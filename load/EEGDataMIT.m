classdef EEGDataMIT < EEGDataInterface
% special read in file for MIT_CHB data set
    properties
        data_dir
        data_file
    end

    methods
        
        function obj = EEGDataMIT(obj) 
            obj.sampling_rate = 256; 
        end


        function obj = load_raw(obj, file_dir)
            par_dir = fileparts(file_dir); 
            channel_file = [ par_dir  '/channel_info.ced']
            disp(['........reading form', file_dir, '.........'])
            [hdr, record] = edfread(file_dir);
            load([ par_dir, '/channel_reverse_info.mat']);
            channel_m = channel_inv * record;
            % channel_m = channel_m(:, 1:256);

            obj.curEEG = LoadEEGDataMatlab(channel_m, obj.dataset_name, channel_file, 256, obj.data_path, 'MIT');
            obj = obj.extract_EEG_data();
        end

    end
end