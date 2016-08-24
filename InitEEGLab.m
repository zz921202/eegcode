classdef InitEEGLab < handle
    % this mimics singleton pattern such that initialization need to carry out only once in a session


    methods (Static)
            function init
                global initialized; % very stupid, eeglab wipes out persistent variable for no good reason
                global myeegcode_dir;
%                 initialized
                if isempty(initialized)
                    cur_dirname = fileparts(mfilename('fullpath'));
                    % myeegcode_dir = cur_dirname;
                    parpath = fileparts(cur_dirname);
                    addpath([parpath '/eeglab']);
                    eeglab
%                     addpath([cur_dirname '/sample_code']);
%                     addpath([cur_dirname '/window_feature']);
%                     addpath([cur_dirname '/load']);
                    addpath(genpath(cur_dirname));
                    addpath(genpath([cur_dirname, '/learning/HMMall']));
                    initialized = true;
                    disp('initialized')
                    % parpool()
                end
            end
            



    end
 end

 


