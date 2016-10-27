classdef MaxMinNormalization < handle
% this class will be used eeglearning to perform normalization of data
% notice that it will save pointer to the sane underlying pcamachine as eeglearning class
% so be mindful of mutations 


    properties
        pca_machine;
        k_means_machine;
        col_min = [];
        col_max = [];
    end

    methods(Abstract)

        function init(obj, pca_machine, k_means_machine)  % pass learner's pca machine to this class to be trained
            obj.pca_machine = pca_machine;
            obj.k_means_machine = k_means_machine;
        end

        function reset(obj, X) % resetcontinue to use old pca_machine and k_means machine, but I will retrain all of them
            tic
            disp('to fit pca_means_machine')
            obj.pca_machine(X);
            toc

            tic
            disp('to fit k_means_machine')
            obj.k_means_machine.fit(X);
            toc

            obj.col_min = min(X);
            obj.col_max = max(X);

        end


        function [normalized_X] = normalize(obj, X) % normalize data to be feed for training
            [m, ~] = size(X);
            center_zero_X = X - repmat(obj.col_min, m, 1);
            normalized_X = center_zero_X ./ repmat(obj.col_max - obj.col_min, m, 1); 
        end



    end
end