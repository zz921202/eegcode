classdef AveEnsembleMachine < SupervisedLearnerInterface
    
    % 
    % searching parameter adjustment will need to be performed manually
    properties
        compositeAdpt = []
        learners = {}

    end

    methods

        function init(obj, compositeAdpt, learner)
            obj.compositeAdpt = compositeAdpt;
            n = compositeAdpt.get_num_features();
            for ind = 1: n
                obj.learners{ind} = learner.clone();
            end
        end

        % used as a demo to get an idea of basic performance
        function train(obj, X, y, ~)
            n = obj.compositeAdpt.get_num_features();
            for ind = 1: n
%                 ind
                curlearner = obj.learners{ind};
                curX = obj.compositeAdpt.cutX(X, ind);
                curlearner.train(curX, y)
            end
        end

        % use cross validation to search for optimal parameter model
        function [label, score] = cvtrain(obj, X, y)
        end

        % infer label for new data
        function [label, score] = infer(obj, Xnew)
            n = obj.compositeAdpt.get_num_features();
            scores = zeros(size(Xnew, 1), n);
            figure()
            for ind = 1: n
                curlearner = obj.learners{ind};
                curX = obj.compositeAdpt.cutX(Xnew, ind);
                [~,  curscore] = curlearner.infer(curX);
                scores(:, ind) = curscore;
                subplot(1,n, ind)
                plot(curscore);
                title(['suplearner', num2str(ind)]);
            end
            score = mean(scores, 2);
            label = score >= 0.5;
        end

        function curloss = loss(Obj, Xtest, ytest)
            error('not implemeneted')
        end

        function learner = clone(obj)
            learner = AveEnsembleMachine();
            learner.compositeAdpt = obj.compositeAdpt;
            n = compositeApt.get_num_features();

            for ind = 1: n
                learner.learners{ind} = obj.learners{ind}.clone();
            end

        end


    end

    
end