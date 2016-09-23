myeegcode_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(myeegcode_dir)
InitEEGLab.init()

% tmp_folder = [myeegcode_dir, '/tmp/mit'];


% all_files = {'01', '02', '03', '04'}%,'21' , '16', '18', '21',  '13','26','15' , '46', '10', '11'};

% for file_ind  = 1
%     load([tmp_folder all_files{file_ind}]);
%     studys(file_ind) = mit
% end
% c = EEGLearning();
% c.set_study(studys);
% c.sup_learning('SVM',[1]);
% c.test_sup_learner([3,4]);


file_dir = [myeegcode_dir, '/processed_data/CHB_MIT_01_Data'];

all_files = {'01', '02', '03','04', '05', '06',  '07', '08','09','15', '16', '17', '18', '19', '20'}%, '09', '10', '11', '12', '13', '14',  '19', '20', '21', '22', '23', '24', '25',  '26', '27'}
% all_files = { '02', '03', '04', '05', '06', '15', '16'};
all_files = {'03', '04'}
seizure_time_file = [3, 4, 15, 16, 18, 21, 26];

seizure_times = {[2996, 3036],
                [1467, 1494], 
                [1732, 1772],
                [1015, 1066],
                [1720, 1810],
                [327, 420],
                [1862, 1963]};
% matlabpool open
for ind = 1: length(all_files)

    filenum = all_files{ind};

    if ismember(str2num(filenum),seizure_time_file)
        seizure_time = seizure_times{find(str2num(filenum) == seizure_time_file), :};
    else
        seizure_time = [0, 0];
    end

    filename = [file_dir, '/chb01_', filenum, '_raw.set'];
    disp(['.......processing.......' filename]);
    mit = EEGStudyInterface();
    mit.classifier_label_imp = IctalInterictalLabel();

    mit.import_data(filename, filenum, seizure_time);
    mit.set_window_params(6, 1, 'TempEvoWindow');
%     mit.set_window_params(2, 1, 'EEGCompositeWindow');
%     mit.plot_temporal_evolution();
%     mit
    studys(ind) = mit;
end
% matlabpool close 
c = EEGLearning();
c.init(studys);
c.save()

composite_eg = mit.get_window_prototype();
ens2comAdpt = Ensemble2CompositeAdapter();
ens2comAdpt.init(composite_eg);

% cvlog = CVMachine();
% logmachine = LogisticRegMachine();
% logmachine.onset_weights = 50; 
% cvlog.set_sup_learner(logmachine);

cvbatch = BatchCVMachine();
lasso_machine = LassoLogisticMachine();
lasso_machine.onset_weights = 50;
cvbatch.set_sup_learner(lasso_machine);

mm = MarkovMachine();
mm.set_sup_learner(cvbatch);


enm = AveEnsembleMachine();
enm.init(ens2comAdpt, mm);

sm = QRSingularMatrixMachine();
sm.init(mm);




logging_dir = [myeegcode_dir, '/sample_code', '/chb01_log.txt'];
c.set_logging_params(4, 'AveEnsembleMachine(cv(garderner-3hz-bandamp)), chb01, leave_out_test, (1:8, 15:20), onset_weights, 100', 2, 1,  logging_dir);
c.pca();
% c.k_means_fit(1);
% c.k_means(1);
c.set_sup_learner(sm);

testingimp = TestingImp();
testingAdpt = Testing2LearningAdpt();
testingAdpt.init(c);
testingimp.init(testingAdpt);
testingimp.start_evaluation();

% c.sup_learning(1);
% c.test_sup_learner(1);
% c.test_sup_learner(5:8);