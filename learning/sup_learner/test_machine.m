load ionosphere
Ybool = strcmp(Y,'g');
hist(Ybool)
X = [X(:,3:end)];
X = X;
rng('default') % for reproducibility
c = SVM()
% b = BatchCVMachine();
% a = LassoLogisticMachine();

% c.init(b);
% b.set_sup_learner(a);
% a.onset_weights = 3;
c.train(X(1:200, :), Ybool(1:200));
[label, score]=c.infer(X(201:end, :));
ratio = sum(label == Ybool(201:end)) / length(Ybool(201:end))
figure
hist(score - Ybool(201:end));
