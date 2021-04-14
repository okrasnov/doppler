clear;
close all;
% x = sin(2*pi*fc*t);

% N = linspace(2, 10, 9);

% fc = 1e3/3;



% mu = fc;
% sigma = 40/3;
% 
% SNR_db = Inf;
% SNR = 10^(SNR_db/20);
% 
% 
% f_true_axis = linspace(-fmax, fmax, N_true);
% 
% Px = 10^3/sqrt(2*pi*sigma^2) * exp(-(f_true_axis - mu).^2/(2*sigma^2));
% xf = sqrt(Px);
% 
% 
% 
% figure; plot(f_true_axis, abs(xf).^2/N_true);

fc = 10e9;

t = linspace(eps, 1/fc, 256);

delt = abs(t(2) - t(1));

fmax = 1./(2 .* delt);

x = exp(1j .* 2 * pi * fc * t);

plot(t, abs(x));

N = 1024;

for i = 1:length(N)

n = N(i);

y = fft(x, n);
y_ = fftshift(fft(x, n));

y_useful = abs(y(1:round(n/2)+1)).^2/n;
y_all = abs(y_).^2/n;

% delf = 1/(4 * T);

f_useful = linspace(eps, fmax, round(n/2)+1);
delf_useful = abs(f_useful(2) - f_useful(1));


f = linspace(-fmax, fmax, n);
delf = abs(f(2) - f(1));

P_useful = abs(y_useful).^2 .* delf_useful;
PTu = sum(P_useful); % Total power of the Doppler Spectrum

MU_useful = f_useful .* abs(y_useful).^2 .* delf_useful;
MUu(i) = sum(MU_useful) ./ PTu; % Mean Doppler velocity 

P = abs(y_).^2 .* delf;
PT = sum(P); % Total power of the Doppler Spectrum

MU = f .* abs(y_).^2 .* delf;
MUall(i) = sum(MU) ./ PT; % Mean Doppler velocity 

% figure; plot(t, x);
figure(2); hold on; plot(f_useful*1e-9, y_useful);
figure(3); hold on; plot(f*1e-9, y_all);
figure(4); hold on; plot(f*1e-9, abs(y).^2/n);

end






%% FFT examples with Gaussian Pulse
close all;
n = 512;
[sig, sig_f] = DS_simulator(10^(Inf/20), 1, 5, 0.2, n, 7.5);

phi = pi;

beta_wind = eps;

sig_a = abs(sig) .* exp(1j .* unwrap(angle(sig)) .* cos(beta_wind - phi));

% figure; plot(abs(sig_a)); % hold on; plot(abs(sig), '*');
% figure; plot(abs(sig_f).^2);

N = 4;

idx = 1:n;
idxq = linspace(min(idx), max(idx), N);
sig_sampled = interp1(idx, sig_a, idxq, 'nearest');

figure; plot(1:1:n, abs(sig_a)); hold on; plot(1:n/N:n, abs(sig_sampled), '*');


sig_doppler = 1/N .* abs(fftshift(fft(sig_sampled, N))).^2;
% sig_doppler_max = 1/N .* abs(fftshift(fft(sig, N))).^2;

figure; plot(abs(sig_doppler)); % hold on;  plot(abs(sig_doppler_max));










