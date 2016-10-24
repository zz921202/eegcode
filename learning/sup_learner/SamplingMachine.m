classdef SamplingMachine < SupervisedLearnerInterface
    % note that this only works for binary case
    % need to mannually set sweeping crtiteria and TODO nly support 0-1 labelsing
    properties
        suplearner
        proportion = 4;
        % kmeans_machine = KMeansMachine();
        % grouping = [0, 1]; %assume that 1 represents seizure while 0 represents otherwise
    end



    methods

        function init(obj, suplearner)
            obj.suplearner = suplearner;
        end

        % used as a demo to get an idea of basic performance
        function train(obj, X, y, learning_obj)

            grouping = unique(y);
            pos_eg = X(y == grouping(1), :);
            neg_eg = X(y == grouping(2), :);

            if size(pos_eg,1) > size(neg_eg,1) * obj.proportion
                domi_X = pos_eg;
                domi_y_type = grouping(1);
                other_X = neg_eg;
                other_y_type = grouping(2);
            elseif size(neg_eg,1) > size(pos_eg,1) * obj.proportion
                domi_X = neg_eg;
                domi_y_type = grouping(2);
                other_X = pos_eg;
                other_y_type = grouping(1);
            else
                error('dataset not suitable for sampling algorithm')
            end
            other_len = size(other_X, 1);
            x_len = size(other_X, 1) * obj.proportion;
            fprintf('to sample %d out of %d with %d features', x_len, size(domi_X, 1), size(domi_X, 2));

            % normal sampling
            % indicator = randsample(1: size(domi_X, 1), x_len);

            % k-means sampling scheme
            disp(learning_obj)
            kmeans_machine = learning_obj.k_means_machine;
            % kmeans_machine.fit(domi_X);
            indicator = kmeans_machine.sampling(x_len, domi_X);
            % indicator(1: 100)
            % figure()
            % hist(indicator)
            % title('index sampled with k-means scheme')
            
            domi_X = domi_X(indicator, :);

            train_X = [domi_X; other_X];
            train_y = [ones(x_len, 1) * domi_y_type; ones(other_len, 1) * other_y_type];
            % hist(train_y)
            obj.suplearner.train(train_X, train_y, learning_obj);
        end
        % use cross validation to search for optimal parameter model



        function [label, score] = cvtrain(obj, X, y)
            label = [];
            score = [];
            error('cv train not supported in CVMachine')
        end

        % infer label for new data
        function [label, score] = infer(obj, Xnew)
            [label, score] = obj.suplearner.infer(Xnew);
        end

        function curloss = loss(Obj, Xtest, ytest)
            curloss = 0;
            warning('curloss train not supported in CVMachine')
        end

        function cvmachine = clone(obj)
            cvmachine = SamplingMachine();
            cvmachine.suplearner = obj.suplearner.clone();
        end
    end

end