function t = getTime(dn,relT)

% dn - a datenum time - if passed in as empty [], or not supplied, dn will
%      be set to the current time minus 1 hour, with the minutes and 
%      seconds set to 0.
%
% relT-number of days in the past or future to adjust dn.
%
% t -  the time in datenum format

if ~exist('relT','var')
    relT = 1/24;
end

if ~exist('dn','var') || isempty(dn)
    c = datevec(now);
    % Add a little slop in seconds to prevent the 59 min 59.99999 seconds
    % round off problem.
    dn = datenum([c(1:4),0,0.1]);
end

t = dn - relT;