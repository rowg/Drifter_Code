function [ofout,success] = convertPlot(ofn, outType, rmOrig)

% This function uses the imagik function convert to convert a file
% from one format to another.  Usually this is to convert a postscript
% file into a gif or jpeg, which can then be placed on a web page.
%
% Usage:
%        [ofout,success] = convertPlot('test.ps','
%
% Inputs:
%        ofn - path/name of file to convert.  IT IS ASSUMED THAT THE
%        FILE HAS AN EXTENSION AND IT IS THE TYPE OF GRAPHIC CONTAINED
%        IN THE FILE.  Example test.ps contains a postscript file, not
%        a jpeg, or gif, or whatever.
%        outType - type of graphic to convert ofn
%        rmOrig - delete original? true or false
%
% Outputs:
%        ofout - name of output file - name of input file
%        with the outType replacing the original extension.
%        success - if convert created a new file success=true
%        otherwise success=false, and ofn is NOT deleted no matter
%        what rmOrig is set to.
%
%        Mike Cook

% Set the default values
if ~exist('outType','var') || isempty(outType)
    outType = 'gif';
end
if ~exist('rmOrig','var') || isempty(rmOrig)
    rmOrig = true;
end

convert = '/ImageMagick-6.4.0/bin/convert';

% Set up default output (set for failure by default)
ofout = '';
success = false;

% Find the '.' extension
ind = strfind(ofn,'.');
if isempty(ind)
    fprintf('Can''t find file extension, so can''t convert %s\n',ofn)
    fprintf('%s exiting\n',mfilename);
    return;
end

ofout = strrep(ofn,ofn(ind(end):end),['.',outType]);
[status,result]=system(['source /Users/cocmpmb/.bashrc;',convert,' ',ofn,' ',ofout]);

% If the system call returns a 0, then convert is successful, any other number
% means there was a problem.
if status == 0
    if rmOrig
        delete(ofn);
    end
    success = true;
else
    fprintf('Problem converting %s using %s\n',ofn,convert);
    fprintf('system command returned\n')
    fprintf('Status = %d\n',status)
    fprintf('Result = %s\n',result)
    fprintf('%s Will NOT BE DELETED if it was requested\n',ofn);
    ofout = '';
end

