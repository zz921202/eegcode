par_dirname = fileparts(fileparts(mfilename('fullpath')));
addpath(par_dirname)
InitEEGLab.init()


%% load MIT data



all_files = { '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27'...
        '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38' }
for ind = 1:length(all_files)
    file = all_files{ind}
    cur_name = ['chb03_' file]
    file_name = ['/' cur_name '.edf']
    c = EEGDataMIT()
    file_dir = ['/Users/Zhe/chb03', file_name]
    c.set_name(cur_name, 'CHB_MIT_03')  % target directory name
    c.load_raw(file_dir)
end


%% load emotiv raw data

% c = EEGDataInterface()
% c.set_name('Vidya_june_3_1','Vidya_june_3_1')
% c.load_raw('/Users/Zhe/Documents/seizure/myeegcode/raw_data/1/2016-06-03_14:45:57.762702-epoc-recording.dat')

%% eyeballing emotiv raw


% c = EEGDataInterface();
% c.set_name('short','Juarez');
% contact_file = '/Users/Zhe/Documents/seizure/myeegcode/raw_data/Juarex_July_15/Juarez_short.txt';
% c.faster_load_raw(contact_file);

%% load Vidya data

% change contact to reading to laod reading files


% all_files = {
%             '1610_contact.txt'
%             '1611_contact.txt'
%             '1626_contact.txt'
%             '1630_contact.txt'
%             '1636_contact.txt'
%             '1637_contact.txt'
%             '1639_contact.txt'
%             '1645_contact.txt'
%             }

% c = EEGDataInterface();
% for ind = 1: length(all_files)
%     cur_name = all_files{ind};
%     short_name = cur_name(1:4);

%     c.set_name(short_name,'Vidya_june_6_contact');
%     contact_file = ['/Users/Zhe/Documents/seizure/myeegcode/raw_data/Vidya_june_6/', cur_name];
%     c.load_raw(contact_file);
% end

