classdef StudyClassifierLabelInterface < handle
    % this is a custome class used to generate labels for EEGLearnings' training, supervised or unsupervised
    % could be switched at run time 
    properties

    end

    methods 
        % uses EEGWindow's time stamp to implement different labeling strategy (pattern)
        % include dictates whether curWindow should be included
        % Vanilla flavour implementation
        function [label, include] = get_label(obj, windowdata)
            label = windowdata.get_color_type();
            include = true;
        end
    end

end

