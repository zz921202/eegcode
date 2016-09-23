myeegcode_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(myeegcode_dir)
InitEEGLab.init()

d = EEGLearning();
% d.init(dstudy);
d.load('CHB_MIT_01_Data_Composite__EEGWindow3Hz_EEGWindowBandCoherence_EEGWindowBandAmplitude');
% d.save();

mit = d.get_study_prototype();
composite_eg = mit.get_window_prototype();
ens2comAdpt = Ensemble2CompositeAdapter();
ens2comAdpt.init(composite_eg);

% cvlog = CVMachine();
% logmachine = LogisticRegMachine();
% logmachine.onset_weights = 50; 
% cvlog.set_sup_learner(logmachine);

% cvbatch = BatchCVMachine();
% lasso_machine = LassoLogisticMachine();
% lasso_machine.onset_weights = 500;
% cvbatch.set_sup_learner(lasso_machine);

% mm = MarkovMachine();
% mm.set_sup_learner(cvbatch);

svm = SVMLightMachine();

enm = AveEnsembleMachine();
enm.init(ens2comAdpt, svm);




logging_dir = [myeegcode_dir, '/sample_code', '/chb01_log.txt'];

d.set_logging_params(4, [composite_eg.toString(),', chb01, leave_out_test, 01, 04, '], 2, 1, logging_dir );
d.pca();
% c.k_means_fit(1);
% c.k_means(1);
d.set_sup_learner(enm);

testingimp = TestingImp();
testingAdpt = Testing2LearningAdpt();
testingAdpt.init(d);
testingimp.init(testingAdpt);
testingimp.start_evaluation();