classdef PCAMachine < UnsupervisedMachine

    properties
        V2 = [];
        V3 = [];
        CUTOFF = 95;
        sampling_proportion = 1;
        principle_components;
        x_lim_range = [];
        y_lim_range = [];
        z_lim_range = [];
    end

    methods
        % find centroids, separators or whatever
        function fit(obj, feature_matrix, data_windows)
            global tool_pca % to avoid overloading with multiple libraries
            disp('..........starting pca...........');
            sample_proportion = obj.sampling_proportion;
            k = floor(length(feature_matrix) * sample_proportion);
            sampled_data_mat = datasample(feature_matrix, k ,1);
            fprintf('size of sampled matrix is %d  by %d' ,size(sampled_data_mat));
            
            [V, score, latent, tsquared, explained] = tool_pca(sampled_data_mat);
            % figure()
            % plot(explained);
            % title('explanatory power of principle components')

            total_explained = cumsum(explained);
            inidcator = [true; total_explained(2:end) < obj.CUTOFF];
            fprintf('pca machine selected %d principle components out of %d features',sum(inidcator), size(sampled_data_mat, 2));
            obj.principle_components = V(:, inidcator);
            obj.V2 = V(:,1:2); 
            obj.V3 = V(:,1:3);
            max_score = max(score);
            min_score = min(score);
            get_score = @(index) [min_score(index), max_score(index)];

            obj.x_lim_range = get_score(1);
            obj.y_lim_range = get_score(2);
            obj.z_lim_range = get_score(3);
            disp('............end of pca..........');

        end


        % pca dimension reduction 
        function feature = infer(obj, feature_matrix)
            size(feature_matrix)
            size(obj.principle_components)
            feature = feature_matrix * obj.principle_components;
        end



        function scatter2(obj, feature_matrix, color_vec)
            if nargin < 3
                color_vec = ones([size(feature_matrix, 1),1]);
            end

            pca_coordinates = feature_matrix * obj.V3;

            scatter(pca_coordinates(:,1), pca_coordinates(:,2), 15, color_vec, 'filled');
            xlim(obj.x_lim_range);
            ylim(obj.y_lim_range);
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
            xlim(obj.x_lim_range);
            ylim(obj.y_lim_range);
            zlim(obj.z_lim_range);
            title('pca 3d plot of color types')
            try
                colorbar
            catch ME
                disp('colorbar not displayed, but ok, not to be alarmed');
            end

        end


    end

end