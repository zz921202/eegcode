classdef SVDSingularMatrixMachine < SingularMatrixMachine

    properties
        tol = 1e-3;
    end

    methods(Access = protected)
    %set transformMatrix
        function decompose(obj, X)
            [~, S, V] = svd(X);
            indicator = abs(diag(S)) > obj.tol;
            obj.transformMatrix = V(:, indicator);
        end

        function machine = create_myself(obj)
            machine = SVDSingularMatrixMachine();
        end
    end

end