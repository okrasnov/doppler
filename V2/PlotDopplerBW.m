function [] = PlotDopplerBW(BW_deg, v_mean_e, v_spread_e, SI, OI, PI, SNR_db, Omega_rpm, Phi)
%    Phi_interest = Phi.Phi(PI) .* 180/pi;
    Omega_interest = Omega_rpm(OI);
    SNR_interest = SNR_db(SI);
    figure(101); hold on; plot(BW_deg, squeeze(v_mean_e(:, SI, OI, PI)), 'color', [0.6350, 0.0780, 0.1840], 'LineWidth', 2);
    grid on;
    xlabel('BW [deg]', 'FontSize', 16)
    ylabel('Error in Mean Doppler velocity [m/s]', 'FontSize', 16);
    title(['Error in Mean Doppler velocity at ', num2str(Omega_interest), 'RPM', ', SNR = ', num2str(SNR_interest), ' dB'], 'FontSize', 16);
    
    
    figure; plot(BW_deg, squeeze(v_spread_e(:, SI, OI, PI)), 'color', [0.6350, 0.0780, 0.1840], 'LineWidth', 2);
    grid on;
    xlabel('BW [deg]', 'FontSize', 16)
    ylabel('Error in Doppler spectrum width [m/s]', 'FontSize', 16);
    
    title(['Error in Doppler spectrum width at ', num2str(Omega_interest), 'RPM', ', SNR = ', num2str(SNR_interest), ' dB'], 'FontSize', 16);

end