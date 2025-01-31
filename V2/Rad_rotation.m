clear;
% close all;

%% Configuration 0 is off, 1 in on

% Want plot for Error vs SNR? 
SNR_enable = 0;

% Want to plot for Error vs BW?
BW_enable = 0;

% Want plot for Erorr vs Omega and Phi?
OP_enable_error = 0;

% Want Doppler Azimuth plot?

DS_Azimuth_plots = 1; % Doppler Azimuth Plot

% Want to run Monte Carlo simulation?
MC_enable = 1;

% Want to plot mean Doppler and Doppler spectrum width?
OP_enable = 0;

%%

if MC_enable == 1
    n_MC = 8; 
else
    n_MC = 1;
end


if SNR_enable == 1

    SNR_i_db = -30; 
    SNR_f_db = 30; 
    n_SNR = 10; % Number of points wanted in the SNR axis
    SNR_db = linspace(SNR_i_db, SNR_f_db, n_SNR);
    SNR = 10.^(SNR_db/10);

else
    n_SNR = 1;
    SNR_db = 30;
    SNR = 10^(SNR_db/10);
end

if BW_enable == 1
    n_BW = 10;
    BW_deg = linspace(1, 10, n_BW);
else
    BW_deg = 1;
    n_BW = 1;
end


%% RADAR constants and wind direction

beta_wind = eps; % wind direction
m0 = 1;
mu = 5;
sigma = 0.2;



PRT = 1e-3;
lambda = 3e-2;
% n = 2^10;

v_amb = lambda/(4*PRT);% Doppler ambiguity limits in velocity


%% 

Omega_rpm = linspace(1, 60, 4); % RPM axis for the rotation of the radar
% Omega_rpm = 1;
% Omega_rpm = linspace(1, 60, 60);
% Omega_rpm = 40.33;

%% 

for l = 1:n_MC % Monte Carlo iterations v
     disp('Monte Carlo Iter'); disp(l);

for m = 1:n_BW

Phi_0_deg = 0;
Phi_end_deg = 360;

BW = BW_deg(m)*pi/180; % Beam width in radians
phi_0 = Phi_0_deg * pi/180; % Start of azimuth angle
phi_end = Phi_end_deg * pi/180; % End of azimuth angle

Phi(m).Phi = phi_0:BW:phi_end;

% mean_Phi = mean([Phi(1:end-1); Phi(2:end)]); % This is done to take the mid angles of all possible angular resolution cell

%% resampling based on the rotation of the radar

    for s = 1:n_SNR
        
        for i = 1:length(Omega_rpm)
            
            Omega = Omega_rpm(i) .* 2 * pi ./ 60;

            T(m ,i) = BW/Omega;

            time_axis(m, i).axis = eps:PRT:T(m, i); % Time axis for one beamwidth
            

            hits_scan(m, i) = length(time_axis(m, i).axis); % length of time axis for one beam width (also known as hits per scan)
            
            N = hits_scan(m, i) .* length(Phi(m).Phi); % When creating HD spectrum and signal, we need number of points = hits_scan \times (Number of beam widths in an entire rotation)
            
            if mod(N, 2) ~= 0 % If it is even, make it odd
                N = N + 1;
            end
            
            
       %% This if clause is only to decide the number of points required for Doppler processing for every azimuthal angle
            if hits_scan(m, i) < 32 % (Make it 0 if no zero padding is required)
                hits_scan_1(m, i) = 64 + 1; % For Doppler processing when hits per scan is too small [zero padding purposes]
            else
                hits_scan_1(m, i) = hits_scan(m, i); 
            end
       %% 
          time_axis_full = linspace(eps, PRT.*N, N); % High resolution time axis
          Axis(m, i).axis_full = linspace(-(N - 1)/2, (N - 1)/2 - 1, N)/(N - 1); 
          vel_axis_full = 2.*v_amb.*Axis(m, i).axis_full; % High definition velocity axis 
            
          [data(i, m).data(l, s, :), ~, ~, ~] = ...
              DS_simulatorV3(SNR(s), m0, mu, sigma, N, v_amb); % Generation of HD signal in time domain
          
          % (i -> for each rotation speed, m -> For different BW, l ->
          % Monte Carlo axis, s -> SNR axis, k -> For each azimuth angle) 
         
          vel_axis(m, i).axis = linspace(-v_amb, v_amb, hits_scan_1(m, i)); % To show the Doppler spectrum
            
          delta_v(m, i) = lambda/(2*hits_scan_1(m, i)*PRT); % velocity resolution 
            
%           Axis(m, i).axis_fft = linspace(0, hits_scan_1(m, i) - 1, hits_scan_1(m, i))/hits_scan_1(m, i); 
%           
%           vel_axis(m, i).axis_fft = 2*v_amb*Axis(m, i).axis_fft; % Axis in case of mean calculatyion when no aliasing is considered

            for k = 1:length(Phi(m).Phi)-1 % For each direction in azimuth 
                
                beta_scan = beta_wind - (Phi(m).Phi(k) + Omega .* time_axis(m, i).axis);
            
                 
                Signal(i, m).sig(l, s, k, :) = hamming(hits_scan(m, i)) .* (abs(squeeze(data(i, m).data(l, s, (k - 1)*hits_scan(m, i) + 1: k*hits_scan(m, i))))...
                .* exp(1j .* unwrap(angle(squeeze(data(i, m).data(l, s, (k - 1)*hits_scan(m, i) + 1: k*hits_scan(m, i))))) .* cos(beta_scan).'));
             
                Signal(i, m).doppler(l, s, k, :) = 1./sqrt(hits_scan_1(m, i)) .* fftshift(fft(Signal(i, m).sig(l, s, k, :), hits_scan_1(m, i))); % To be used for moments calculation
                
                
%                 Signal(i, m).doppler_fft(l, s, k, :) = 1./sqrt(hits_scan_1(m, i)) .* (fft(Signal(i, m).sig(l, s, k, :), hits_scan_1(m, i))); % To be used for moments calculation without aliasing
%                  
%                 figure; plot(vel_axis(m, i).axis, db(abs(squeeze(Signal(i, m).doppler_fft(l, s, k, :)).^2))/2, '-o'); 
%                 
%                 hold on;  plot(vel_axis(m, i).axis, db(abs(squeeze(data(i, m).data_f(l, s, k, :))).^2)/2, '*'); grid on;
% %                 hold on;  plot(vel_axis_full, db(abs(squeeze(data(i, m).data_f_full(l, s, k, :))).^2)/2, '-.'); grid on;
% %                 figure; 
                
              
           %% Moments calculation
           
                PT_integrand = abs(squeeze(Signal(i, m).doppler(l, s, k, :))).^2 .* delta_v(m, i);
                PT = sum(PT_integrand); % Total power of the Doppler Spectrum

                v_mean_integrand = vel_axis(m, i).axis.' .* abs(squeeze(Signal(i, m).doppler(l, s, k, :))).^2 .* delta_v(m, i);
                v_mean_l(l, m, s, i, k) = sum(v_mean_integrand) ./ PT; % Mean Doppler velocity 

                v_spread_integrand = (vel_axis(m, i).axis.' - v_mean_l(l, m, s, i, k)).^2 .* abs(squeeze(Signal(i, m).doppler(l, s, k, :))).^2 .* delta_v(m, i);
                v_spread_l(l, m, s, i, k) = sqrt(sum(v_spread_integrand)./ PT); % Doppler spectrum width
                
            %% Moments calculation without aliasing
            
%                 PT_integrand_fft = abs(squeeze(Signal(i, m).doppler_fft(l, s, k, :))).^2;
%                 PT_fft = sum(PT_integrand_fft); % Total power of the Doppler Spectrum
%              
%                 [~, indx] = max(abs(squeeze(Signal(i, m).doppler_fft(l, s, k, :))).^2);
%                 
%                 Axis(m, i).axis_mean = indx-hits_scan_1(m, i)/2:1:indx+hits_scan_1(m, i)/2-1;
%                 
%                 f_mean_l(l, m, s, i, k) = (1/(hits_scan_1(m, i) .* PRT)) .* indx + (1/(hits_scan_1(m, i) .* PRT .* PT_fft))...
%                     .* sum((Axis(m, i).axis_mean - indx) .* abs(squeeze(Signal(i, m).doppler_fft(l, s, k, 1+mod(Axis(m, i).axis_mean, hits_scan_1(m, i)))).').^2);
%                 v_mean_l_fft(l, m, s, i, k) = f_mean_l(l, m, s, i, k) .* lambda./2;
%                 
%                 if v_mean_l_fft(l, m, s, i, k) > v_amb
%                     v_mean_l_fft(l, m, s, i, k) = v_mean_l_fft(l, m, s, i, k) - 2.*v_amb;
%                 end
            end
            
        end

    end
end

end

%% Error calculations

for m = 1:n_BW
    for s = 1:n_SNR
       for i = 1:length(Omega_rpm)
          for k = 1:length(Phi(m).Phi)-1
               v_mean(m, s, i, k) = sum(v_mean_l(:, m, s, i, k))/n_MC;
%                v_mean_fft(m, s, i, k) = sum(v_mean_l_fft(:, m, s, i, k))/n_MC;
               v_spread(m, s, i, k) = sum(v_spread_l(:, m, s, i, k))/n_MC;
               v_mean_e(m, s, i, k) = sqrt(sum((v_mean_l(:, m, s, i, k) - mu).^2)/n_MC);
               v_spread_e(m, s, i, k) = sqrt(sum((v_spread_l(:, m, s, i, k) - sigma).^2)/n_MC);
          end
       end
    end
end


%% Plot Doppler spectrum (Azimuth vs Doppler Velocity)


if DS_Azimuth_plots == 1
    SI = 1; % Index for SNR
    OI = 3; % Index for Omega
    BI = 1; % Index of Beamwidth
    Plot2DDoppler(vel_axis(BI, OI).axis, Phi, Signal, BI, SI, OI, BW_deg, SNR_db, Omega_rpm);
end
%%
% for k = 1:length(Phi(BI).Phi)-1
%     s = squeeze(mean(abs(squeeze(Signal(OI, BI).doppler(:, SI, k, :))), 1));
%     figure(101); plot(vel_axis(BI, OI).axis, db(abs(s)));hold on;
% end
%% Plot Erros with BW

if BW_enable == 1
    OI = 1;
    PI = 1; 
    SI = 1;
    PlotDopplerBW(BW_deg, v_mean_e, v_spread_e, SI, OI, PI, SNR_db, Omega_rpm, Phi);
end


%% Error with With SNR

if SNR_enable == 1
    OI = 4; % Index for Omega
    PI = 1; % Index for Phi
    BI = 1;
    PlotDopplerSNR(SNR_db, v_mean_e, v_spread_e, BI, OI, PI, BW_deg, Omega_rpm, Phi);
end



%%
% legend show;
% figure(103);
% h = legend;
% set(h,'FontSize',12, 'FontWeight', 'bold', 'Location','north');
%% 2D plots of mean Doppler and Doppler spread and Erros



if OP_enable == 1 || OP_enable_error == 1
    SI = 1; % Index of the SNR axis
    BI = 1; % Index of the Beamwidth axis
    PlotDopplerOP(OP_enable, OP_enable_error, BW_deg, BI, SNR_db, SI, Phi, Omega_rpm, v_mean, v_spread, v_mean_e, v_spread_e);
end

%% 1D plots of velocity with azimuth at different rotation speeds but a given Beamwidth


figure;
SI = 1; % Index of the SNR axis
BI = 1; % Index of BeamWidth
Length_Phi_axis = length(Phi(BI).Phi) - 1;


for i = 1:length(Omega_rpm)
   txt = ['\Omega = ', num2str(Omega_rpm(i)), ' [rpm]'];
   hold on; plot(Phi(BI).Phi(1:Length_Phi_axis) * 180/pi, squeeze(v_mean(BI, SI, i, 1:Length_Phi_axis)), 'DisplayName', txt);
end
h = legend;
grid on;
ylabel('Mean Doppler velocity [m/s]', 'FontSize', 12);
xlabel('Azimuth \Phi [deg]', 'FontSize', 12)
set(h,'FontSize',12, 'FontWeight', 'bold', 'Location','north');
title(['Mean Doppler velocity when ', ' SNR = ', num2str(SNR_db(SI)), ' dB', ', BW = ', num2str(BW_deg(BI)), ' deg'], 'FontSize', 12);
figure;
for i = 1:length(Omega_rpm)
   txt = ['\Omega = ', num2str(Omega_rpm(i)), ' [rpm]'];
   hold on; plot(Phi(BI).Phi(1:Length_Phi_axis) * 180/pi, squeeze(v_spread(BI, SI, i, 1:Length_Phi_axis)), 'DisplayName', txt);
end
h = legend;
grid on;
ylabel('Doppler spectrum width [m/s]', 'FontSize', 12);
xlabel('Azimuth \Phi [deg]', 'FontSize', 12)
set(h,'FontSize',12, 'FontWeight', 'bold', 'Location','north');
title(['Doppler spectrum width when ', ' SNR = ', num2str(SNR_db(SI)), ' dB',', BW = ', num2str(BW_deg(BI)), ' deg'], 'FontSize', 12);

