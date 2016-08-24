load ionosphere
Ybool = strcmp(Y,'g');
hist(Ybool)
X = X(:,3:end);

rng('default') % for reproducibility
b = BatchCVMachine();
a = LassoLogisticMachine();
b.set_sup_learner(a);
a.onset_weights = 3;
b.train(X, Ybool);
[label, score]=b.infer(X);
ratio = sum(label == Ybool) / length(Ybool)
figure
hist(score - Ybool);
