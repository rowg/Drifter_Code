clear all
close all

conf = MNTY_unique_conf;

% time = datenum(2007,09,1,0,0,1):1/24:datenum(2007,09,2,23,0,2);
% time = datenum(2007,09,2,0,0,1);
time = getTime([],4/24);
for i = 1:length(time)
    D = time(i);

    fprintf('******* Current time: %s ===== Will process data time: %s \n', ...
                     datestr(now,0), datestr(D,0));
    try
        % Total and OMA processing
        COCMPdriver_Totals_OMA(D,conf);
    catch
        fprintf('COCMPdriver_Totals_OMA failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end

    %    % Plotting
    %    try
    %    figure
    %    COCMPdriver_plot_hourly_totals(D,conf,'HourPlot.Print',true);
    %catch
    %    fprintf('COCMPdriver_plot_hourly_totals failed, skipping because:\n')
    %    res = lasterror;
    %    fprintf('%s\n',res.message)
    %end

    %try
    %    figure
    %    COCMPdriver_plot_hourly_totals(D,conf,'HourPlot.Type','OMA', ...
    %                                  'HourPlot.BaseDir',conf.OMA.HourPlotDir, ...
    %                          'HourPlot.axisLims',[-122.5,conf.HourPlot.axisLims(2:4)], ...
    %                          'HourPlot.Print',true);
    %catch
    %    fprintf('COCMPdriver_plot_hourly_totals failed, skipping because:\n')
    %    res = lasterror;
    %    fprintf('%s\n',res.message)
    %end

    % Now the individual plots
    try
        COCMPdriver_plot_radial_cover(D,conf,'RadialPlot.Print',true);
    catch
        fprintf('COCMPdriver_plot_radial_cover failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
      
    try
        COCMPdriver_plot_radial_current(D,conf,'RadialPlot.Print',true);
    catch
        fprintf('COCMPdriver_plot_radial_current failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
end

fprintf('+++++++ Finished at: %s\n',datestr(now,0));
%disp('exit disabled')
exit;
