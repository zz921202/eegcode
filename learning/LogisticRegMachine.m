classdef LogisticRegMachine< SupervisedLearnerInterface
    % searching parameter adjustment will need to be performed manually
    properties
        mybeta
        weight = 2
    end

    methods

        % used as a demo to get an idea of basic performance
        function train(obj, X, y, options_map)
            n = length(y)
            aug_X = double([ones(n,1), X]);
            w = double(ones(n, 1) +  y * obj.weight);
            obj.mybeta = logistic(aug_X, y, w)
        end

        % use cross validation to search for optimal parameter model
        function [label, score] = cvtrain(obj, X, y)
        end
        % infer label for new data
        function [label, score] = infer(obj, Xnew)
            n = size(Xnew, 1);
            aug_X = [ones(n,1), Xnew];
            score = 1 ./ (1 + exp(- aug_X * obj.mybeta));
            label = score > 0.5;
            label = double(label);
        end

    end
end