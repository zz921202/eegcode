classdef KMeansMachine < handle
    
    properties
    centroids = [];
    num_clusters = 6;
    end

    methods
        % find centroids, separators or whatever
        function fit(obj, feature_matrix, data_windows)
            disp('..........starting k means...........');
            [idx, centroids] = kmeans(data_mat, obj.num_clusters,'MaxIter',1000, 'Replicates',20) ;
            disp('finishing kmeans clustering');
        end

        % infer the class membership 
        function [feature] = infer(obj, feature_matrix)
            
        end
    end


end