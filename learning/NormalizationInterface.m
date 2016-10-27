classdef NormalizationInterface < handle
% this class will be used eeglearning to perform normalization of data
% notice that it will save pointer to the sane underlying pcamachine as eeglearning class
% so be mindful of mutations 


    properties
    end

    methods(Abstract)

        init(obj, pca_machine, k_means)  % pass learner's pca machine to this class to be trained

        reset(obj, X) % resetcontinue to use old pca_machine and k_means machine, but I will retrain all of them

        [x_normalized] = normalize(obj, X) % normalize data to be feed for training


    end
end