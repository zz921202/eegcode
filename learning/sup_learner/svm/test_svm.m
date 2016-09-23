load ionosphere
Ybool = strcmp(Y,'g');
hist(Ybool)
X = [X(:,3:end)];
label = (Ybool*2) -1; 

training_dataset = [label, X];
test_dataset = [zeros(length(label), 1), X];

% result = svmlight(training_dataset, test_dataset);
% result1 = svmlight(training_dataset, test_dataset);

train_name = 'testing_train';
model_name = '_svm_2016-09-08_-00:13_37N';
test_name = 'testing_test';

svmlight_train(training_dataset, '-c 100 -t 2 -g 1 ', train_name, model_name);
score = svmlight_infer(test_dataset, model_name, test_name);

% a.onset_weights = 3;
% c.train(X, Ybool);
% [label, score]=c.infer(X); d
% ratio = sum(result == label) / length(label)
figure
scatter(score, label);
