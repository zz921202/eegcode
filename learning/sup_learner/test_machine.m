load ionosphere
Ybool = strcmp(Y,'g');
hist(Ybool)
X = [X(:,3:end)];
X = [X,X];
rng('default') % for reproducibility
c = QRSingularMatrixMachine()
b = BatchCVMachine();
a = LassoLogisticMachine();

c.init(b);
b.set_sup_learner(a);
a.onset_weights = 3;
c.train(X, Ybool);
[label, score]=c.infer(X);
ratio = sum(label == Ybool) / length(Ybool)
figure
hist(score - Ybool);
