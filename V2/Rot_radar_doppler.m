clear;
close all;

%% Configuration 0 is off, 1 in on

% Want to run Monte Carlo simulation to see errors?
MC_enable = 1;

if MC_enable == 1
    n_MC = 128; 
else
    n_MC = 1;
end

% Want to run errors for different SNRs? 
SNR_enable = 1;

if SNR_enable == 1
    SNR_i_db = -30; SNR_i = 10^(SNR_i_db/20);
    SNR_f_db = 30; SNR_f = 10^(SNR_f_db/20);
    n_SNR = 100; % Number of points wanted in the SNR axis
    SNR = linspace(SNR_i, SNR_f, n_SNR);
else
    n_SNR = 1;
    SNR_db = Inf;
    SNR = 10^(SNR_db/20);
end



%% RADAR constants and wind direction

beta_wind = eps;
mu = 5;
sigma = 0.2;



PRT = 1e-3;
lambda = 3e-2;
n = 2^12;

v_amb = lambda/(4*PRT);% Doppler ambiguity limits in velocity

for l = 1:n_MC
    for s = 1:n_SNR
        [data_(l, s, :), data_f_(l, s, :)] = DS_simulator(SNR(s), mu, sigma, n, v_amb); % One time simulation of the spectrum and the signal with fine sampling
    end
end

data = squeeze(mean(data_, 1));
data_f = squeeze(mean(data_f_, 1));

% n_ = 4;
% vel_ = linspace(-v_amb, v_amb, n);
% vel__ = linspace(-v_amb, v_amb, n_);
% 
% figure; plot(vel_, abs(data_f)); hold on; plot(vel__, 1/sqrt(n) .* abs(fftshift(fft(data, n_))));

%% 

BW_deg = 1;

Phi_0_deg = 0;
Phi_end_deg = 360;

BW = BW_deg*pi/180; % Beam width in radians
phi_0 = Phi_0_deg * pi/180; % Start of azimuth angle
phi_end = Phi_end_deg * pi/180; % End of azimuth angle

Phi = phi_0:BW:phi_end;

mean_Phi = mean([Phi(1:end-1); Phi(2:end)]); % This is done to take the mid angles of all possible angular resolution cell

Omega_rpm = linspace(1, 60, 4); % RPM axis for the rotation of the radar
% Omega_rpm = 160;
% Omega_rpm = 60;

%% resampling based on the rotation of the radar

for s = 1:n_SNR
    
    for i = 1:length(Omega_rpm)

        Omega = Omega_rpm(i) .* 2 * pi ./ 60;

        T = BW/Omega;

        time_axis(i).axis = eps:PRT:T;

        hits_scan_(i) = length(time_axis(i).axis); % length of time axis
        hits_scan(i) = 2^(nextpow2(hits_scan_(i)) - 1); % hits scan for Doppler processing
        vel_axis(i).axis = linspace(-v_amb, v_amb, hits_scan(i));
        delta_v(i) = lambda/(2*hits_scan(i)*PRT);

        for k = 1:length(mean_Phi)
    %        beta(k) = beta_wind - mean_Phi(k);
            beta(k) = eps;
            Signal(i).sig(s, k, :) = abs(data(s, :)) .* exp(1j .* unwrap(angle(data(s, :))) .* cos(beta(k)));
            Signal(i).doppler(s, k, :) = 1./sqrt(hits_scan(i)) .* fftshift(fft(Signal(i).sig(s, k, :), hits_scan(i)));

            PT_integrand = abs(squeeze(Signal(i).doppler(s, k, :))).^2 .* delta_v(i);
            PT = sum(PT_integrand); % Total power of the Doppler Spectrum

            v_mean_integrand = vel_axis(i).axis.' .* abs(squeeze(Signal(i).doppler(s, k, :))).^2 .* delta_v(i);
            v_mean(s, i, k) = sum(v_mean_integrand) ./ PT; % Mean Doppler velocity 

            v_spread_integrand = (vel_axis(i).axis.' - v_mean(s, i, k)).^2 .* abs(squeeze(Signal(i).doppler(s, k, :))).^2 .* delta_v(i);
            v_spread(s, i, k) = sqrt(sum(v_spread_integrand)./ PT); % Doppler spectrum width
        end

%         figure; surface(vel_axis(i).axis, mean_Phi * 180/pi, abs(squeeze(Signal(i).doppler(s, :, :)))); shading flat; colorbar; %colormap('jet'); 
%         ylabel('Azimuth Angle \Phi [deg]', 'FontSize', 16);
%         xlabel('Velocity axis [m/s]', 'FontSize', 16)
%         zlabel('Normalized Doppler spectrum', 'FontSize', 16);
%         title(['Normalized Doppler spectrum at ', num2str(Omega_rpm(i)), 'RPM', ', SNR = ', num2str(SNR_db), ' dB'], 'FontSize', 16);
    end
    
end

%% Configuration for Plots

DS_Azimuth_plots = 0;

if DS_Azimuth_plots

   
    
    SI = 100;  % Index in SNR 
    OI = 1;    % INdex in Omega
    
    Plot2DDoppler(vel_axis(OI).axis, mean_Phi, Signal, SNR_interest, Omega_interest);
    
end



%% Plot Doppler spectrum (Azimuth vs Doppler Velocity)



figure; surface(Omega_rpm, mean_Phi .* 180/pi, v_mean.'); shading flat; colorbar;colormap('jet') % Plot the error in mean Doppler

ylabel('Azimuth Angle \Phi [deg]', 'FontSize', 16);
xlabel('Angular speed of radar beam in azimuth [rpm]', 'FontSize', 16)
zlabel('Error in Mean Doppler velocity [m/s]', 'FontSize', 16);

figure; surface(Omega_rpm, mean_Phi .* 180/pi, v_spread.'); shading flat; colorbar; colormap('jet'); % Plot the mean Doppler

ylabel('Azimuth Angle \Phi [deg]', 'FontSize', 16);
xlabel('Angular speed of radar beam in azimuth [rpm]', 'FontSize', 16)
zlabel('Mean Doppler velocity [m/s]', 'FontSize', 16);

