classdef PCAMachine < UnsupervisedMachine

    properties
        V2 = [];
        V3 = [];
        sampling_proportion = 0.05;
        
    end

    methods
        % find centroids, separators or whatever
        function fit(obj, feature_matrix, data_windows)
            disp('..........starting pca...........');
            sample_proportion = obj.sampling_proportion;
            k = floor(length(feature_matrix) * sample_proportion);
            sampled_data_mat = datasample(feature_matrix, k ,1);
            fprintf('size of sampled matrix is %d  by %d' ,size(sampled_data_mat));
            
            [~,~,V] = svd(sampled_data_mat);
            obj.V2 = V(:,1:2);
            obj.V3 = V(:,1:3);
            disp('............end of pca..........');
        end


        % infer the class membership 
        function feature = infer(obj, feature_matrix)
            feature = feature_matrix * obj.V3;
        end

        function scatter2(obj, feature_matrix, color_vec)
            if nargin < 3
                color_vec = ones([size(feature_matrix, 1),1]);
            end

            pca_coordinates = feature_matrix * obj.V2;

            scatter(pca_coordinates(:,1), pca_coordinates(:,2), 15, color_vec, 'filled');

            title('pca 2d plot of color types')
            try
                colorbar
            catch ME
                disp('colorbar not displayed, but ok, not to be alarmed');
            end

        end


        function scatter3(obj, feature_matrix, color_vec)
            if nargin < 3
                color_vec = ones([size(feature_matrix, 1),1]);
            end
            pca_coordinates = feature_matrix * obj.V3;
            scatter3(pca_coordinates(:, 1), pca_coordinates(:, 2), pca_coordinates(:, 3), 15, color_vec, 'filled');
            title('pca 3d plot of color types')
            try
                colorbar
            catch ME
                disp('colorbar not displayed, but ok, not to be alarmed');
            end

        end


    end

end