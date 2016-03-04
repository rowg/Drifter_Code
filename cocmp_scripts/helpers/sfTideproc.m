function [uc,vc,lon,lat,sameTime] = sfTideproc(rotAngle,matchTime,tol);
%
% rotAngle - currents in along/cross shore direction, rotate to east/north.
%            rotAngle is the angle, in degrees, to rotate.
% matchTime- match tuv time, in matlab datenum format.
% tol      - tolerance in hours allowed for nearest current to be used.
%

if ~exist('rotAngle','var')
    % This is the rotation angle for the Golden Gate current prediction.
    rotAngle = 43;
end
if ~exist('matchTime','var')
    fprintf('%s: Using time from RealTimeParms file\n',mfilename);
    matchTime = getTime([],0);
end
if ~exist('tol','var')
    % set to 1/2 hour
    tol = 0.5;
end


% Make up a lon/lat that is inside DMK's domain.  Make up all the other
% stuff except the u and v.
lon = -122.5263;
lat =   37.7998;


filename = 's05010_ptop.html';

% First get rid of old file
delete(filename);

% Get the new file containing the golden gate currents.
%system('/sw/bin/wget http://tidesandcurrents.noaa.gov/sfports/s05010_ptop.html');
%system('curl http://tidesandcurrents.noaa.gov/sfports/s05010_ptop.html > s05010_ptop.html');
system('curl http://140.90.121.102/sfports/s05010_ptop.html > s05010_ptop.html');

% Process the file
fid = fopen(filename,'r');
dataRead = false;
% Initialize arrays.
[time,av,cv]=deal([]);
cnt = 0;
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    cnt = cnt + 1;
    % Skip over header
    if strncmp(tline,'     CD       T    TZ',21)
        % OK skip over 2 more lines
        tline = fgetl(fid);
        tline = fgetl(fid);
        dataRead = true;
        % OK this is the first data line
        tline = fgetl(fid);
    end
    
    if strncmp(tline,'</pre>',6)
        % We are done reading data
        dataRead = false;
    end
    
    if dataRead
        % OK we are at the beginning of the data, parse.  Here's the format:
        % 21  7 2006 21 48  PDT 1.12 0.00
        % where:
        %   CD   -   Calander date (day, month, year)
        %   T    -   Time (hour, minute)
        %   TZ   -   Timezone
        %   AV   -   Along channel current velocity (knots)
        %   CV   -   Cross channel current velocity (knots)
        day = str2num(tline(2:3));
        mon = str2num(tline(5:6));
        year = str2num(tline(8:11));
        hour = str2num(tline(13:14));
        minute=str2num(tline(16:17));
        dn = datenum(year,mon,day,hour,minute,0);
        tz = tline(20:22);
        % Convert the time into GMT.
        if strcmpi(tz,'PDT')
            dn = dn + 7/24;
        elseif strcmpi(tz,'PST')
            dn = dn + 8/24;
        else
            fprintf('%s not set to deal with %s time zone ... time in %s NOT GMT\n', ...
                     mfilename, tz, tz);
        end
        time = cat(1,time,dn);
        av = cat(1,av,str2num(tline(23:27)));
        cv = cat(1,cv,str2num(tline(28:32)));
    end
end
fclose(fid);
% Get rid of this file.
delete(filename);


% OK now process the data. 
% Currents are in knots, convert to cm/s
av = (av * 0.514444) * 100;
cv = (cv * 0.514444) * 100;
% Currents are rotated into along and cross channel - convert to standard
% east and north convention.  Golden Gate info is:
% Golden Gate Bridge, California
% DON'T ACTUALLY THINK THIS IS THE CORRECT LOCATION, BUT IT IS CLOSE.
% Latitude: 37¡ 48.4' N
% Longitude: 122¡ 27.9' W
% Predicted Tidal Current            January, 2006
% Flood Direction,  47  True.               Ebb (-)Direction, 227  True.
% NOAA, National Ocean Service
% So rotate -43 degrees for standard u (east) and v (west).
[u,v] = rotUV(av,cv,rotAngle);

% Now do time matching
timeDiff = abs(time-matchTime);
[minTimeDiff,index]=min(timeDiff);

if minTimeDiff < tol/24
    uc = u(index);
    vc = v(index);
    sameTime = time(index);
    speed = sqrt(uc .^2 + vc .^2);
else
    uc = NaN;
    vc = NaN;
    sameTime = NaN;
    speed = NaN;
end

