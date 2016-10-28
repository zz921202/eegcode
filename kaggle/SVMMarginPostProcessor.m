classdef SVMMarginPostProcessor < PostProcessorInterface 
    % this is the post_processing core attached to a section of data (however that is defined
    % itself does not contain any data, hence it is purely service provider function
    methods
        function [pred_lable, confidence] = process(obj, margin_array) %OBJ is not used since it is a service class
            pos_count = sum(margin_array > 0);
            neg_count = sum(margin_array < 0);
            confidence  = pos_count / (pos_count + neg_count);
            pred_lable = double(confidence > 0.5);
        end
    end
end

