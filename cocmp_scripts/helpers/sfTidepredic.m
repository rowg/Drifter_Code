function [uc,vc,lon,lat] = sfTidepredic(predicFN,time)
%
% predicFN - filename containing the variables FREQ, NAME, TIDECON and
%            others that came from t_tide analysis of the current data.
%
% time  - time in datenume format to make the prediction. Can be a vector
%         of times.

if ~exist('predicFN','var')
    predicFN = 'tideConst.mat';
end
if ~exist('time','var')
    % set to 1/2 hour
    time = getTime([],0);
end

% The t_tide analysis results are already in tideConst, but do it here so
% you can see how it is done from analysis to prediction.  AShore_constDT
% is the along channel component of the current only.  Since the tide is so
% strong in the channel the cross shore component isn't analyzed by NOAA.
% AShore_constDT is in knots, time in GMT.
% [NAME,FREQ,TIDECON,XOUT] = t_tide(AShore_constDT, ...
%                                   'start time',startTime, ...
%                                   'error','wboot', ...
%                                   'latitude',lat, ...
%                                   'output','GgateAlongChannel.out', ...
%                                   'synthesis',0);

load(predicFN);

% Currents are rotated into along and cross channel.  Thers is no cross
% channel current though.  Convert to standard
% east and north convention.  Golden Gate info is:
% Golden Gate Bridge, California
% DON'T ACTUALLY THINK THIS IS THE CORRECT LOCATION, BUT IT IS CLOSE.
% Latitude: 37¡ 48.4' N
% Longitude: 122¡ 27.9' W
% Predicted Tidal Current            January, 2006
% Flood Direction,  47  True.               Ebb (-)Direction, 227  True.
% NOAA, National Ocean Service
% So rotate 43 degrees for standard u (east) and v (west).
rotAngle = 43;

residual=AShore_constDT-XOUT;

% predict for the whole time period
x = t_predic(time,NAME,FREQ,TIDECON,lat,0)+nanmean(residual);

% Convert to u/v components, but u/v are still in knots
[u,v]=rotUV(x,0,rotAngle);

% Currents are in knots, convert to cm/s
uc = (u * 0.514444) * 100;
vc = (v * 0.514444) * 100;

% Make up a lon/lat that is inside SFOO OMA domain.
lon = -122.5263;
lat =   37.7998;

