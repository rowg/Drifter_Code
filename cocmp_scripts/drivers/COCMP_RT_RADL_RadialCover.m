clear all
close all

START_TIME=now;

% This is usually run once per day for 1 week into the past, so starting at
% the past hour isn't critical.  Set back a few to get latest long range
% data too.
time = getTime([],3/24);

conf = RADL_conf;

for i = 1:length(time)
    D = time(i);

    fprintf('******* Current time: %s  === Processing data time: %s \n', ...
            datestr(now,0), datestr(D,0));

    % Now create a weekly coverage plot for every radial site in the conf
    % list forr time D.
    try
        COCMPdriver_plot_radial_weeklyCover(D,conf,'RadialPlot.Print',true);
    catch
        fprintf('COCMPdriver_plot_radial_weeklyCover failed because:\n')
        res = lasterror;
        fprintf('%s\n',res.message)
    end
    close all    
end

END_TIME = now;
fprintf('COCMP_RT_RADL_RadialCover.m complete ...\n');
fprintf('Start Time: %s,  End Time: %s\n', ...
    datestr(START_TIME,0),datestr(END_TIME,0));

% disp('exit disabled FIX BEFORE MAKING REALTIME')
exit;
