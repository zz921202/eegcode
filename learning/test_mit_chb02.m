myeegcode_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(myeegcode_dir)
file_dir = [myeegcode_dir, '/processed_data/CHB_MIT_02_Data'];
InitEEGLab.init()
%WARNING: do not use 01 - 04
all_files = {'16', '19'}%'14', '15','16', '17', '18','19', '20',  '21', '22', '23', '24'} %'07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27'}
% all_files = {'02'}; '12','13','14','15',
seizure_time_file = [16, 161, 19]

seizure_times = {[130, 212],
                [2972, 3053], 
                [3369, 3378]};
% matlabpool open
for ind = 1: length(all_files)

    filenum = all_files{ind};

    if ismember(str2num(filenum),seizure_time_file)
        seizure_time = seizure_times{find(str2num(filenum) == seizure_time_file), :};
    else
        seizure_time = [0, 0];
    end

    filename = [file_dir, '/chb02_', filenum, '_raw.set'];
    disp(['.......processing.......' filename]);
    mit = EEGStudyInterface();
    mit.classifier_label_imp = IctalInterictalLabel();

    mit.import_data(filename, filenum, seizure_time);
%     mit.set_window_params(2, 1, 'EEGWindowBandCoherence');
    mit.set_window_params(2, 1, 'EEGCompositeWindow');
%     mit.plot_temporal_evolution();
%     mit
    dstudy(ind) = mit;
end

composite_eg = mit.data_windows(1);
ens2comAdpt = Ensemble2CompositeAdapter();
ens2comAdpt.init(composite_eg);

cvlog = CVMachine();
logmachine = LogisticRegMachine();
logmachine.onset_weights = 10;
cvlog.set_sup_learner(LogisticRegMachine());

% lasso_machine = LassoLogisticMachine();
% logmachine.onset_weights = 20;

mm = MarkovMachine();
mm.set_sup_learner(cvlog);


enm = AveEnsembleMachine();
enm.init(ens2comAdpt, mm);



c = EEGLearning();
c.init(dstudy);
c.set_logging_params(4, 'AveEnsembleMachine(cv(garderner-3hz-bandamp)), chb02, leave_out_test, 14:24, onset_weight, 100 ', 2, 1, 'chb02_log.txt' );
c.pca();
% c.k_means_fit(1);
% c.k_means(1);
c.set_sup_learner(enm);

testingimp = TestingImp();
testingAdpt = Testing2LearningAdpt();
testingAdpt.init(c);
testingimp.init(testingAdpt);
testingimp.start_evaluation();
% d.test_sup_learner(1:3);