classdef ExploreData < handle
% this designed to allow the basic exploration of a new dataset, in this particular case, we are tailoring specifically to the IntraData from Melbourne university
% it should contain basic functionalities such as the channel based signal plots, fft energy calculation of all frequency
    properties
        sections = []
        browser = EEGBrowse()
        cur_normal = 0
        cur_preictal = 0
    end

    methods
        function [] = read_data(obj, directory) % read all data from a directory say test_1
            % need to enumerate all files inside the directory
            file_listing = dir(directory);
            for file_ind = 1:length(file_listing)
                file = file_listing(file_ind);
                if file.bytes < 1000 || file.name(1) == '.'
                    disp(['empty file:', file.name])
                else
                    cur_section = KaggleDataCapsule();
                    disp(['loading file:', file.name]);
                    load([directory, '/', file.name]);
                    cur_section.read_data_structure(dataStruct, file.name);
                    obj.sections = [obj.sections, cur_section];
                end
            end
        end


        function section = next_preitcal(obj) % get the next ictal window's index, just update cur_normal
            for i = (obj.cur_preictal + 1) : length(obj.sections)
                cur_section = obj.sections(i);
                if cur_section.is_preictal
                    obj.cur_preictal = i;
                    section = cur_section;
                    return
                end
            end
            obj.cur_preictal = 0;
            section = obj.next_preitcal();
        end

        function section = next_normal(obj) % get the next normal window's index, just update cur_preictal
            for i = (obj.cur_normal + 1) : length(obj.sections)
                cur_section = obj.sections(i);
                if ~cur_section.is_preictal
                    obj.cur_normal = i;
                    section = cur_section;
                    return
                end
            end
            obj.cur_normal = 0;
            section = obj.next_normal();
        end

        function show_next_preitcal(obj) % use whatever Browse Command to show them
            section = obj.next_preitcal();
            obj.browser.show(section);
        end

        function show_next_normal(obj) % use whatever Browse Command to show them
            section = obj.next_normal();
            obj.browser.show(section);
        end



        
    end
end