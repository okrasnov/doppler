%% Input to the simulator 
clear all;
% close all;

Omega_rpm = linspace(1, 60, 120);
SNR_db = Inf;
BW_deg = 1; 

Phi_0_deg = 0;
Phi_end_deg = 360;

beta_wind = eps;
PRT = 1e-3;
lambda = 3e-2;

mu = 2;
sigma = 0.9;


BW = BW_deg*pi/180; % Beam width in radians
phi_0 = Phi_0_deg * pi/180; % Start of azimuth angle
phi_end = Phi_end_deg * pi/180; % End of azimuth angle

Phi = phi_0:BW:phi_end;

mean_Phi = mean([Phi(1:end-1); Phi(2:end)]); % This is done to take the mid angles of all possible angular resolution cell


N_iteration = 256;

for i = 1:length(Omega_rpm)
    for k = 1:length(mean_Phi)
    
        for l = 1:N_iteration

            [Signal(i).sig(l, k, :), Signal(i).sig_doppler(l, k, :), Signal(i).sig_with_Omega(l, k, :), hits_scan(i), delta_v(i), vel_axis(i).axis, time_axis(i).axis] ...
                = Simulator_with_rot(Omega_rpm(i), BW, SNR_db, mean_Phi(k), beta_wind, PRT, lambda, mu, sigma);

            Signal(i).doppler(l, k, :) = 1./sqrt(hits_scan(i)) .* (fftshift(fft(squeeze(Signal(i).sig_with_Omega(l, k, :))))); % Find the Doppler of the signal of the rotating radar

            PT_integrand = abs(squeeze(Signal(i).doppler(l, k, :))).^2 .* delta_v(i);
            PT = sum(PT_integrand); % Total power of the Doppler Spectrum

            v_mean_integrand = vel_axis(i).axis.' .* abs(squeeze(Signal(i).doppler(l, k, :)) ./cos(beta_wind - mean_Phi(k))).^2 .* delta_v(i);
            v_mean(i, l, k) = sum(v_mean_integrand) ./ PT; % Mean Doppler velocity 

            v_spread_integrand = (vel_axis(i).axis.' - v_mean(i, l)).^2 .* abs(squeeze(Signal(i).doppler(l, k, :))).^2 .* delta_v(i);
            v_spread(i, l, k) = sqrt(sum(v_spread_integrand)./ PT); % Doppler spectrum width
            
        end
        v_mean_error(i, k) = sqrt(sum((squeeze(v_mean(i, :, k)) - mu).^2)/N_iteration);
    end
end

figure; surface(Omega_rpm, mean_Phi, v_mean_error.'); shading flat; colorbar; colormap('jet');
