clear;
close all;

%% Ground Truth 


beta_wind = eps; % wind direction
m0 = 1; % Amplitiude
mu = 4; % Mean velocity
sigma = 0.2; % Standard deviation of wind velocity

%% Radar variables 


SNR_db = 30;
SNR = 10^(SNR_db/10);
BW_deg = 1.8;
PRT = 1e-3;
lambda = 3e-2;
v_amb = lambda/(4*PRT);% Doppler ambiguity limits in velocity


%% Radar rotation and Azimuth angle axes

% Omega_rpm = linspace(1, 60, 4); % RPM axis for the rotation of the radar

Omega_rpm = 1; % use this when only one rotation speed is needed 
BW = 1.8*pi/180;


%% Data creation and processing


for i = 1:length(Omega_rpm) % Loop over each angular velocity of the radar
       
    
    
     Omega = Omega_rpm(i) .* 2 * pi ./ 60; % Angular speed in [radians/sec]

     T = BW/Omega; % Dwell time (Time for the radar beam to stay at one azimuth angle cell (beamwidth))
 

     time_axis = 0:PRT:T; % Time axis for one beamwidth 
            

     hits_scan(i) = length(time_axis); % length of time axis for one beam width (also known as hits per scan)
            
     Phi_0 = 0*pi/180;
     Phi_end = 360*pi/180;
     
     T_full = (Phi_end - Phi_0)/Omega;
     
     N(i) = round(T_full/PRT); 
    
     time_axis_full = linspace(eps, N(i)*PRT, N(i));
    
     Phi = linspace(Phi_0, Phi_end, hits_scan(i));
     mean_Phi = mean([Phi(1:end - 1); Phi(2:end)]);
     
     
     
     phi_axis = linspace(Phi_0, Phi_end, N(i)); % phi_axis = phi_axis(1:end-1);
%      phi_axis = 60 .* pi/180;
     
%    mu_phi = mu .* cos(beta_wind - phi_axis);
            
%% This if clause is only to decide the number of points required for Doppler processing for every azimuthal angle
     if hits_scan(i) < 0 % (Make it 0 if no zero padding is required)
         hits_scan_1(i) = 64 + 1; % For Doppler processing when hits per scan is too small [zero padding purposes]
     else
         hits_scan_1(i) = hits_scan(i); 
     end
     
     [data(i).data, data(i).data_f, ~, ~] = ...
              DS_simulatorV3(SNR, m0, mu, sigma, N(i), v_amb); % Generation of HD signal in time domain
     % (i -> for each rotation speed, m -> For different BW, l ->
     % Monte Carlo axis, s -> SNR axis, k -> For each azimuth angle) 
  
     Signal(i).sig_full = hamming(1, length(data(i).data)) .* exp(1j .* 4 .* pi./lambda .* mu .* time_axis_full) ...
         .* exp(1j .* ( 4*pi/lambda * mu .* (cos(beta_wind - phi_axis) - 1)) .* time_axis_full);
         
     vel_axis = linspace(-v_amb, v_amb, hits_scan_1(i)); % velocity axis to show the Doppler spectrum and calculate the moments
            
     delta_v = lambda/(2*hits_scan_1(i)*PRT); % velocity resolution 

     
     
            
end

% 
% for i = 1:length(Omega_rpm)
%     for k = 1:length(mean_Phi)
%         Signal(i).sig(k, :) = abs(data(i).data((k - 1)*hits_scan(i)+1:k*hits_scan(i)))...
%             .* exp(1j .* unwrap(angle(data(i).data((k - 1)*hits_scan(i)+1:k*hits_scan(i)))) .* cos(beta_wind - phi_axis((k - 1)*hits_scan(i)+1:k*hits_scan(i))));
%         
%     end
% end
% for i = 1:length(Omega_rpm)
%     
%     for k = 1:length(mean_Phi)
%         Signal(i).sig_full((k - 1)*hits_scan(i)+1:k*hits_scan(i)) = Signal(i).sig(k, 1:hits_scan(i));
%     end
%     
% end

for i = 1:length(Omega_rpm)
    
    for k = 1:length(mean_Phi)
%         Phi_debug(k, :) = phi_axis((k - 1)*hits_scan(i)+1:k*hits_scan(i));
        sig_interest = Signal(i).sig_full((k - 1)*hits_scan(i)+1:k*hits_scan(i));
%         sig_interest_unwrap = abs(sig_interest) .* exp(1j .* (angle(sig_interest)));
%         Signal(i).doppler(k, :) = 1./sqrt(hits_scan(i)) .* fftshift(fft(Signal(i).sig_full((k - 1)*hits_scan(i)+1:k*hits_scan(i))));
         Signal(i).doppler(k, :) = 1./sqrt(hits_scan(i)) .* fftshift(fft(sig_interest));
          PT_integrand = abs(squeeze(Signal(i).doppler(k, :))).^2 .* delta_v;
          PT = sum(PT_integrand); % Total power of the Doppler Spectrum

          v_mean_integrand = vel_axis .* abs(squeeze(Signal(i).doppler(k, :))).^2 .* delta_v;
          v_mean(i, k) = sum(v_mean_integrand) ./ PT; % Mean Doppler velocity 

          v_spread_integrand = (vel_axis - v_mean(i, k)).^2 .* abs(squeeze(Signal(i).doppler(k, :))).^2 .* delta_v;
          v_spread(i, k) = sqrt(sum(v_spread_integrand)./ PT); % Doppler spectrum width
                
    end
    
end

for i = 1:length(Omega_rpm)
    Signal(i).sig_comp = abs(Signal(i).sig_full) .* exp(1j .* unwrap(angle(Signal(i).sig_full))./cos(phi_axis));
%     Signal(i).sig_comp = Signal(i).sig_full  .* exp(1j .* 4.*pi/lambda * mu * (1 - cos(phi_axis)) .* time_axis_full);
    
    
    Signal(i).sig_comp_doppler = 1./sqrt(N(i)) .* fftshift(fft(Signal(i).sig_comp));
    
    if mod(N(i), 2) ~= 0
        axis = linspace(-(N(i) - 1)/2, (N(i) - 1)/2, N(i))/(N(i) - 1);
        vel_axis_full = 2 * v_amb * axis;
    else
        axis = linspace(-N(i)/2, N(i)/2 - 1, N(i))/(N(i));
        vel_axis_full = 2 * v_amb * axis;
    end
end

figure; plot(vel_axis_full, db(abs(Signal(i).sig_comp_doppler)));
figure; plot(vel_axis_full, db(abs(data(i).data_f)), '*');




%% Plot Doppler spectrum (Azimuth vs Doppler Velocity)
OI = 1; % Index for Omega

Plot2DDopplerV2(hits_scan_1(OI), mean_Phi, v_amb, Signal, OI, SNR_db, Omega_rpm);

%% 

%% 1D plots of velocity with azimuth at different rotation speeds but a given Beamwidth


figure;


for i = 1:length(Omega_rpm)
   txt = ['\Omega = ', num2str(Omega_rpm(i)), ' [rpm]'];
   hold on; plot(mean_Phi * 180/pi, squeeze(v_mean(i, :)), 'DisplayName', txt);
end
h = legend;
grid on;
ylabel('Mean Doppler velocity [m/s]', 'FontSize', 12);
xlabel('Azimuth \Phi [deg]', 'FontSize', 12)
set(h,'FontSize',12, 'FontWeight', 'bold', 'Location','north');
title(['Mean Doppler velocity when ', ' SNR = ', num2str(SNR_db), ' dB'], 'FontSize', 12);
figure;
for i = 1:length(Omega_rpm)
   txt = ['\Omega = ', num2str(Omega_rpm(i)), ' [rpm]'];
   hold on; plot(mean_Phi * 180/pi, squeeze(v_spread(i, :)), 'DisplayName', txt);
end
h = legend;
grid on;
ylabel('Doppler spectrum width [m/s]', 'FontSize', 12);
xlabel('Azimuth \Phi [deg]', 'FontSize', 12)
set(h,'FontSize',12, 'FontWeight', 'bold', 'Location','north');
title(['Doppler spectrum width when ', ' SNR = ', num2str(SNR_db), ' dB'], 'FontSize', 12);
