clear all
close all

% Get long range and standard range sites
time = [getTime([],4/24),getTime([],1/24)];

conf = ELIP_conf;
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

    % Now the individual plots
    try
        COCMPdriver_plot_radial_cover(D,conf,'RadialPlot.Print',true);
    catch
        fprintf('COCMPdriver_plot_radial_cover failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
    close all
      
    try
        COCMPdriver_plot_radial_current(D,conf,'RadialPlot.Print',true);
    catch
        fprintf('COCMPdriver_plot_radial_current failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end                   
    close all
    
end

clear conf
conf = RADL_conf;

% Get long range and standard range sites
% time = [getTime([],4/24),getTime([],1/24)];
% time = getTime([],1/24);
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

    % Now the individual plots
    try
        COCMPdriver_plot_radial_cover(D,conf,'RadialPlot.Print',true);
    catch
        fprintf('COCMPdriver_plot_radial_cover failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
    close all
      
    try
        COCMPdriver_plot_radial_current(D,conf,'RadialPlot.Print',true);
    catch
        fprintf('COCMPdriver_plot_radial_current failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end                   
    close all
    
end

fprintf('+++++++ Finished at: %s\n',datestr(now,0));
% disp('exit disabled FIX BEFORE MAKING REALTIME')
exit;
