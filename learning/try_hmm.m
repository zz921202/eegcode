% Example of fixed lag smoothing

% rand('state', 1);
S = 2;
O = 2;
T = 1000;
% data = sample_discrete([0.5 0.5], 1, T);
transmat = mk_stochastic([0.995 0.005; 0.1 0.9]);
obsmat = mk_stochastic([0.9 0.1; 0.2  0.8]); % say we are the oracle

data = hmmgenerate(T ,transmat, obsmat);

obslik = multinomial_prob(data, obsmat); % inverse probaility
prior = [0.5 0.5]';

figure
subplot(131)
[alpha0,beta, gamma, loglik, xi, gamma2] = fwdback(prior, transmat, obslik);
% plot(alpha0');
plot(gamma');
ylim([-1, 2])
subplot(132)
title('truth');
plot(data);
ylim([0, 3])

%% fixed smoothing
subplot(133)
title('fixed smoothing')

w = 3;
alpha1 = zeros(S, T);
gamma1 = zeros(S, T);
xi1 = zeros(S, S, T-1);
t = 1;
b = obsmat(:, data(t));
olik_win = b; % window of conditional observation likelihoods
alpha_win = normalise(prior .* b);
alpha1(:,t) = alpha_win;
for t=2:T
  [alpha_win, olik_win, gamma_win, xi_win] = ...
      fixed_lag_smoother(w, alpha_win, olik_win, obslik(:, t), transmat);
  alpha1(:,max(1,t-w+1):t) = alpha_win;
  gamma1(:,max(1,t-w+1):t) = gamma_win;
  xi1(:,:,max(1,t-w+1):t-1) = xi_win;
end
plot(gamma1');
ylim([-1, 2])

%% generate transition matrix
% [dirichletPriorWeight, other] = process_options(...
%     [], 'dirichletPriorWeight', 0);
% [transmat, initState] = transmat_train_observed(data, 2, ...
% 						'dirichletPriorWeight', dirichletPriorWeight);
% transmat