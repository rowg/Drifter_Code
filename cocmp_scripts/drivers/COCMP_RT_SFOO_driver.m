clear all
close all

conf = SFOO_conf;

% time = datenum(2008,03,4,0,0,1):1/24:datenum(2008,03,4,20,0,2);
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
    try
        COCMPdriver_meanTUV(avgT,conf,'meanTUV.Type','OMA');
    catch
        fprintf('COCMPdriver_meanTUV failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
    
    % Particle trajectory stuff
    try
        COCMPdriver_calcTraj(avgT,conf);
    catch
        fprintf('COCMPdriver_calcTraj failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
    
    % Predicted Particle trajectory stuff and GNOME netcdf file write.
    try
        COCMPdriver_predict(D,conf);
    catch
        fprintf('COCMPdriver_predict failed because:\n')
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
        COCMPdriver_plot_hourly_totals(D,conf,'HourPlot.Type','OMA', ...
                                      'HourPlot.BaseDir',conf.OMA.HourPlotDir, ...
                                      'HourPlot.axisLims',[-123.05,conf.HourPlot.axisLims(2:4)], ...
                                      'HourPlot.Print',true);
    catch
        fprintf('COCMPdriver_plot_hourly_totals failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end

    try
        figure
        COCMPdriver_plot_OMAerrors(D,conf,'HourPlot.Type','OMA', ...
                                   'HourPlot.BaseDir',conf.OMA.HourPlotDir, ...
                                   'HourPlot.axisLims',[-123.05,conf.HourPlot.axisLims(2:4)], ...
                                   'HourPlot.Print',true);
    catch
        fprintf('COCMPdriver_plot_OMAerrors failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end

    try
        figure
        %COCMPdriver_plot_meanTUV(D,conf,'meanTUV.Type','OMA', ...
        %                               'HourPlot.axisLims',[-123.05,conf.HourPlot.axisLims(2:4)], ...
        %                               'HourPlot.Print',true);
        COCMPdriver_plot_meanTUV(D,conf, ...
                 'HourPlot.Print',true);
    catch
        fprintf('COCMPdriver_plot_meanTUV failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
    
    % %     try
    % %         figure
    % %         % All radials
    % %         COCMPdriver_plot_hourly_radials(D,conf, ...
    % %                             'RadialPlot.FilePrefix',strcat('RadAll_',conf.HourPlot.DomainName,'_'), ...
    % %                             'RadialPlot.Print',true);
    % %     catch
    % %         fprintf('COCMPdriver_plot_hourly_radials failed because:\n')
    % %         res = lasterror;
    % %         fprintf('%s\n',res.message)
    % %     end

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

    % %     % Now the individual plots
    % %     try
    % %         COCMPdriver_plot_radial_cover(D,conf,'RadialPlot.Print',true);
    % %     catch
    % %         fprintf('COCMPdriver_plot_radial_cover failed because:\n')
    % %         res = lasterror;
    % %         fprintf('%s\n',res.message)
    % %     end
    % %       
    % %     try
    % %         COCMPdriver_plot_radial_current(D,conf,'RadialPlot.Print',true);
    % %     catch
    % %         fprintf('COCMPdriver_plot_radial_current failed because:\n')
    % %         res = lasterror;
    % %         fprintf('%s\n',res.message)
    % %     end
    
    try
        figure
        COCMPdriver_plot_trajectory(D,conf,'HourPlot.Print',true, ...
                'HourPlot.axisLims',[-123.05,conf.HourPlot.axisLims(2:4)]);
    catch
        fprintf('COCMPdriver_plot_trajectory failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
    
    try
        figure
        COCMPdriver_plot_pred_trajectory(D,conf,'HourPlot.Print',true, ...
                'HourPlot.axisLims',[-123.05,conf.HourPlot.axisLims(2:4)]);
    catch
        fprintf('COCMPdriver_plot_pred_trajectory failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
    
    try
        COCMP_trajectory_movie_bg(D,conf,'HourPlot.Print',true, ...
                'HourPlot.axisLims',[-123.05,conf.HourPlot.axisLims(2:4)]);
    catch
        fprintf('COCMP_trajectory_movie_bg failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
    
    try
        COCMP_pred_trajectory_movie_bg(D,conf,'HourPlot.Print',true, ...
                'HourPlot.axisLims',[-123.05,conf.HourPlot.axisLims(2:4)]);
    catch
        fprintf('COCMP_pred_trajectory_movie failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
               
    
    close all
end

fprintf('+++++++ Finished at: %s\n',datestr(now,0));
% disp('exit disabled FIX BEFORE MAKING REALTIME')
exit;
