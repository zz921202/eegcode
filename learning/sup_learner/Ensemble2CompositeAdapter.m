classdef Ensemble2CompositeAdapter < handle

    properties
        composite_window_example = [];
    end

    methods

       function  init(obj,composite_window)
            obj.composite_window_example = composite_window;
        end

        function num = get_num_features(obj)
            num = obj.composite_window_example.get_num_children();
        end

        function curX = cutX(obj, X, k)
            [startind, endind] = obj.composite_window_example.get_child_feature_ind(k);
            curX = X(:, startind: endind);
        end

    end

end