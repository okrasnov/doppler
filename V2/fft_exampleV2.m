%% FFT examples with Gaussian Pulse part 2
clear;
close all;
n = 1024;
N = 2;

v_amb = 7.5;
mu = 5;
sigma = 0.2;

[sig, sig_f, sig_f_full, sig_full] = DS_simulatorV2(10^(30/10), 1, mu, sigma, n, v_amb, N);


% figure; histogram(real(sig), 1000);
% figure; histogram((sig_f), 1000); 
% figure; histogram((sig_f).^2, 1000);


vel_axis_full = linspace(-v_amb, v_amb, n);
vel_axis = linspace(-v_amb, v_amb, N);


figure; plot(vel_axis_full, db((abs(sig_f_full).^2))/2); grid on;

phi = eps;

beta_wind = eps;

sig_a = abs(sig) .* exp(1j .* unwrap(angle(sig)) .* cos(beta_wind - phi));


sig_doppler = 1./sqrt(N) .* abs(fftshift(fft(sig_a, N)));


% sig_doppler_max = 1/N .* abs(fftshift(fft(sig, N))).^2;

figure; plot(vel_axis, db(abs(sig_doppler)), '-o'); hold on;  plot(vel_axis, db(abs(sig_f))); grid on; legend('with cosine', 'actual')


%% Interpolation of sig the time domain signal

idx = 1:N;
idxq = linspace(min(idx), max(idx), n);

sig_resamlpled = interp1(idx, sig, idxq, 'linear'); % resample the HR signal

figure; plot(real(sig_full), '-o'); hold on;  plot(real(sig_resamlpled)); grid on; legend('actual in time domain', 'resampled', 'resampled '); 
title('real part of signal')

sig_dop_resampled =  1./sqrt(n) .* abs(fftshift(fft(sig_resamlpled, n)));

figure; 
plot(vel_axis_full, db(abs(sig_f_full))); hold on; 
plot(vel_axis, db(abs(sig_f))); hold on;  
plot(vel_axis, db(abs(sig_doppler)), 'o'); hold on;
plot(vel_axis_full, db(abs(sig_dop_resampled)), '*'); hold on; 

grid on; legend('[sim] actual', '[sim] actual undersampled in freq domain', 'doppler with cosine undersampled', 'after resampled with cosine');
title(['At \Phi = ', num2str(phi * 180/pi), ' [deg]']);