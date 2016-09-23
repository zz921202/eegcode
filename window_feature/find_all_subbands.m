function  [bands, energies] = find_all_subband_energy(x, depth, wavelet)
    % returns a matrix where each row is the wavelet decomposed signal for each band
    % notice taht energy would be a column vector
    if nargin < 3
        disp('hello default to db4')
        wavelet = 'db4';
    end

    if depth == 0
        bands = x;
        energies = log(sum(x.^2)); % using log energy
        return
    else
        [wave, cutoff] = wavedec(x, 1, wavelet);
        cutoff = cumsum(cutoff);
        lw = wave(1: cutoff(1));
        hw = wave(cutoff(1) + 1 : cutoff(2));
        [band_left, en_l] = find_all_subbands(lw, depth - 1, wavelet);
        [band_rgiht, en_r] = find_all_subbands(hw, depth - 1, wavelet);
        bands = [band_left; band_rgiht];
        energies = [en_l; en_r];
    end