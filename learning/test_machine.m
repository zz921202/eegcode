load ionosphere
Ybool = strcmp(Y,'g');
X = X(:,3:end);

rng('default') % for reproducibility

a = LassoLogisticMachine()
a.onset_weights = 3;
a.train(X, Ybool)
a.infer(X)