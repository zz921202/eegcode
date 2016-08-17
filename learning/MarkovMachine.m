classdef MarkovMachine < SupervisedLearnerInterface
    % note that this only works for binary case
    % searching parameter adjustment will need to be performed manually
    properties
        transmat
        suplearner
        lookforward = 3
        prior = [0.5, 0.5]'
        cur_alpha
        cur_gamma
    end

    methods(Access = private)
        function forward_backward(obj, obslik)
            [alpha0,beta0, gamma0, loglik, xi, gamma2] = fwdback(obj.prior, obj.transmat, obslik);
            obj.cur_gamma = gamma0;
            obj.cur_alpha = alpha0;
        end

        function forward_smoothing(obj, obslik)
            w = obj.lookforward;
            S = 2; % only dealing with binary now
            T = size(obslik, 2);
            transmat = obj.transmat;
            prior = obj.prior;
            alpha1 = zeros(S, T);
            gamma1 = zeros(S, T);
            xi1 = zeros(S, S, T-1);
            alpha_win = normalise(prior .* obslik(:, 1));% window of conditional observation likelihoods
            olik_win = obslik(:, 1);
            alpha1(:,1) = alpha_win;
            for t=2:T
              [alpha_win, olik_win, gamma_win, xi_win] = ...
                  fixed_lag_smoother(w, alpha_win, olik_win, obslik(:, t), transmat);
              alpha1(:,max(1,t-w+1):t) = alpha_win;
              gamma1(:,max(1,t-w+1):t) = gamma_win;
              xi1(:,:,max(1,t-w+1):t-1) = xi_win;
            end
            obj.cur_gamma = gamma1;

        end

        

    end

    methods

        function set_sup_learner(obj, suplearner)
            obj.suplearner = suplearner;
        end
        % used as a demo to get an idea of basic performance
        function train(obj, X, y, options_map)
            obj.suplearner.train(X, y)
            y = y' + 1;
            [dirichletPriorWeight, other] = process_options(...
                [], 'dirichletPriorWeight', 0);
            [transmat, initState] = transmat_train_observed(y, 2, ...
                                    'dirichletPriorWeight', dirichletPriorWeight);
            obj.transmat = transmat;

        end

        % use cross validation to search for optimal parameter model
        function [label, score] = cvtrain(obj, X, y)
        end
        % infer label for new data
        function [label, score] = infer(obj, Xnew)
            [~, oldprob] = obj.suplearner.infer(Xnew);
            prob = oldprob(:);
            obslik = [prob'; 1- prob'] ;
            fprintf('size of obslik is %d, %d \n', size(obslik,1), size(obslik,2));
            obj.forward_smoothing(obslik); % change the smoothing method here
            score = obj.cur_gamma(1,:); %TODO change back to gamma

            fprintf('size of score is %d, %d \n', size(score,1), size(score, 2));
            figure
            hist(score)
            score = score';
            label = score > 0.5;
            label = double(label);
            figure
            subplot(121)

            plot(oldprob(:));
            title('old prob')

            subplot(122)
            plot(score(:));
            ylim([0, 1])
            title('smoothed prob')
        end
        function curloss = loss(Obj, Xtest, ytest)
            error('loss is not supported currently')
        end


        function mmachine = clone(obj)
            mmachine = MarkovMachine();
            mmachine.transmat = obj.transmat;
            mmachine.suplearner = obj.suplearner.clone();
        end
    end
end