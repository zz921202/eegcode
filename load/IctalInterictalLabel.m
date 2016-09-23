classdef  IctalInterictalLabel < StudyClassifierLabelInterface
    % this is a custome class used to generate labels for EEGLearnings' training, supervised or unsupervised
    % could be switched at run time 
    properties

    end

    methods 
        % uses EEGWindow's time stamp to implement different labeling strategy (pattern)
        % include dictates whether curWindow should be included 
        function [label, toInclude] = get_label(obj, windowdata)
            relative_timestamp = windowdata.relative_timestamp;
            toInclude = true;
            % disp('using imp')
            if abs(relative_timestamp) < 30
                % disp('not including this window')
                toInclude = false;
            end
            if relative_timestamp == 0 
                if windowdata.seizure_timestamp < 18
                    toInclude = true;
                end
                label = 1;
            else
                label = 0;
            end
        end

    end

end

