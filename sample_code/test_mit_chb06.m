myeegcode_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(myeegcode_dir)
file_dir = [myeegcode_dir, '/processed_data/CHB_MIT_06_Data'];
InitEEGLab.init()

%WARNING: do not use 01 - 04
all_files = { '01', '04'}%, '02', '04','05'}%, '20',  '21', '22', '23', '24'} %'07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27'}
% all_files = {'02'}; '12','13','14','15',
seizure_time_file = [1, 4, 9, 10, 13, 18, 24]

seizure_times = {[1724, 1738; 7461, 7476; 13525, 13540;],
                [327, 347; 6211, 6231], 
                [12500, 12516],
                [10833, 10845],
                [506, 519],
                [7799, 7811],
                [9387, 9403]};


% matlabpool open
for ind = 1: length(all_files)

    filenum = all_files{ind};

    if ismember(str2num(filenum),seizure_time_file)
        seizure_time = seizure_times{find(str2num(filenum) == seizure_time_file), :};
    else
        seizure_time = [0, 0];
    end

    filename = [file_dir, '/chb06_', filenum, '_raw.set'];
    disp(['.......processing.......' filename]);
    mit = EEGStudyInterface();
    mit.classifier_label_imp = IctalInterictalLabel();

    mit.import_data(filename, filenum, seizure_time);
    mit.set_window_params(6, 1, 'TempEvoWindow');
%     mit.set_window_params(2, 1, 'EEGWindowBandAmplitude');
%     mit.plot_temporal_evolution();
%     mit
    dstudy(ind) = mit;
end

d = EEGLearning();
% d.init(dstudy);
% d.load('CHB_MIT_06_Data_EEGWindowBandCoherence');
d.save();

mit = d.get_study_prototype();
composite_eg = mit.get_window_prototype();
ens2comAdpt = Ensemble2CompositeAdapter();
ens2comAdpt.init(composite_eg);

% cvlog = CVMachine();
% logmachine = LogisticRegMachine();
% logmachine.onset_weights = 50; 
% cvlog.set_sup_learner(logmachine);

cvbatch = BatchCVMachine();
lasso_machine = LassoLogisticMachine();
lasso_machine.onset_weights = 500;
cvbatch.set_sup_learner(lasso_machine);

mm = MarkovMachine();
mm.set_sup_learner(cvbatch);



% enm = AveEnsembleMachine();
% enm.init(ens2comAdpt, mm);




logging_dir = [myeegcode_dir, '/sample_code', '/chb06_log.txt'];

d.set_logging_params(4, [composite_eg.toString(),', chb06, leave_out_test, 01, 04, onset_weight, 500 '], 2, 1, logging_dir );
d.pca();
% c.k_means_fit(1);
% c.k_means(1);
d.set_sup_learner(mm);

testingimp = TestingImp();
testingAdpt = Testing2LearningAdpt();
testingAdpt.init(d);
testingimp.init(testingAdpt);
testingimp.start_evaluation();
% d.test_sup_learner(1:3);