classdef CVMachine < SupervisedLearnerInterface
    % note that this only works for binary case
    % need to mannually set sweeping crtiteria and TODO nly support 0-1 labelsing
    properties
        suplearner
        sweep_params = -5: 1 : 5;
        proportion_test = 0.2
    end



    methods

        function set_sup_learner(obj, suplearner)
            obj.suplearner = suplearner;
        end

        % used as a demo to get an idea of basic performance
        function train(obj, X, y, ~)
            
            grp = unique(y);
            exp_sweep = exp(obj.sweep_params);
            [positiveTrain, positiveTest] = crossvalind('HoldOut', y, obj.proportion_test,  'Classes', [grp(1),]);

            [negativeTrain, negativeTest] = crossvalind('HoldOut', y, obj.proportion_test,  'Classes', [grp(2),]);
            all_loss = [];
            XTrain = X(logical(positiveTrain + negativeTrain), :);
            XTest = X(logical(positiveTest + negativeTest), :);
            yTrain = y(logical(positiveTrain + negativeTrain), :);
            yTest = y(logical(positiveTest + negativeTest), :);
            for curreg = exp_sweep
                
                obj.suplearner.train(XTrain, yTrain, curreg);
                curloss = obj.suplearner.loss(XTest, yTest);
                all_loss = [all_loss, curloss];
                sprintf('reg: %s loss: %s\n', curreg, curloss)
            end
            figure()
            plot(obj.sweep_params, all_loss);
            title('regularization and loss')
            best_reg_ind = find(all_loss == min(all_loss));
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
    end
end