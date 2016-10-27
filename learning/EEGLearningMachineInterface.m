classdef EEGLearningMachineInterface < handle
% I am going to break EEG learning into 3 parts cooperating with each other
% this is the training machine which is doing the heavy lifting, Data, Machine, Controller Framework
% note that it will require data from EEGStudySetInterface (rolling fashion)
% k-fold cross_validated training is now implemented in this class


    properties

    end

    methods (Abstract)

        set_studyset(obj, eegstudyset)

        reset(obj) % training of various builtin parameters

        %% data prepossessing: like normalization e.t.c Of course I could/ might delegate it to specialized prepossessing machine
        [x_normal] = normalize(obj, X) % stores normalization parameters inside the current class 
        
        %% training: delegate it to different 
        cv_training(obj) % train a superviseed_learner

        %% prediction: returns margin, score, e.t.c to original data
        [confidence, label] = predict(obj, X) 

        %% basic data visualization, say histogram of confidence 
        visualize(obj) % delegated to the sup_leaenre to visualize data

    end
end