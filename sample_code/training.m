cvbatch = BatchCVMachine();
lasso_machine = LassoLogisticMachine();
lasso_machine.onset_weights = 100;
cvbatch.set_sup_learner(lasso_machine);

mm = MarkovMachine();
mm.set_sup_learner(cvbatch);


sm = SVDSingularMatrixMachine();
sm.init(mm);
% enm = AveEnsembleMachine();
% enm.init(ens2comAdpt, mm);




logging_dir = [myeegcode_dir, '/sample_code', '/chb06_log.txt'];

d.set_logging_params(4, [composite_eg.toString(),', chb06, leave_out_test, 01, 04, onset_weight, 100 '], 2, 1, logging_dir );
% d.pca();
% c.k_means_fit(1);
% c.k_means(1);
d.set_sup_learner(sm);

testingimp = TestingImp();
testingAdpt = Testing2LearningAdpt();
testingAdpt.init(d);
testingimp.init(testingAdpt);
testingimp.start_evaluation();