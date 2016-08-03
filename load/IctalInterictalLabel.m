classdef  IctalInterictalLabel < StudyClassifierLabelInterface
    % this is a custome class used to generate labels for EEGLearnings' training, supervised or unsupervised
    % could be switched at run time 
    properties

    end

    methods 
        % uses EEGWindow's time stamp to implement different labeling strategy (pattern)
        % include dictates whether curWindow should be included
        function [label, toInclude] = get_label(obj,EEGWindow)
            relative_timestamp = EEGWindow.relative_timestamp;
            toInclude = true;
            if relative_timestamp == 0
                label = -1;
            else
                label = 1;
            end
        end

    end

end

