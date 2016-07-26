classdef UnsupervisedMachine < handle
    
    properties
    end

    methods
        % find centroids, separators or whatever
        function fit(obj, feature_matrix, data_windows)
        end
        % infer the class membership 
        function [feature] = infer(obj, feature_matrix)
        end
    end


end