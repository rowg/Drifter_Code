function writeShapeLines(Lon,Lat,pathFile,Type,time)
% Lon = 2-D matrix, #drifters x #times
%
% NOTES:
%     Lon and Lat should have no rows with all NaN's, ie. any drifter track
%     with all NaN's should have already been removed.


if ~exist('shapewrite.m','file')
    fprintf('shapewrite not found, mapping toolbox probably not installed ...\n')
    fprintf('no shape files created, %s exiting\n',mfilename)
    return;
end


% Loop over every remaining drifter (row) and trim off any nan's
numDrift = size(Lon,1);
for i = 1:numDrift
    ind = find(~isnan(Lon(i,:)));
    tmpLon = Lon(i,ind);
    tmpLat = Lat(i,ind);
    S(i).Lon = tmpLon';
    S(i).Lat = tmpLat';
    % Compute the start and stop times.
    S(i).StartTime = datestr(time(ind(1)),31);
    S(i).EndTime = datestr(time(ind(end)),31);
end
    
[S(1:numDrift).Geometry] = deal('PolyLine');
[S(1:numDrift).Type] = deal(Type);


% Write to shapefile
shapewrite(S, pathFile);

% Copy projection file template for new file set if it can be found
projTemp = 'shpProjTemp.prj';
if exist(projTemp,'file')
    projTemp = which(projTemp);
    projFile = strrep(pathFile,'.shp','.prj');
    copyfile(projTemp, projFile);
else
    fprintf('Can''t find %s in search path - no .prj file written\n', ...
             projTemp);
end
         
% Create a zip file of all shape file parts created in this hour
% Make the wildcard list of all the files for this hour.
zipList = strrep(pathFile,'.shp','.*');
zipName = strrep(pathFile,'.shp','');
% Now get rid of the file name
system(['zip -j ',zipName,' ',zipList]);

% Delete the shape files and keep only the zip file
shapeTypes = {'dbf','prj','shp','shx'};
for j = 1:numel(shapeTypes)
    if exist([zipName,'.',shapeTypes{j}],'file')
        delete([zipName,'.',shapeTypes{j}]);
    end
end
