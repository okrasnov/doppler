function [data, data_f, data_f_full, data_full, X, Theta, vel_axis_permitted, dv] = DS_simulatorV2B(SNR, m0, mu, sigma, n, v_amb, N)

%% N is the number of Doppler bins permitted for a specific rotation speed and radar beam width 

axis = linspace(-n/2, n/2, n+1)/n;
vel_axis = 2 * v_amb * axis;

% vel_axis = linspace(-v_amb, v_amb, n);
dv = vel_axis(2) - vel_axis(1);

% X_full = rand(1, n+1);
% Theta_full = 2 .* pi * rand(1, n+1);

if sigma < 0.02
    [~, idx1] = (min(abs(vel_axis - mu)));
    S_ = dirac(vel_axis - vel_axis(idx1)); 
    idx = S_ == Inf;
    S_(idx) = 1;
else
S_ = m0/sqrt(2*pi*sigma^2) * exp(-(vel_axis - mu).^2/(2*sigma^2));
end

Noise_full = sum(S_) ./ ((n + 1) .* SNR); % Noise Power

% P_full = -(S_ + Noise_full) .* log(X_full); % Power spectrum 
P_full = -(S_ + Noise_full); % .* log(X_full); % Power spectrum 
data_f_full = sqrt(P_full); % .* exp(1j .* Theta_full);
data_full = ifft(fftshift(sqrt(n) .* data_f_full));
% 
axis_permitted = linspace(-N/2, N/2, N+1)/N;
vel_axis_permitted = 2 * v_amb * axis_permitted;
% vel_axis_permitted = linspace(-v_amb, v_amb, N);

for i = 1:N+1
    [~, indices(i)] = min(abs(vel_axis - vel_axis_permitted(i)));
end

idx_for_integral = round(mean([indices(1:end-1); indices(2:end)]));

indx = [indices(1) idx_for_integral indices(end)];

for k = 1:N+1
    num = indx(k + 1) - indx(k) + 1;
    S(k) = sum(S_(indx(k):indx(k+1)) .* dv)/(num .* dv); 
%     S(k) = S_(indices(k));
end
% figure(300); hold on; plot(S);
% plot(vel_axis_permitted,  abs(S)); hold on; plot(vel_axis,  abs(S_));
% 
% plot(S_(indices)); hold on; plot(S_(idx_for_integral));


% n = length(S); % Length of number of frequencies

idx = linspace(1, n+1, n+1);
idxq = linspace(min(idx), max(idx), N+1);

X = rand(1, N+1);
Theta = 2 .* pi * rand(1, N+1);

% X = interp1(idx, X_full, idxq, 'linear');
% Theta = interp1(idx, Theta_full, idxq, 'linear');


Noise = sum(S) ./ ((N+1) .* SNR); % Noise Power

% P = -(S + Noise) .* log(X); % Power spectrum 
P = -(S + Noise) .* log(X); % Power spectrum 
data_f = sqrt(P) .* exp(1j .* Theta); % frequency domain

% figure(400); hold on; plot(abs(data_f).^2);

% figure(1); hold on; plot(vel_axis, sqrt(abs(P))); grid on;

data = ifft(ifftshift(sqrt(N+1) .* data_f));% complex time domain signal 
% data = ifft(fftshift(sqrt(P) .* exp(1j .* Theta)));% complex time domain signal 

% figure; plot(abs(data)); 

end