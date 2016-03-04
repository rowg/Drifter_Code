function COCMPdriver_Totals_OMA( D, p, varargin )
% COCMPDRIVER_TOTALS_OMA - This is an example driver function that
% automates generating totals and doing OMA analysis from radials data
%
% Usage: COCMPdriver_Totals_OMA( TimeStamp, conf, PARAM1, VAL1, ... )
%
% Inputs
% ------
% TimeStamp = Timestamp to work on in datenum format.
% conf = a structure with configuration parameters, can be empty
% PARAMn,VALn = name,value pairs that can override configuration parameters.
%
% Outputs
% -------
% There are no outputs.  All results are stored in mat-files that are in
% directories specified in the configuration parameters below.
%
% Configuration Parameters
% ------------------------
% conf.MonthFlag = whether or not to include month directory in file
%                  paths. Defaults to true.
%
% conf.Radials.BaseDir = base directory.  Defaults to '.'
% conf.Radials.Sites = cellstr of site names.  Must match site names in
%                     RDL files.
% conf.Radials.Types = cellstr of file types, typically 'RDLi' or 'RDLm'.
% conf.Radials.FilePrefix = prefix of filenames for each site+type.
%                          Defaults to [ Types '_' Sites '_' ]
% conf.Radials.FileSuffix = Suffix for each site+type or a single suffix
%                          for all.  Defaults to '.ruv'
% conf.Radials.RangeLims = a Nx3 matrix where N is the number of sites with
%                          range limits for radial interpolation. See
%                          interpRadials for details.
%                          Alternately if not specified, will be set to [ ],
%                          which will set interpRadials to use unique
%                          RangeLims.  Again, see interpRadials for details.
% conf.Radials.BearLims = a Nx3 matrix where N is the number of sites with
%                         bearing limits for radial interpolation. See
%                         interpRadials for details.
%                         As above if not specified, will be set to [ ],
%                         which will set interRadials to use unique BearLims.
%                         Again see interpRadials for details.
% conf.Radials.RangeGap = max range gap in km for radial interpolation.
%                        See interpRadials for details.  Defaults to 2.5.
% conf.Radials.BearGap = max angle gap in array units for radial
%                        interpolation.  See interpRadials for details.
%                        Defaults to 3.5.
% conf.Radials.RangeBearSlop = slops for interpolation, Nx2 matrix where N
%                              is the number of sites.  See interpRadials
%                              for details.  Defaults to 1e-10.
% conf.Radials.MaxRadSpeed = max radial speed for cleanRadials.  Defaults
%                           to 100.
% conf.Radials.MaskFiles = cellstr of mask files for each site+type.
%                         Radials inside each mask will be kept.
%                         Defaults to ''.
%
% conf.Totals.BaseDir = Defaults to '.'
% conf.Totals.DomainName = name of totals domain
% conf.Totals.FilePrefix = Defaults to [ 'tuv_' DomainName '_' ]
% conf.Totals.FileSuffix = Defaults to '.mat'.
% conf.Totals.GridFile = string filename with totals grid to use or a 2
%                        column matrix of LonLat coordinates.
% conf.Totals.MinNumSites = minimum number of sites for generating a
%                           total.  Defaults to 2.
% conf.Totals.MinNumRads = minimum number of radials for generating a
%                          total.  Defaults to 3.
% conf.Totals.spatthresh = spatial window around each totals grid point.
%                          See makeTotals for details.  Defaults to 3.
% conf.Totals.tempthresh = temporal window around each timestep.  See
%                          makeTotals for details.  Defaults to 1/24/2-eps.
% conf.Totals.MaxTotSpeed = maximum totals speed for cleanTotals.
%                           Defaults to 100.
% conf.Totals.cleanTotalsVarargin = Other arguments for cleanTotals.  See
%                                   cleanTotals for details.  Defaults to
%                                   {}.
% conf.Totals.MaskFile = mask file name for totals or a 2 column matrix
%                        of coordinates.  Totals outside mask will be
%                        kept.  Defaults to ''.
%
% conf.OMA.BaseDir = Defaults to '.'
% conf.OMA.DomainName = Defaults to Totals.DomainName.
% conf.OMA.FilePrefix = Defaults to [ 'oma_' DomainName '_' ]
% conf.OMA.FileSuffix = Defaults to '.mat'
% conf.OMA.ModesFileName = Full path of file with modes information.
%                          Defaults to 'modes.mat'.  Set to '' to not do
%                          OMA fits.
% conf.OMA.InterpFileName = Mode interpolation file.  Defaults to
%                           ModesFileName.
% conf.OMA.tempthresh = Defaults to conf.Totals.tempthresh.
% conf.OMA.K = Homogenization smoothing term.  Defaults to 1e-3.
% conf.OMA.ErrorType = See fit_OMA_modes_to_radials for details.
%                      Defaults to 'constant'.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	$Id: HFRPdriver_Totals_OMA.m 471 2007-08-21 22:52:08Z dmk $	
%
% Copyright (C) 2007 David M. Kaplan
% Licence: GPL (Gnu Public License)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters and parameter checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = HFRPdriver_default_conf( p );

% Merge
mand_params = { 'Radials.Sites', 'Radials.Types', 'Radials.RangeLims', ...
                'Radials.BearLims', 'Totals.DomainName', 'Totals.GridFile' };
p = checkParamValInputArgs( p, {}, mand_params, varargin{:} );

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fix default inputs that can only be done afterwards
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try, p.Radials.FilePrefix;
catch
  p.Radials.FilePrefix = strcat( p.Radials.Types, '_', p.Radials.Sites, '_' ...
                                );
end

try, p.Radials.MonthFlag;
catch
    p.Radials.MonthFlag = true;
end

try, p.Radials.RangeBearSlop;
catch
  p.Radials.RangeBearSlop = repmat( 1e-10, [ numel(p.Radials.Sites), 2 ] );
end

try, p.Totals.FilePrefix;
catch
  p.Totals.FilePrefix = [ 'tuv_' p.Totals.DomainName '_' ];
end

try, p.Totals.CreationInfo;
catch
    p.Totals.CreationInfo = mfilename;
end

try, p.Totals.ShapeWrite;
catch
    p.Totals.ShapeWrite = false;
end

try, p.OMA.DomainName;
catch
  p.OMA.DomainName = p.Totals.DomainName;
end

try, p.OMA.FilePrefix;
catch
  p.OMA.FilePrefix = [ 'oma_' p.OMA.DomainName '_' ];
end

try, p.OMA.tempthresh;
catch
  p.OMA.tempthresh = p.Totals.tempthresh;
end

try, p.OMA.InterpFileName;
catch
  p.OMA.InterpFileName = p.OMA.ModesFileName;
end

% Size up FileSuffix if needed. - THIS ONLY WORKS IF THE RESULT IS AN
% INTEGER - THIS ISN'T GUARANTEED - DOESN'T APPEAR TO BE NECESSARY.
% COMMENT OUT FOR NOW - MCOOK.
% % % p.Radials.FileSuffix = repmat( cellstr( p.Radials.FileSuffix ), ...
% % %                                size(p.Radials.FilePrefix)./ ...
% % %                                size(p.Radials.FileSuffix) );

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get filenames together
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F = filenames_standard_filesystem( p.Radials.BaseDir, p.Radials.Sites(:), ...
                                   p.Radials.Types(:), D, p.Radials.MonthFlag, ...
                                   p.Radials.TypeFlag);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Radials work - load in all at once, masking, cleaning interpolation
%
% When loading, for each time, load all radials from all sites in an
% element of a single cell array - this will be useful for later saving
% radials from each time with the appropriate totals files.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Processing radials.');
Rorig = loadRDLFile(F);

% Deal with possible missing files - interpRadials won't work on 0 x n U's
% and V's.
% NOTE: THIS DOESN'T DEAL WITH RADIAL FILES THAT EXIST, HAVE HEADER AND
% TRAILER INFO, BUT NO DATA - MUST FIX.
% sn = { Rorig.SiteName };
% ii = strmatch( '', sn, 'exact' );  % true here means a bad, get rid of it.
%%%%%%%%%%%%%%%%% This is the fix of above code %%%%%%%%%%%%%%%%%%
% Since a file that contains only header information will create a struct
% entry with a SiteName, but 0 x n U,V, and LonLat variable.  Key on one of
% these instead of the SiteName.
ii = false(size(Rorig));
for j = 1:numel(Rorig)
    ii(j) = numel(Rorig(j).U) == 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
missingRadials.FileNames = [ Rorig(ii).FileName ];
[missingRadials.TimeStamps,missingRadials.Sites,missingRadials.Types] ...
    = parseRDLFileName( missingRadials.FileNames );
Rorig(ii) = [];

if isempty(Rorig)
  error( 'No data at this timestep.' );
end

% Get rid of stuff for missing files - if maskfile, rangelims or bearlims
% are missing, just don't do anything
try, p.Radials.MaskFiles(ii) = []; end
try, p.Radials.RangeLims(ii,:) = []; end
try, p.Radials.BearLims(ii,:) = []; end
% DO something with p.Radials.Sites, Types, and FilePrefix to match up with
% maskfiles, etc for later radial plotting.
p.Radials.Sites(ii) = '';
p.Radials.Types(ii) = '';
p.Radials.FilePrefix(ii) = '';
p.Radials.RangeBearSlop(ii,:) = [];

% Do radial cleaning
disp('Radial Cleaning')
Rclean = cleanRadials( Rorig, p.Radials.MaxRadSpeed );

% Do masking
disp('Radial masking')
Rmask = maskRadials( Rclean, p.Radials.MaskFiles, true );

% Interpolation
disp('Radial interpolation')
for n = 1:numel(Rmask)
    % Allow for possibilty of RangeLims and/or BearLims to be not defined.
    try
        RL = p.Radials.RangeLims(n,:);
    catch
        fprintf('Radials.RangeLims(%d,:) not set, will default to [ ]\n',n);
        RL = [];
    end
    try
        BL = p.Radials.BearLims(n,:);
    catch
        BL = [];
        fprintf('Radials.BearLims(%d,:) not set, will default to [ ]\n',n);
    end
        
    % If there is only one radial, or maybe some other conditons that I'm 
    % not thinking of, then the interpolation will fail.  Set up a
    % try/catch block to keep things from failing.
    try
        Rinterp(n) = interpRadials( Rmask(n), ...
                            'RangeLims', RL, ...
                            'BearLims', BL, ...
                            'RangeDelta', p.Radials.RangeBearSlop(n,1), ...
                            'BearDelta', p.Radials.RangeBearSlop(n,2), ...
                            'MaxRangeGap', p.Radials.RangeGap, ...
                            'MaxBearGap', p.Radials.BearGap, ...
                            'CombineMethod', 'average' );
    catch
        fprintf('Warning: ## interpRadials failed for %s ... should find out why\n', ...
                Rmask(n).SiteName);
        Rinterp(n) = Rmask(n);
        Rinterp(n).ProcessingSteps{end+1} = 'Interpolation failed, revert to uninterpolated';
    end
    
    % Check for case of interpolation creating all NaN's.  Use 90 % as the 
    % threshold.  Replace with uninterpolated radials and warn the user.
    if (sum(~isnan(Rinterp(n).U)) < sum(~isnan(Rmask(n).U)) * 0.9)
        fprintf('%s:\n',char(Rinterp(n).FileName));
        fprintf('probably not interpolated properly ... using uninterpolated data instead\n')
        tmp = Rinterp(n).ProcessingSteps;
        Rinterp(n) = Rmask(n);
        Rinterp(n).ProcessingSteps = tmp;
        Rinterp(n).ProcessingSteps{end+1} = 'Revert to uninterpolated';
    end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate totals from radials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[grid,fn,c] = loadDataFileWithChecks( p.Totals.GridFile );
if c >= 100
  error( 'Could not find totals grid.' );
end

disp('Generating totals');

% Make totals
disp('Using interpolated data')
[TUVorig,RTUV]=makeTotals(Rinterp,'Grid',grid,'TimeStamp',D, ...
                         'spatthresh',p.Totals.spatthresh, ...
                         'tempthresh',p.Totals.tempthresh, ...
                         'DomainName',p.Totals.DomainName, ...
                         'CreationInfo','MCook - NPS', ...
                         'WhichErrors',{'GDOPMaxOrthog'});
% Clean totals
[TUVclean,I] = cleanTotals( TUVorig, p.Totals.MaxTotSpeed, ...
                            p.Totals.cleanTotalsVarargin{:} );
fprintf('%d totals removed by cleanTotals\n',sum(I(:)>0))

% Mask totals
[TUV,I]=maskTotals(TUVclean,p.Totals.MaskFile,false);
fprintf('%d totals masked out\n',sum(~I(:)))

%%
% Check for SFOO domain and add SF tide to end of TUV struct
if strcmpi(p.Totals.DomainName,'SFOO') || strcmpi(p.Totals.DomainName,'CENT')
    % % get the sf tide data and convert to u/v components.
    % [u,v,lon,lat,tt]=sfTideproc(43,D);
    
    % get the sf tide data and convert to u/v components.
    fprintf('sfTidepredic.m:  SF current prediction made for %s\n', ...
            datestr(D));
    [u,v,lon,lat]=sfTidepredic('tideConst.mat',D);

    if isnan(u)  ||  isnan(v)
        return;
    end
    
    % Make bearing and heading for false radial structure
    bear = degrees(atan2([v,-u],[u,v]));
    bear(bear<0) = bear(bear<0) + 360;
    head = degrees(atan2([-v,u],[-u,-v]));
    head(head<0) = head(head<0) + 360;
    rc = sqrt(u.^2+v.^2);    

    % DMK : Also want to create a radial structure
    RSFBM = RADIALstruct;
    RSFBM.SiteName = 'SFBMSpecialSite';
    RSFBM.SiteCode = -1;
    RSFBM.FileName = { '' };
    RSFBM.TimeStamp = D;
    RSFBM.LonLat = [lon,lat; lon, lat];
    RSFBM.RangeBearHead = [[0;0],bear(:),head(:)];
    RSFBM.RadComp = [ -rc; 0 ]; 
    RSFBM.Error = NaN(2,1);
    RSFBM.Flag = NaN(2,1);
    [RSFBM.U,RSFBM.V] = deal( [u;0], [v;0] );

    % set up a default TUV struct
    %TT=TUVstruct([1,1]);
    % DMK: Above works, but meanss that TT will not have the same extra variables as TUV
    % DMK: The following is probably better
    TT = subsrefTUV(TUV, 1, 1 );

    % add the data to the struct, make up some reasonable error information.
    TT.U=u;
    TT.V=v;
    TT.LonLat=[lon,lat];
    TT.TimeStamp=D;
    % make up the error
    TT.ErrorEstimates.Uerr = 1;
    TT.ErrorEstimates.Verr = 1;
    TT.ErrorEstimates.UVCovariance = 0;
    TT.ErrorEstimates.TotalErrors = 1;
    
    TUV = spatialConcatTUV(TUV,TT,true,false);
    TUV.OtherMetadata.AddUV.Number = 1;   % How many did you add?

end
    

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save total current results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[tdn,tfn] = datenum_to_directory_filename( p.Totals.BaseDir, D, ...
                                           p.Totals.FilePrefix, ...
                                           p.Totals.FileSuffix, p.MonthFlag );
tdn = tdn{1};

if ~exist( tdn, 'dir' )
  mkdir(tdn);
end
save(fullfile(tdn,tfn{1}),'Rorig','missingRadials','p','RTUV','Rmask', ...
     'Rinterp','TUVorig','TUV' )

% Save the ascii version of the total data
asciiDir = fullfile(char(tdn),'ascii');
if ~exist(asciiDir,'dir')
    mkdir(asciiDir);
end
TUVstruct2ascii(TUV,asciiDir);

%%%%%%%%%%%%%%%%%%%%%%% GIS %%%%%%%%%%%%%%%%%%%
% Code patch for Shape write procedure
if p.Totals.ShapeWrite
    % Create the directory and filename
    [gdn,gfn] = datenum_to_directory_filename(p.Totals.BaseDir, D, ...
                                              p.Totals.FilePrefix, ...
                                              '.shp', p.MonthFlag);
    gdn = gdn{1};
    % Add the GIS subdirectory to the directory tree.
    gisDir = fullfile(char(gdn),'gis_shapefile');

    % Create the gis shapefile directory if it doesn't exist.
    if ~exist(gisDir,'dir')
        mkdir(gisDir)
    end
    TUVstruct2shape(TUV,fullfile(gisDir,gfn{1}));
end
%%%%%%%%%%%%%%%%%%%%%%% GIS %%%%%%%%%%%%%%%%%%%

clear TUV
 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do OMA fits to radials!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check for modes file.  Don't fail
if ~exist( p.OMA.ModesFileName, 'file' ) || ...
      ~exist( p.OMA.InterpFileName, 'file' )
  disp( 'OMA modes or interp file missing. Skipping' );
  return
end

% Standard name
RTUV = Rmask; % Use masked, not interpolated, radials for OMA.

disp('Doing OMA fits');
% DMK: Note that I am adding in the SFBM "radials"
% Check for SFOO domain and add SF tide to end of TUV struct
if strcmpi(p.Totals.DomainName,'SFOO') || strcmpi(p.Totals.DomainName,'CENT')
    RTUV = [RTUV; RSFBM];
end

TUV = fit_OMA_modes_to_radials( RTUV, 'modes_filename', p.OMA.ModesFileName, ...
                                'interp_filename', p.OMA.InterpFileName, ...
                                'K', p.OMA.K, 'TimeStamp', D, 'tempthresh', ...
                                p.OMA.tempthresh, 'error_type', p.OMA.ErrorType ...
                                );
if strcmpi(p.Totals.DomainName,'SFOO') || strcmpi(p.Totals.DomainName,'CENT')
    TUV.OtherMetadata.AddUV.Number = 1;
end
TUV.DomainName = p.OMA.DomainName;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[odn,ofn] = datenum_to_directory_filename( p.OMA.BaseDir, D, p.OMA.FilePrefix, ...
                                           p.OMA.FileSuffix, p.MonthFlag );
odn = odn{1};

if ~exist( odn, 'dir' )
  mkdir(odn);
end

% % save(fullfile(odn,ofn{1}),'Rorig','missingRadials','p','RTUV','TUV','RSFBM')
save(fullfile(odn,ofn{1}),'Rorig','missingRadials','p','RTUV','TUV')

% Save the ascii version of the OMA data
asciiDir = fullfile(char(odn),'ascii');
if ~exist(asciiDir,'dir')
    mkdir(asciiDir);
end
TUVstruct2ascii(TUV,asciiDir);

