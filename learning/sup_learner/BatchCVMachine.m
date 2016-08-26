classdef BatchCVMachine < SupervisedLearnerInterface
    % note that this only works for binary case
    % need to mannually set sweeping crtiteria and TODO nly support 0-1 labelsing
    properties
        suplearner
        sweep_params = -10: 1 : 5;
        % sweep_params = 1;
        proportion_test = 0.2;
        folds = 5;
    end



    methods

        function set_sup_learner(obj, suplearner)
            obj.suplearner = suplearner;
        end

        % used as a demo to get an idea of basic performance
        function train(obj, X, y, ~)
            all_loss = zeros(obj.folds, length(obj.sweep_params));
            exp_sweep = exp(obj.sweep_params);
            for ind = 1: obj.folds
                grp = unique(y);
                
                [positiveTrain, positiveTest] = crossvalind('HoldOut', y, obj.proportion_test,  'Classes', [grp(1),]);

                [negativeTrain, negativeTest] = crossvalind('HoldOut', y, obj.proportion_test,  'Classes', [grp(2),]);
                fold_loss = [];
                XTrain = X(logical(positiveTrain + negativeTrain), :);
                XTest = X(logical(positiveTest + negativeTest), :);
                yTrain = y(logical(positiveTrain + negativeTrain), :);
                yTest = y(logical(positiveTest + negativeTest), :);
                
                obj.suplearner.train(XTrain, yTrain, exp_sweep);

                fold_loss = obj.suplearner.loss(XTest, yTest); % 
                % fprintf('reg: %s loss: %s\n', curreg, curloss);
                all_loss(ind, :) = fold_loss;
            end

            mean_all_loss = mean(all_loss)

            % figure()
            % % plot(obj.sweep_params, all_loss);
            % title('regularization and loss')
            best_reg_ind = find(mean_all_loss == min(mean_all_loss));
            best_reg = exp_sweep(best_reg_ind(1));
            disp(['end of sweeping, best param is', num2str(best_reg)]);
            obj.suplearner.train(X,y, best_reg);
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
            cvmachine = CVMachine();
            cvmachine.suplearner = obj.suplearner.clone();
        end
    end
end