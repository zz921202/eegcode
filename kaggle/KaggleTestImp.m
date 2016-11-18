classdef KaggleTestImp < TestingImplementationInterface 
% This class will be attached to study set to drive the choice of sets used for testing 
% also drive the process of testing by calling train method in study set, basically the whole 
% I will create a five fold test implementation if allowed

    properties
        studyset = [];
        num_pos_sections = 0;
        num_neg_sections = 0;
        max_fold = 1; % a slight variation of this will also be used to implement CV schedule, ratehr than leaving it inside studyset

        pos_test_schedule_cell = {};
        neg_test_schedule_cell = {};
        logging_dir = '';
    end

    methods
        function set_studyset(obj, studyset)
            obj.studyset = studyset;
            obj.logging_dir = [get_myeegcode_dir(), '/kaggle/out']; % INIT eeglab first
        end

        function reset(obj) % get information from studyset to set up testing schedule, after window extraction
            [obj.num_pos_sections, obj.num_neg_sections] = obj.studyset.get_num_datasets();
%             assert(obj.num_pos_sections >= obj.max_fold, sprintf('too few positive sections for testing, fold=%d < pos_sections %d', obj.max_fold, obj.num_pos_sections));

            pos_increment = floor(obj.num_pos_sections / obj.max_fold);
            neg_increment = floor(obj.num_neg_sections / obj.max_fold);
            prev_pos = 1;
            prev_neg = 1;
            for idx = 1: obj.max_fold % leaving out the tail 
                obj.pos_test_schedule_cell = [obj.pos_test_schedule_cell, prev_pos : idx * pos_increment]; %EXPAND CELL
                obj.neg_test_schedule_cell = [obj.neg_test_schedule_cell, prev_neg : idx * neg_increment]; %EXPAND CELL
                prev_pos = idx * pos_increment + 1;
                prev_neg = idx * neg_increment + 1;
            end
        end

        function test(obj) % instruct studyset to carry out testing after eeglearning has been set up
            confidence_array = [];
            predicted_label_array = [];
            true_label_array = [];
            dataset_name_cell = {};
            for idx = 1: obj.max_fold
                obj.studyset.set_testing_dataset(obj.pos_test_schedule_cell{idx}, obj.neg_test_schedule_cell{idx});
               
                obj.studyset.train();
                [cur_confidence, cur_pred_label, cur_true_label, cur_dataset_names ] = obj.studyset.post_processing();
                
                predicted_label_array = [predicted_label_array; cur_pred_label]; % EXPAND ARRAY
                confidence_array = [confidence_array; cur_confidence]; % EXPAND ARRAY
                true_label_array = [true_label_array; cur_true_label]; % EXPAND ARRAY
                dataset_name_cell = [dataset_name_cell, cur_dataset_names]; %EXPAND CELL
                
%                 fprintf('prediction label array(%d) and file_name_cell size (%d)', length(dataset_name_cell), length(predicted_label_array));
            end
            
            result_str = obj.evaluate(true_label_array, confidence_array, predicted_label_array);
            disp(result_str);
            obj.dump_result(result_str, dataset_name_cell, predicted_label_array, confidence_array);
        end


        function result = evaluate(obj, true_label_array, confidence_array, predicted_label_array) % plotting performed here
            result = obj.auc(true_label_array, confidence_array, predicted_label_array);
        end


        function str = auc(obj, ytest, score, pred)

            figure
            conf = confusionmat(ytest, pred);
            disp(conf);
            imagesc(conf);
            xlabel('true label')
            ylabel('predicted label')

            [X,Y,~,AUC] = perfcurve(ytest, score, 1);
            figure()
            plot(X,Y)
            xlabel('False positive rate')
            ylabel('True positive rate')
            title(['ROC for Classification'])
            str = sprintf('auc_%.5f, ' ,AUC);
        end

        function set_logging_dir(obj, use_dir)
            obj.logging_dir = use_dir;
        end

        function dump_result(obj, mytitle, file_name_cell, predicted_label_array, score)
            [~,timestr]=unix('date +out_%F_-%H:%M_%S%N');
            dump_file_name_path = [obj.logging_dir, '/', mytitle, timestr];

            file_handle = fopen(dump_file_name_path, 'w');
            assert(length(file_name_cell) == length(predicted_label_array) ...
                , sprintf('prediction label array(%d) and file_name_cell size mismatch(%d)', length(file_name_cell), length(predicted_label_array)));
            for idx = 1: length(file_name_cell)
                cur_line = sprintf('%s, %d, %s \n', file_name_cell{idx}, predicted_label_array(idx), num2str(score(idx)));
                fprintf(file_handle, cur_line);
            end

        end
    end
end









