clear all
close all

START_TIME=now;

conf = ANVO_AR_conf;
logFile = 'ANVO_AR_conf.log';
fid = fopen(logFile,'w');

% Start at June 1, 2006
% time = datenum(2006,06,01,00,00,0.0001):1/24:datenum(2007,12,31,23,0,1);
time = datenum(2007,03,29,00,00,0.0001):1/24:datenum(2007,12,31,23,0,1);

% What to process?
% 1 = data only: create totals, oma, 25 hr avg, trajectories
% 2 = plots only: create totals, oma, 25hr avg, traj plots
% 3 = predicted trajs and movies, this is the S-L-O-W stuff
% 4 = do it all, 1 thru 3.
procFlag = 2;

for i = 1:length(time)
    D = time(i);

    % Need to create a FilePrefix and a Type that is 1 x N
    timeIndex = find(D >= conf.Radials.TimeChanges);
    conf.Radials.Types = conf.Radials.TypesList{timeIndex(end)};
    conf.Radials.FilePrefix = {conf.Radials.FilePrefixList{timeIndex(end),:}};

    fprintf('** Current time: %s  == Processing data time: %s == TimeChange Index: %d\n', ...
            datestr(now,0), datestr(D,0), timeIndex(end));
    fprintf(fid,'** Current time: %s  == Processing data time: %s == TimeChange Index: %d\n', ...
            datestr(now,0), datestr(D,0), timeIndex(end));


    if procFlag == 1  ||  procFlag > 3
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
            fprintf('******* CALLING COCMPdriver_meanTUV for OMA\n');
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
    end
    
    if procFlag == 2  ||  procFlag > 3
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
            fprintf('COCMPdriver_plot_hourly_totals failed because:\n')
            res = lasterror;
            fprintf('%s\n',res.message)
        end

        try
            figure
            COCMPdriver_plot_meanTUV(D,conf, ...
                          'HourPlot.Print',true);
        catch
            fprintf('COCMPdriver_plot_meanTUV failed because:\n')
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

        try
            figure
            COCMPdriver_plot_trajectory(D,conf,'HourPlot.Print',true, ...
                    'HourPlot.axisLims',[-123.05,conf.HourPlot.axisLims(2:4)]);
        catch
            fprintf('COCMPdriver_plot_trajectory failed because:\n')
            res = lasterror;
            fprintf('%s\n',res.message)
        end
        close all
    end
    
    if procFlag == 3  ||  procFlag > 3
        % Predicted Particle trajectory stuff and GNOME netcdf file write.
        try
            COCMPdriver_predict(D,conf);
        catch
            fprintf('COCMPdriver_predict failed because:\n')
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
            fprintf('COCMP_pred_trajectory_movie_bg failed because:\n')
            res = lasterror;
            fprintf('%s\n',res.message)
        end
    end
               
    
    close all

end

END_TIME = now;
fprintf('COCMP_AR_ANVO_driver.m complete ...\n');
fprintf('Start Time: %s,  End Time: %s procFlag=%d\n', ...
    datestr(START_TIME,0),datestr(END_TIME,0),procFlag);
fprintf(fid,'Start Time: %s,  End Time: %s procFlag=%d\n', ...
    datestr(START_TIME,0),datestr(END_TIME,0),procFlag);
fclose(fid);
disp('exit disabled FIX BEFORE RUNNING IN BATCH MODE')
% exit;
