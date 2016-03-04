function hotClean(BaseDir,Site,Type,Num2Keep,Ext,debug)

% Program to check if the file exists in the realtime yyyy_mm directory, if
% so copy it from the hot directory.  Keep only a few days in the hot
% directory after this check.
if ~exist('Num2Keep','var')
    Num2Keep = 72;  % in hours
end
if ~exist('Ext','var')
    Ext = 'ruv';
end
if ~exist('debug','var')
    debug = false;
end

% Get a HOT dir listing of radar type "site"
% Full path is BaseDir/Site
% File name is assumed to be:  Type_Site_yyyy_mm_dd_hhmm.Ext
d = dir(fullfile(BaseDir,Site,[Type,'_','*.',Ext]));
numFiles = numel(d);

if numFiles == 0
    % If the hot directory contains none of these files, warn and exit
    fprintf('*****%s: no files match %s\n*****Exiting\n',mfilename, ...
            fullfile(BaseDir,Site,[Type,'_','*.',Ext]));
    return;
end

% See if they exist in the proper yyyy_mm directory
% Full path is:  BaseDir/Site/Type/yyyy_mm
for i = 1:numFiles
    % Must create the yyyy_mm portion of the directory - rely on fact that
    % radar files will ALWAYS be of the form RDLx_SITE_yyyy_mm_dd_hhmm.ruv
    yyyy_mm = d(i).name(11:17);
    dn = fullfile(BaseDir,Site,Type,yyyy_mm);
    if ~exist(fullfile(dn,d(i).name),'file')
        % make directory if nessary
        if ~exist(dn,'dir')
            if debug
                fprintf('+++Making %s\n',dn);
            end
            mkdir(dn);
        end
        % copy file to directory
        if debug
            fprintf('@@@Copying %s to %s\n', ...
                            fullfile(BaseDir,Site,d(i).name), ...
                            fullfile(BaseDir,Site,Type,yyyy_mm,d(i).name));
        end
        copyfile(fullfile(BaseDir,Site,d(i).name), ...
                 fullfile(BaseDir,Site,Type,yyyy_mm,d(i).name));
    end
end

% Now decide how many files to keep in the hot directory
if numFiles > Num2Keep
    for i = 1:numFiles-Num2Keep
        if debug
            fprintf('***Deleting %s\n',fullfile(BaseDir,Site,d(i).name));
        end
        delete(fullfile(BaseDir,Site,d(i).name));
    end
end
