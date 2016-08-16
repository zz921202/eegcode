rng default
fs = 512;
f1 = 35;
f2 = 31;
t = 0:1/fs:2-1/fs;
um = sin(2*pi*f1*t)+rand(size(t));
un = sin(2*pi*f2*t-pi/3)+rand(size(t));
u3 = sin(2*pi*(f2+2)*t-pi/3)+rand(size(t));
raw_feature = [um; un; u3];

% coh = EEGCompositeWindow();
% coh.set_raw_feature(raw_feature, fs);
% disp('target value !!!!!!!')
% coh.mscoh_extract()
% disp('my value')
% coh.fast_extraction()
% coh.extract_feature()


coh = TempEvoWindow();
coh.set_raw_feature(raw_feature, fs);
% disp('target value !!!!!!!')
% coh.mscoh_extract()
% disp('my value')
% coh.fast_extraction()
coh.extract_feature()
coh.flattened_feature