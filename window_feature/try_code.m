sig = sin(linspace(1, 3*2*pi , 256)) + sin(linspace(1, 20*2*pi , 256));

% low pass filter and downsampling
y  = resample(sig, 50, 256);

figure 
subplot(121)
plot(sig);
subplot(122)
plot(y)

% wavedec

% level = 3
% [lw, cutoff] = wavedec(y, 1, 'db4');
% cutoff = cumsum(cutoff);
level = 3;
[bands, energy] = find_all_subbands(y, level);
n = 2^level;
figure 
for i  = 1 : n
    index = 100 + n * 10 + i;
    subplot(index)
%     show_spectrum(bands(i, :), 25);
    % show_spectrum(lw(1: cutoff(1)), 25);
%     subplot(122)
%     show_spectrum(bands(2, :), 50);
end
energy