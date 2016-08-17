classdef PerformanceEvalImp < handle
% performs evaluation and logging note 

    properties
        learningAdpt
        window_size
        step_size
        posclass = 0;
        okay_range = 300; % the range over which any detection is accepted

    end

    methods(Access = private)

        function str = auc(obj, ytest, score, label)
            [X,Y,~,AUC] = perfcurve(ytest, 1 - score, obj.posclass);
            figure()
            plot(X,Y)
            xlabel('False positive rate')
            ylabel('True positive rate')
            title(['ROC for Classification by', obj.learningAdpt.get_tag()])
            str = sprintf('auc, %.5f, ' ,AUC);
        end

        function str = latency(obj, y, score, label)
            true_onset = obj.find_onsets(y)
            true_end = obj.find_ends(y);

            myonset = obj.find_onsets(label)
            missing_seizure = 0;
            latency = [];
            copy_label = 1 - label;
            n = length(y);
            for ind = 1: length(true_onset)
                cur_onset = true_onset(ind);
                cur_end = true_end(ind);
                okay_start = max(cur_onset - obj.okay_range,1 );
                
                okay_end = min(cur_end + obj.okay_range, n); 
                copy_label(okay_start: okay_end) = 0;
                okay_condition = @(swicth_point) swicth_point > okay_start  && swicth_point < okay_end;
                okay_inds = find(arrayfun(okay_condition, myonset));

                if isempty(okay_inds)
                    missing_seizure = missing_seizure + 1;
                else
                    % find the earliest detection time
                    okay_points = myonset(okay_inds);
                    detection_gap = min(okay_points - cur_onset)
                    latency = [latency, obj.learningAdpt.get_algorithm_lag() + detection_gap * obj.step_size];
                end
            end
            wrong_flag = sum(copy_label);

            figure()
            hist(latency)
            title(['latency of ', obj.learningAdpt.get_tag()] );
            str = sprintf('latency, %d, missing_seizures, %d, false_flags, %d', mean(latency), missing_seizure, wrong_flag);
        end


        function onset_points = find_onsets(obj, y)
            % switch from one to zero
            swicth_points = [];
            n = length(y);
            pre = y(1);
            % plot(y);
            if pre == 0 %TODO caters specifically to 0 seizure, 1 none-seizure labeling
                switch_points = [0,];
            end
            
            for ind = 2: n
               cur = y(ind);
                if pre - cur == 1;
                    swicth_points = [swicth_points, ind];
                end
                pre = cur;
            end
            onset_points = swicth_points;
        end


        function end_points = find_ends(obj, y)
            % switch from zero to 1
            swicth_points = [];
            n = length(y);
            pre = y(1);
            % plot(y);
            
            for ind = 2: n
               cur = y(ind);
                if pre - cur == -1;
                    swicth_points = [swicth_points, ind];
                end
                pre = cur;
            end

            end_points = swicth_points;
        end

       
        function logging(obj, str)
            fileID = fopen(obj.learningAdpt.get_logfile_name() ,'a');
            c = clock;
            timestr = datestr(c);
            result_str = [timestr,' ' str ,'\n'] ;
            fprintf(fileID,result_str);
        end


    end

    methods

        function init(obj, learningAdpt)
            obj.learningAdpt = learningAdpt;
        end

        function eval(obj, ytest, score, label)
            [obj.window_size, obj.step_size] = obj.learningAdpt.get_window_step_size();
            auc_str = obj.auc(ytest, score, label);
            la_str = obj.latency(ytest, score, label);
            tag_str = obj.learningAdpt.get_tag();
            [~,~,window_str] = obj.learningAdpt.get_window_step_size();
            result_str = [tag_str, window_str, auc_str, la_str];
            obj.logging(result_str);

        end


    end

end