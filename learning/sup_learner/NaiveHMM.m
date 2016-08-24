classdef NaiveHMM < SupervisedLearnerInterface
    % searching parameter adjustment will need to be performed manually
    properties(Access = public)
        mu 
        transmat
        Sigma
        nstates = 2

        % maxNproto = 3
    end




    methods

        % used as a demo to get an idea of basic performance
        function train(obj, X, y, options_map)

            % obsData(:,t,ex) 
            % hiddenData(ex,t) 
            hiddenData = y';
            observed_data = X';
            [initState, obj.transmat, obj.mu, obj.Sigma] = gausshmm_train_observed(observed_data, hiddenData, ...
                obj.nstates);
        end


        % use cross validation to search for optimal parameter model
        function [label, score] = cvtrain(obj, X, y)
        end
        % infer label for new data
        function [label, score] = infer(obj, Xnew)
            B = mixgauss_prob(Xnew', obj.mu, obj.Sigma);
            [path] = viterbi_path([0; 1], obj.transmat, B);
            label = path';
            score = path';
        end

    end
end