addpath(genpath('./HMMall'))


O = 3;
Q = 2;

% "true" parameters
prior0 = normalise(rand(Q,1));
transmat0 = mk_stochastic([0.05 0.95; 0.95, 0.05]);
obsmat0 = mk_stochastic([0.9, 0.05, 0.05; 0.05, 0.8, 0.15]);

% training data
T = 200;
nex = 5;
data = dhmm_sample(prior0, transmat0, obsmat0, T, nex);

% initial guess of parameters

% improve guess of parameters using EM
figure()
rep = 10;
err = zeros(1,rep);
ll = zeros(1,rep);
hold on
for i = 1:rep
    prior1 = normalise(rand(Q,1));
    transmat1 = mk_stochastic(rand(Q,Q));
    obsmat1 = mk_stochastic(rand(Q,O));

    [LL, prior2, transmat2, obsmat2] = dhmm_em(data, prior1, transmat1, obsmat1, 'max_iter', 20);
    err(i) = norm(transmat2- transmat0);
    plot(LL);
    ll(i) = LL(end);
end
hold off
figure()
subplot(121)
plot(log(err));
ylabel('l2 error')
subplot(122)
plot(ll);
line([1, rep], [max(ll), max(ll)], 'color', 'red');
xx = find(ll == max(ll));
line([xx, xx], get(gca, 'ylim'), 'color', 'blue');
% use model to compute log likelihood
loglik = dhmm_logprob(data, prior2, transmat2, obsmat2)

% log lik is slightly different than LL(end), since it is computed after the final M step
