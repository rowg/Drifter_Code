function [Traj]=flagTrajs(Traj,poly,flag)

% function to flag any drifter positions that are outside of a user input
% boundary.  It is designed to work with the OMA domain boundary, but any
% closed polygon with lon/lat vertices will work.
try
    flag;
catch
    flag = NaN;
end

ind = inpolygon(Traj.Lon,Traj.Lat,poly(:,1),poly(:,2));
ind = ~ind;  % want those outside polygon to be true

% Flag any points outside the domain.  Set any points in time after the
% first flagged value to a flagged value also.
for i = 1:size(ind,1)
    num = find(ind(i,:) == true);
    if ~isempty(num)
        % This is to make sure all positions after the drifter leaves the
        % domain are set to NaN.
        ind(i,num:end) = true; 
    end
end

Traj.Lon(ind) = flag;
Traj.Lat(ind) = flag;

