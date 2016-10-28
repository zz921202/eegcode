classdef PostProcessorInterface < handle
    % this is the post_processing core attached to a section of data (however that is defined
    % itself does not contain any data, hence it is purely service provider function
    methods(Abstract)
        [pred_lable, confidence] = process(obj, score)
    end
end