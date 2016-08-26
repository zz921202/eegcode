classdef SingularMatrixMachine < SupervisedLearnerInterface
    % searching parameter adjustment will need to be performed manually
    properties(Access = public)
        transformMatrix = [];
        suplearner = [];
        % maxNproto = 3
    end




    methods 

        function init(obj, suplearner)
            obj.suplearner = suplearner;
        end

        % used as a demo to get an idea of basic performance
        function train(obj, X, y, options_map)
            % any(isnan(X))
            obj.decompose(X);
            X_trans = X * obj.transformMatrix;
            fprintf('using %d features\n', size(X_trans,2));
            obj.suplearner.train(X_trans, y);
        end




        % use cross validation to search for optimal parameter model
        function [label, score] = cvtrain(obj, X, y)
        end


        % infer label for new data
        function [label, score] = infer(obj, Xnew)
            X_trans = Xnew * obj.transformMatrix;
            [label, score] = obj.suplearner.infer(X_trans);
        end

        function curloss = loss(Obj, Xtest, ytest)
            error('loss is not supported currently')
        end

        function mmachine = clone(obj)
            mmachine = obj.create_myself();
            mmachine.transformMatrix = obj.transformMatrix;
            mmachine.suplearner = obj.suplearner.clone();
        end
    end
    methods(Access = protected)
                % set transformMatrix for future use
        function decompose(obj, X)
        end

        function machine = create_myself(obj)
        end
    end


end