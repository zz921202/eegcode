classdef NaiveHMM < SupervisedLearnerInterface
    % searching parameter adjustment will need to be performed manually
    properties(Access = private)
        mu 
        transmat
        Sigma
        nstates = 5
    end

    methods

        % used as a demo to get an idea of basic performance
        function [label, score] = train(obj, X, y, options_map)

            % obsData(:,t,ex) 
            % hiddenData(ex,t) 
            y = y(:)';
            [initState, transmat, mu, Sigma] = gausshmm_train_observed(obsData, hiddenData, ...
                          obj.nstates)
        end


        % use cross validation to search for optimal parameter model
        function [label, score] = cvtrain(obj, X, y)
        end
        % infer label for new data
        function [label, score] = infer(obj, Xnew)
        end

    end
end