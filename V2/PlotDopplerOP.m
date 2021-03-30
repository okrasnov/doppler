function [] = PlotDopplerOP(OP_enable, OP_enable_error, SNR_db, SI, mean_Phi, Omega_rpm, v_mean, v_spread, v_mean_e, v_spread_e)

SNR_interest = SNR_db(SI);

if OP_enable == 1
    figure; surface(Omega_rpm, mean_Phi .* 180/pi, squeeze(v_mean(SI, :, :)).'); shading flat; colorbar;colormap('jet') % Plot the error in mean Doppler

    ylabel('Azimuth Angle \Phi [deg]', 'FontSize', 16);
    xlabel('Angular speed of radar beam in azimuth [rpm]', 'FontSize', 16)
    zlabel('Mean Doppler velocity [m/s]', 'FontSize', 16);
    title(['Mean Doppler velocity at ', ', SNR = ', num2str(SNR_interest), ' dB'], 'FontSize', 16);
    
    figure; surface(Omega_rpm, mean_Phi .* 180/pi, squeeze(v_spread(SI, :, :)).'); shading flat; colorbar; colormap('jet'); % Plot the mean Doppler

    ylabel('Azimuth Angle \Phi [deg]', 'FontSize', 16);
    xlabel('Angular speed of radar beam in azimuth [rpm]', 'FontSize', 16)
    zlabel('Doppler Spectrum Width [m/s]', 'FontSize', 16);
    title(['Doppler spectrum width at ', ', SNR = ', num2str(SNR_interest), ' dB'], 'FontSize', 16);
end
if OP_enable_error == 1
    
    figure; surface(Omega_rpm, mean_Phi .* 180/pi, squeeze(v_mean_e(SI, :, :)).'); shading flat; colorbar;colormap('jet') % Plot the error in mean Doppler

    ylabel('Azimuth Angle \Phi [deg]', 'FontSize', 16);
    xlabel('Angular speed of radar beam in azimuth [rpm]', 'FontSize', 16)
    zlabel('Error in Mean Doppler velocity [m/s]', 'FontSize', 16);
    title(['Error in Mean Doppler velocity ', ', SNR = ', num2str(SNR_interest), ' dB'], 'FontSize', 16);
    
    figure; surface(Omega_rpm, mean_Phi .* 180/pi, squeeze(v_spread_e(SI, :, :)).'); shading flat; colorbar; colormap('jet'); % Plot the mean Doppler

    ylabel('Azimuth Angle \Phi [deg]', 'FontSize', 16);
    xlabel('Angular speed of radar beam in azimuth [rpm]', 'FontSize', 16)
    zlabel('Error in Doppler Spectrum width [m/s]', 'FontSize', 16);
    title(['Error in Doppler spectrum width at ', ', SNR = ', num2str(SNR_interest), ' dB'], 'FontSize', 16);
end

end