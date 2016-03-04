clear all
close all

conf = MNTY_conf;
conf.TrajAnim.tmpDir = '/Users/hroarty/Documents/MATLAB/cocmp_scripts/drivers/trajectory_temp/';

% time = datenum(2007,12,17,0,0,1):1/24:datenum(2007,12,18,18,0,2);
% time = datenum(2007,09,2,0,0,1);
time = getTime([],5/24);
for i = 1:length(time)
    D = time(i);

    % 25 hour average
    avgT = D-(conf.meanTUV.avgTime-1)/24:1/24:D+eps;

    % Particle trajectory stuff
    try
        COCMPdriver_calcTraj(avgT,conf);
    catch
        fprintf('COCMPdriver_calcTraj failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
    
    try
        figure
        COCMPdriver_plot_trajectory(D,conf,'HourPlot.Print',true, ...
                'HourPlot.axisLims',[-122.5,conf.HourPlot.axisLims(2:4)]);
    catch
        fprintf('COCMPdriver_plot_trajectory failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
    
    try
        close
        COCMP_trajectory_movie(D,conf,'HourPlot.Print',true, ...
                'HourPlot.axisLims',[-122.5,conf.HourPlot.axisLims(2:4)]);
    catch
        fprintf('COCMPdriver_plot_trajectory failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
end

% % % exit;
