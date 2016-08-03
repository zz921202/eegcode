classdef KMeansMachine < handle
    
    properties(Access = private)
    centroids = [];
    num_clusters = 2;
    one_window = [];
    end

    methods
        % find centroids, separators or whatever
        function fit(obj, data_mat, data_windows)
            obj.one_window = data_windows(1);
            disp('starting k means...........');
            [idx, obj.centroids] = kmeans(data_mat, obj.num_clusters,'MaxIter',1000, 'Replicates',20) ;
            
            hist(idx);
            title('kmeans distribution');
            disp('..........finishing kmeans clustering');
            figure

            plot(obj.centroids')
            ss = 1:obj.num_clusters;
            ss = arrayfun(@num2str, ss, 'UniformOutput', false);
            legend(ss)

            title('kmeans vectors')
        end

        % infer the class membership 
        function [idx] = infer(obj, feature_matrix)
            len = size(feature_matrix, 1);
            dists = zeros(len, obj.num_clusters);

            for col = 1: obj.num_clusters
                curentroid = obj.centroids(col, :);
                curdist_vec = feature_matrix - repmat(curentroid , len, 1);
                curdist = sqrt(sum(curdist_vec.^2, 2));
                dists(:, col) = curdist;
            end
            find_max_in_row = @(row) find(row == min(row));
            idx = arrayfun(@(row_ind) find_max_in_row(dists(row_ind, :)), 1:len);
        end


        function show_centroids(obj)
            first_window = obj.one_window;
            C = obj.centroids;
            k = obj.num_clusters;
            plot_limits = [min(min(C)), max(max(C))];
                            
            for curidx = 0:1: k               
                % figure()
                curfeature = C(curidx, :);
                first_window.plot_his_feature(curfeature(:), plot_limits)%, [0, 0.7]);%TODO remove limit
                title(sprintf('%d th component',curidx))

            end

        end


    end

end