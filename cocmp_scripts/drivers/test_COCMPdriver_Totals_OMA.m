clear all
close all

conf = MNTY_conf;

% time = datenum(2007,09,1,0,0,1):1/24:datenum(2007,09,2,23,0,2);
% time = datenum(2007,09,2,0,0,1);
time = getTime([],5/24);
for i = 1:length(time)
    D = time(i);

    fprintf('******* Current time: %s  === Processing data time: %s \n', ...
            datestr(now,0), datestr(D,0));
    % Total and OMA processing
    COCMPdriver_Totals_OMA(D,conf);

end

fprintf('+++++++ Finished at: %s\n',datestr(now,0));
