function COCMPdriver_calcTraj( times, p, varargin )

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters and parameter checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = HFRPdriver_default_conf( p );

% Merge
mand_params = { };
p = checkParamValInputArgs( p, {}, mand_params, varargin{:} );

%%
try, p.OMA.DomainName;
catch
  p.OMA.DomainName = p.Totals.DomainName;
end

try, p.OMA.FilePrefix;
catch
  p.OMA.FilePrefix = [ 'oma_' p.OMA.DomainName '_' ];
end

try, p.Traj.ShapeWrite;
catch
    p.Traj.ShapeWrite = false;
end

try, p.Traj.MinTimes;
catch
    p.Traj.MinTimes = fix(length(times)/2);
end

% s = p.meanTUV.Type;


%%
[f] = datenum_to_directory_filename( p.OMA.BaseDir, times, ...
                                     p.OMA.FilePrefix, ...
                                     p.OMA.FileSuffix, p.MonthFlag );
[TUV,goodCount] = catTotalStructs(f,'TUV');
numTimes = length(f);

% Now mean
fprintf('File Loading: %d of %d hours present\n',goodCount,numTimes);

if goodCount < p.Traj.MinTimes
    fprintf('Not enough times for traj calculation\n')
    return;
end

% GET FROM CONF
modes_fn = p.OMA.ModesFileName;
% modes_fn = 'MNTY_10kmB_10kmS.mat';

% The particle starting locations - GET FROM CONF
LL = p.Traj.StartLoc;

% Get some good option values for tracking - otherwise output is junk.
abs_tol = 1.0e-3; % Not sure about this
rel_tol = 1.0e-3; % Not sure about this
maxstep = 1/24/2; % 1/4 hour  
options = odeset('RelTol',rel_tol,'AbsTol',abs_tol,'MaxStep',maxstep);

TRAJoma = generate_trajectories_from_OMA_fit( TUV, modes_fn, ...
                                              TUV.TimeStamp([1,end]), ...
                                              LL );


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[tdn,tfn] = datenum_to_directory_filename( p.Traj.BaseDir, times(end), ...
                                           p.Traj.FilePrefix, ...
                                           p.Traj.FileSuffix, p.MonthFlag );
tdn = tdn{1};
if ~exist( tdn, 'dir' )
  mkdir(tdn);
end
save(fullfile(tdn,tfn{1}),'TRAJoma')


%%%%%%%%%%%%%%%%%%%%%%% GIS %%%%%%%%%%%%%%%%%%%
if p.Traj.ShapeWrite
    % Code patch for Shape write procedure
    % Create the directory and filename
    [gdn,gfn] = datenum_to_directory_filename(p.Traj.BaseDir, times(end), ...
                                              p.Traj.FilePrefix, ...
                                              '.shp', p.MonthFlag);
    gdn = gdn{1};
    % Add the GIS subdirectory to the directory tree.
    gisDir = fullfile(char(gdn),'gis_shapefile');

    % Create the gis shapefile directory if it doesn't exist.
    if ~exist(gisDir,'dir')
        mkdir(gisDir)
    end
    TRAJstruct2shape(TRAJoma,fullfile(gisDir,gfn{1}));
end
%%%%%%%%%%%%%%%%%%%%%%% GIS %%%%%%%%%%%%%%%%%%%
