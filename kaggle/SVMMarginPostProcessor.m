classdef SVMMarginPostProcessor < PostProcessorInterface 
    % this is the post_processing core attached to a section of data (however that is defined
    % itself does not contain any data, hence it is purely service provider function
    methods
        function [pred_label, confidence] = process(obj, margin_array) %OBJ is not used since it is a service class
            pos_count = sum(margin_array > 0);
            neg_count = sum(margin_array <= 0);
            confidence  = pos_count / (pos_count + neg_count);
            fprintf('zero count: %d\n', sum(margin_array == 0));
            if isnan(confidence)
                fprintf('nan neg_count %d pos_ocunt %d', pos_count, neg_count);
            end

            pred_label = double(confidence > 0.5);

            % summing up the margin 


            sum_margin = sum(margin_array);
            confidence  = 1 ./ (1 + exp(-sum_margin));
            pred_label = double(sum_margin > -0.3);
        end
    end
end

