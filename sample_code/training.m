myeegcode_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(myeegcode_dir)
InitEEGLab.init()

% cvbatch = BatchCVMachine();
% lasso_machine = LassoLogisticMachine();
% lasso_machine.onset_weights = 100;
% cvbatch.set_sup_learner(lasso_machine);
% 
% mm = MarkovMachine();
% mm.set_sup_learner(cvbatch);
c = EEGLearning();
c.load('CHB_MIT_06_Data_TempEvoEEGWindowBandWaveletEngergydb3')

sm = SVMLightMachine();
sam = SamplingMachine();
sam.init(sm);
% sm.init(mm);
% enm = AveEnsembleMachine();
% enm.init(ens2comAdpt, mm);



logging_dir = [myeegcode_dir, '/sample_code', '/chb06_log.txt'];
data_window = c.get_study_prototype().get_window_prototype();
c.set_logging_params(4, [data_window.toString(), ' chb06, leave_out_test, 01, 04, '], 2, 1, logging_dir );
% d.pca();
% c.k_means_fit(1);
% c.k_means(1);
c.set_sup_learner(sam);
% c.sup_learning(3)
testingimp = TestingImp();
testingAdpt = Testing2LearningAdpt();
testingAdpt.init(c);
testingimp.init(testingAdpt);
testingimp.start_evaluation();