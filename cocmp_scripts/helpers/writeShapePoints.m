function writeShapePoints(Lon, Lat, U, V, pathFile, Type)

% writeShapePoints  Write HFR surface currents to shapefile format
% USAGE:
%   writeShapePoints(Lon, Lat, U, V, pathFile) generates a shapefile
%   containing latitude, longitude, magnitude and bearing of HFR
%   derived surface currents.  THERE MUST BE NO NAN's IN THE INPUT 
%   VARIABLES.  All 5 inputs are required.
%
%   (U,V) are eastward and northward velocities which are
%   converted to magnitude and bearing (deg, cw from true North)
%   The shapefile is written out to pathFile.  Actually 3 files (.dbf,
%   .shp, and .shx) with the same file prefix will be created.
%
%   Input:
%      Lon	m x 1
%      Lat	m x 1
%      U	m x 1
%      V	m x 1
%      pathfile	string
%
%   Important NOTES:   
%       - All input fields MUST be NaN free.
%       - shapewrite is part of the matlab mapping toolbox
%       - The file shpProjTemp.prj contains projection information, and
%           will be included as a 4th output file if it can be found on the 
%           search path.
%
%   A modification of the program hfr_npred_mat2shp.m by Mark Otero.
%
%   Mike Cook


if ~exist('shapewrite.m','file')
    fprintf('shapewrite not found, mapping toolbox probably not installed ...\n')
    fprintf('no shape files created, %s exiting\n',mfilename)
    return;
end

% Convert from Cartesian to polar coordinates and report bearing
% in geographic convention (cw from North)
[Bear, Mag] = cart2pol(U,V);
Bear        = mod(90-Bear*180/pi, 360);
MagKtsHr    = Mag.*0.01944;

% Create geostructure
m = length(U);
[S(1:m).Geometry] = deal('Point');
[S(1:m).Type] = deal(Type);
for I = 1:m
    S(I).Lat              = Lat(I);
    S(I).Lon              = Lon(I);
    S(I).Mag_cmSec        = Mag(I);
    S(I).Mag_ktsHr        = MagKtsHr(I);
    S(I).Bearing          = Bear(I);
end

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

