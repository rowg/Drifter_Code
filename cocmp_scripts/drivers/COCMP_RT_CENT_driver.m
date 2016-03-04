clear all
close all

conf = CENT_conf;

% 3 different examples of how to call time.
% time = datenum(2007,09,1,0,0,1):1/24:datenum(2007,09,2,23,0,2);
% time = datenum(2007,09,2,0,0,1);
time = getTime([],1/24);
for i = 1:length(time)
    D = time(i);

    fprintf('******* Current time: %s  === Processing data time: %s \n', ...
            datestr(now,0), datestr(D,0));
    try
        % Total and OMA processing
        fprintf('******* CALLING COCMPdriver_Totals\n');
        COCMPdriver_Totals_OMA(D,conf);
    catch
        fprintf('COCMPdriver_Totals_OMA failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end

    % 25 hour average
    avgT = D-(conf.meanTUV.avgTime-1)/24:1/24:D+eps;
    try
        fprintf('******* CALLING COCMPdriver_meanTUV\n');
        COCMPdriver_meanTUV(avgT,conf);
    catch
        fprintf('COCMPdriver_meanTUV failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end    
    
    % Plotting
    try
        figure
        COCMPdriver_plot_hourly_totals(D,conf,'HourPlot.Print',true);
    catch
        fprintf('COCMPdriver_plot_hourly_totals failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
    
    try
        figure
        % Just the masked, interpolated ones
        COCMPdriver_plot_hourly_radials(D,conf, ...
             'RadialPlot.RadialType','RTUV','RadialPlot.Print',true);
    catch
        fprintf('COCMPdriver_plot_hourly_radials failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end

%     % Now the individual plots
%     try
%         COCMPdriver_plot_radial_cover(D,conf,'RadialPlot.Print',true);
%     catch
%         fprintf('COCMPdriver_plot_radial_cover failed because:\n')
%         res = lasterror;
%         fprintf('%s\n',res.message)
%     end
%       
%     try
%         COCMPdriver_plot_radial_current(D,conf,'RadialPlot.Print',true);
%     catch
%         fprintf('COCMPdriver_plot_radial_current failed because:\n')
%         res = lasterror;
%         fprintf('%s\n',res.message)
%     end
                   
    
    %close all
end

fprintf('+++++++ Finished at: %s\n',datestr(now,0));
% disp('exit disabled FIX BEFORE MAKING REALTIME')
exit;
