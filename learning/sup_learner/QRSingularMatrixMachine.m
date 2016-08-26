classdef QRSingularMatrixMachine < SingularMatrixMachine

    properties
        tol = 1e-3;
        R;
    end
    
    methods(Access = protected)
    %set transformMatrix
        function decompose(obj, X)
            [Q, R] = qr(X,0);
            indicator = abs(diag(R)) > obj.tol;
            figure()
            imagesc(R)
            obj.R = R;
            obj.transformMatrix = diag(indicator);
            obj.transformMatrix = obj.transformMatrix(:, indicator);
            fprintf('kept %d out of %d \n',  sum(indicator), length(indicator));
        end

        function machine = create_myself(obj)
            machine = QRSingularMatrixMachine();
        end
    end

end