rng default
fs = 128;
f1 = 32;
f2 = 34;
t = 0:1/fs:2-1/fs;
um = 2*sin(2*pi*f1*t)+rand(size(t));
% plot(um)
un = sin(2*pi*f2*t);
% plot(un)
u3 = sin(2*pi*(f1)*t-pi/3)  ;
raw_feature = [ un; u3];

coh = EEGWindowBandCoherence();
coh.set_raw_feature(raw_feature, fs);

disp('target value !!!!!!!')
coh.mscoh_extract()

disp('my value')
coh.fast_extraction()
% coh.extract_feature()


% coh = TempEvoWindow();
% coh.set_raw_feature(raw_feature, fs);
% % disp('target value !!!!!!!')
% % coh.mscoh_extract()
% % disp('my value')
% % coh.fast_extraction()
% coh.extract_feature()
% coh.flattened_feature