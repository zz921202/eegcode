classdef LassoLogisticMachine< SupervisedLearnerInterface
    % searching parameter adjustment will need to be performed manually
    % SUPPORTS batch lambda param computation
    properties
        mybeta
        weight = 2
        switch_points = []
        onset_weights = 10;
        plot_lasso = false;
    end



    methods(Access = private)

        function cost = cost_function(obj, mindist)
            cost = obj.onset_weights * exp(- 0.2 * mindist);
        end


        function addon = add_cost(obj, y)
            obj.find_switch_points(y);
            n = length(y);
            addon = zeros(n, 1);
            allind = find(y == 0);
            for ind = allind';
               
                dists = ind - obj.switch_points;
                mindist = min(dists(dists >= 0));
                addon(ind) = obj.cost_function(mindist);
            end
        end


        function find_switch_points(obj, y)
            % switch from one to zero
            obj.switch_points = [];
            n = length(y);
            pre = y(1);
            % plot(y);
            if pre == 0 %TODO caters specifically to 0 seizure, 1 none-seizure labeling
                obj.switch_points = [0,];
            end
            
            for ind = 2: n
               cur = y(ind);
                if pre - cur == 1;
                    obj.switch_points = [obj.switch_points, ind];
                end
                pre = cur;
            end
        end


        function w = get_weight(obj, y)
            n = length(y);
            w = double(ones(n, 1) +  y * obj.weight + obj.add_cost(y));
        end


    end

    methods

        % used as a demo to get an idea of basic performance
        function train(obj, X, y, lasso_params)

            
            n = length(y);
            X = real(double( X));
            % figure()
            % imagesc(X(1:100, :));
            w = obj.get_weight(y); 
            opts = statset('UseParallel',true);

            if nargin < 4
                [B, FitInfo] = lassoglm(X, y, 'binomial' , 'Weights', w, 'NumLambda', 20, 'Options', opts);
            else
                [B, FitInfo] = lassoglm(X, y, 'binomial' , 'Weights', w, 'lambda', lasso_params, 'Options', opts);
            end
            obj.mybeta = [FitInfo.Intercept; B];
            % lasso_params
            if obj.plot_lasso
                figure
                plot(lasso_params, FitInfo.Deviance);
            end
            fprintf('lasso computation for %d examples, %d features\n', size(X, 1), size(X, 2));
        end

        % use cross validation to search for optimal parameter model
        function [label, score] = cvtrain(obj, X, y)

        end
        % infer label for new data
        function [label, score] = infer(obj, Xnew)
            n = size(Xnew, 1);
            aug_X = real([ones(n,1), Xnew]);
            % size(aug_X)
            % size(obj.mybeta)
            fprintf('Lasso Machine  has %d fitted models for lambdas\n', size(obj.mybeta, 2));
            score = real(1 ./ (1 + exp(- aug_X * obj.mybeta)));
            if size(obj.mybeta,2 )>1
                label = [];
                disp('Lasso Machine: no label returned since I have more models');
            else
                label = score > 0.5;
                label = double(label);
            end
            
        end

        function allLoss = loss(obj, Xtest, ytest) % just the normal nll loss
            [~, score] = obj.infer(Xtest);
            L = size(obj.mybeta, 2);
            w = obj.get_weight(ytest);
            weight1mat = repmat(w(ytest == 1) , [1,L]);
            weight0mat  = repmat(w(ytest == 0) , [1,L]);
            
            allLoss = -sum(log(score(ytest == 1, :)) .*  weight1mat, 1 ) - sum(log(1 - score(ytest == 0, :) ).*  weight0mat, 1);
        end

        function lassoMachine = clone(obj)
            lassoMachine = LassoLogisticMachine();
            lassoMachine.mybeta = obj.mybeta;
            lassoMachine.onset_weights = obj.onset_weights;
            
        end
    end
end