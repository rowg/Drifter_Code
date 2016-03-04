function TRAJstruct2shape(TRAJ,pathFile)

% USAGE:
%    TRAJstruct2shape(TRAJ,pathFile)
%    will take the TRAJ struct, remove any NaN's at the end of 
%    tracks, and write the
%    rest to a shapefile for use in GIS programs like ArcView.


% Time is calculated every 7 1/2 minutes, decimiate to every 1/2 hour.
time = TRAJ.TimeStamp(1:4:end);
Lon = TRAJ.Lon(:,1:4:end);
Lat = TRAJ.Lat(:,1:4:end);

% Eliminate trajectories with no duration.
ind = TRAJ.TrajectoryDuration < eps;
Lon(ind,:) = [];
Lat(ind,:) = [];

if isempty(Lon)
    fprintf('No data in this TRAJ struct, no shape files written')
    return;
end


writeShapeLines(Lon,Lat,pathFile,TRAJ.Type,time);
