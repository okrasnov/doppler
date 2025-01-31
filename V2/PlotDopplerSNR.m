function [] = PlotDopplerSNR(SNR_db, v_mean_e, v_spread_e, BI, OI, PI, BW_deg, Omega_rpm, Phi)
    Phi_interest = Phi(BI).Phi(PI) .* 180/pi;
    Omega_interest = Omega_rpm(OI);
    BW_interest = BW_deg(BI);
    
   
    txt = ['\Omega = ', num2str(Omega_interest), ' [rpm]'];
    figure(102); hold on;
%         plot(SNR_db, squeeze(v_mean_e(BI, :, OI, PI)), 'color', [0.6350, 0.0780, 0.1840], 'LineWidth', 2);
        plot(SNR_db, squeeze(v_mean_e(BI, :, OI, PI)), 'LineWidth', 2, 'DisplayName', txt);
%         plot(SNR_db, squeeze(v_mean_e(BI, :, OI, PI)), 'LineWidth', 2);
    grid on;
    xlabel('SNR [dB]', 'FontSize', 16)
    ylabel('Error in Mean Doppler velocity [m/s]', 'FontSize', 16);
%     title(['Error in Mean Doppler velocity at ', num2str(Omega_interest), 'RPM', ', \Phi = ', num2str(Phi_interest), ' deg', ', BW = ', num2str(BW_interest), ' deg'], 'FontSize', 16);
    title(['Error in Mean Doppler velocity at ', ', BW = ', num2str(BW_interest), ' deg'], 'FontSize', 16);
%     
    figure(103); hold on; 
%     plot(SNR_db, squeeze(v_spread_e(BI, :, OI, PI)), 'color', [0.6350, 0.0780, 0.1840], 'LineWidth', 2); 
    plot(SNR_db, squeeze(v_spread_e(BI, :, OI, PI)), 'LineWidth', 2, 'DisplayName', txt); 
%     plot(SNR_db, squeeze(v_spread_e(BI, :, OI, PI)), 'LineWidth', 2);
      grid on;
    xlabel('SNR [dB]', 'FontSize', 16)
    ylabel('Error in Doppler spectrum width [m/s]', 'FontSize', 16);
    
%     title(['Error in Doppler spectrum width at ', num2str(Omega_interest), 'RPM', ', \Phi = ', num2str(Phi_interest), ' deg'', BW = ', num2str(BW_interest), ' deg'], 'FontSize', 16);
      title(['Error in Doppler spectrum width at ', ', BW = ', num2str(BW_interest), ' deg'], 'FontSize', 16);
end