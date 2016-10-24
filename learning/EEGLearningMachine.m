classdef EEGLearningMachine < handle
% I am going to break EEG learning into 3 parts cooperating with each other
% this is the training machine which is doing the heavy lifting, Data, Machine, Controller Framework
% note that it will require data from EEGStudySetInterface (rolling fashion)
% k-fold cross_validated training is now implemented in this class


    properties
    end

    methods 
        %% data prepossessing: like normalization e.t.c Of course I could/ might delegate it to specialized prepossessing machine

        %% training: delegate it to different 

        %% prediction: returns margin, score, e.t.c to original data

        %% basic data visualization, say histogram of confidence 

    end
end