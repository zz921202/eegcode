classdef KaggleDataCapsule < handle
    properties
        data
        full_name
        idx_name
        preictal
        srate
        sequence % -1 to indicate none existent field
    end

    methods
        function read_data_structure(obj, data_structure, file_name) % read a particular data_structure into current window
            obj.full_name = file_name;

            parts = strsplit('.',file_name); % just splitting the string to get the coveted indices
            first_part = parts{1};

            idx_parts = strsplit('_',first_part);
            obj.preictal = str2num(idx_parts{3});
            obj.idx_name = str2num(idx_parts{2});
            obj.srate = data_structure.iEEGsamplingRate;
            obj.data = double(data_structure.data');

            % remove flat columns
            indicator = (sum(abs(obj.data)) == 0);
            fprintf('removed %d columns from %s', sum(indicator), obj.full_name);
            obj.data = obj.data(:, ~indicator);

            % sequence info
            if isfield(data_structure, 'sequence')
                obj.sequence = data_structure.sequence;
            else
                obj.sequence = -1;
            end
        end

        function [idx_name, preictal] = get_idx_name(obj, file_name)
            parts = strsplit('.',file_name); % just splitting the string to get the coveted indices
            first_part = parts{1};
            idx_parts = strsplit('_',first_part);            
            idx_name = str2num(idx_parts{2});
            preictal = str2num(idx_parts{3});
        end

        function indicator = is_preictal(obj) % returns 1 if it is a preitcal state
            indicator = (obj.preictal == 1);
        end

        function data = get_data(obj) % return channel * data_points data
            data = obj.data;
        end

        function srate = get_srate(obj) % get sampling rate of current snippet
            srate = obj.srate;
        end

        function [isEnd, sequence_num] = get_sequence_num(obj) 
        % return sequence number if there is one 
        % isEnd is used to segment it into different recording sections
            isEnd = true;
            sequence_num = obj.sequence;
            if sequence_num < 6 && sequence_num >= 0
                isEnd = false;
            end
        end

        function copy =  clone(obj)
            copy = KaggleDataCapsule();
        end

    end
end

