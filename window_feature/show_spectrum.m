function show_spectrum(cur_data, Fs)   
    
    
    L = size(cur_data, 2);
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    Y = fft(cur_data,NFFT, 2)/L;

    freq = Fs/2*linspace(0,1,NFFT/2+1);

    plot(freq,2*abs(Y(:,1:NFFT/2+1)).^2);

    title(['Single-Sided Amplitude Spectrum of y(t) at '])
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')
    ylim([0, 1])
end