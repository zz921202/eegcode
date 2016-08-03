classdef InitEEGLab < handle
    % this mimics singleton pattern such that initialization need to carry out only once in a session


    methods (Static)
            function init
                global initialized; % very stupid, eeglab wipes out persistent variable for no good reason
%                 initialized
                if isempty(initialized)
                    cur_dirname = fileparts(mfilename('fullpath'));
                    parpath = fileparts(cur_dirname);
                    addpath([parpath '/eeglab']);
                    eeglab
                    addpath([cur_dirname '/sample_code']);
                    addpath([cur_dirname '/window_feature']);
                    addpath([cur_dirname '/load']);
                    addpath(genpath('learning/HMMall'));
                    initialized = true;
                    disp('initializing')
                end
            end
            

    end
 end

 

