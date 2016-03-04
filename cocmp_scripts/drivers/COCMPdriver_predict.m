function COCMPdriver_predict( D, p, varargin )
% Tidal analysis and prediction, predicted Trajs, and GNOME netcdf write.

%% Set defaults and check
p = HFRPdriver_default_conf( p );

% Merge
mand_params = { 'predUV.pastHours', 'predUV.minGoodHours', ...
                'predUV.interpTimeStep', 'predUV.maxGap', ...
                'predUV.predicTime', 'predUV.actHours', ...
                'predUV.minGoodMeanHrs','predTraj.StartLoc', ...
                'Totals.DomainName'};
p = checkParamValInputArgs( p, {}, mand_params, varargin{:} );


try, p.OMA.DomainName;
catch
  p.OMA.DomainName = p.Totals.DomainName;
end

try, p.OMA.FilePrefix;
catch
  p.OMA.FilePrefix = [ 'oma_' p.OMA.DomainName '_' ];
end

try, p.predUV.writeFlag;
catch
    p.predUV.writeFlag = false;
end

%% Parameters section - these will be passed in when functionalized

% Tidal analysis confs, the number of hours to use in the t_tide analysis,
% and the minumum number of hours acceptable to do the analysis.
% minGoodHours checks to see if the whole field is there, it doesn't check
% gridpoint by gridpoint.
pastHours = p.predUV.pastHours; % In hours
minGoodHours = p.predUV.minGoodHours; % In Hours
% Interpolation confs - interpolate any missing fields up to a gap of
% maxGap hours - gaps bigger than that will remain gaps.
interpTimeStep = p.predUV.interpTimeStep; % In Hours from conf file
% Convert to days.
interpTimeStep = interpTimeStep/24;
maxGap = p.predUV.maxGap;  % In Hours from conf, convert to days
maxGap = maxGap/24;  
predicTime = p.predUV.predicTime; % In Hours from conf 
% Convert to days
predicTime = predicTime/24;
actHours = p.predUV.actHours;  % Number of actual hours to write to file
% Number of good actual hours for prediction to be valid
minGoodMeanHrs=p.predUV.minGoodMeanHrs;  

% Number of hours in past relative to D
% % % analysisTime = D-(conf.meanTUV.avgTime-1)/24:1/24:D+eps;
analysisTime = D-(pastHours-1)/24:1/24:D;

fprintf('******* %s: Current time: %s\n === Processing data from %s to %s\n', ...
        mfilename,datestr(now,0), ...
        datestr(analysisTime(1),0), ...
        datestr(analysisTime(end),0));

% THIS WILL BE A CONF PARAMETER
% OMA or TOTALS - either one will have the TUV struct in my scheme.
%s = p.meanTUV.Type;
s = 'OMA';


%% Concat all the data
[f] = datenum_to_directory_filename( p.(s).BaseDir, analysisTime, ...
                                     p.(s).FilePrefix, ...
                                     p.(s).FileSuffix, p.MonthFlag );
[TUVcat,goodCount] = catTotalStructs(f,'TUV');
numTimes = length(f);


% Now check to see if minimum number of times (TUV fields) are present.
fprintf('Temporal Concatenating: %d of %d hours present\n',goodCount,numTimes);
if goodCount < minGoodHours
    fprintf('No tidal prediction for %s to %s\', ...
             datestr(analysisTime(1)), datestr(analysisTime(end)));
    return
end

% Remove any extra currents off the end of the OMA struct if necessary.
try
    TUVcat.U = TUVcat.U(1:end-TUVcat.OtherMetadata.AddUV.Number,:);
    TUVcat.V = TUVcat.V(1:end-TUVcat.OtherMetadata.AddUV.Number,:);
    TUVcat.LonLat = TUVcat.LonLat(1:end-TUVcat.OtherMetadata.AddUV.Number,:);
    TUVcat.Depth = TUVcat.Depth(1:end-TUVcat.OtherMetadata.AddUV.Number);
catch
    disp('No extra currents on the end')
end

%% interpolation step
% Use the analysis time - that should contain all hours of interest
intTime = analysisTime(1):interpTimeStep:analysisTime(end);
% Move start time up alittle and end time back alittle so interp function
% calculates values at the endpoints.  eps won't cut it.
% add 0.05 seconds
addT = 0.05 / 86400;
intTime(1) = intTime(1) + addT;
intTime(end) = intTime(end) - addT;
Ti = temporalInterpTotals(TUVcat,intTime,maxGap);

%% Tide analysis step
% t_tide yields many warning - turn off
% This is the warning:
% Warning: FINITE is obsolete and will be removed in future versions. Use
% ISFINITE instead.
% Use 'wboot' option - by default t_tide uses an error option that calls
% the signal processing toolbox.  If you don't have this toolbox,
% t_tide_totals crashes.
warning off
[TideAnal] = t_tide_totals(Ti,minGoodHours/pastHours,true, ...
                     'synthesis',0,'error','wboot');
warning on

%% Do the prediction based on above analysis

% Set up the prediction time vector
predicTime = intTime(end)+interpTimeStep:interpTimeStep:intTime(end)+predicTime+eps;
LonLat = Ti.LonLat;

warning off  % avoid seeing loads of same message as described in 
             % t_tide_totals.
% Predict the tides from above tidal analysis
TUVpredic=t_predic_totals(predicTime,LonLat,TideAnal,true,'synthesis',0);
warning on

%% Add mean from last (set variable, like 24) actual hours to predicted tide.
% Check first to see if enough pts in last 24 hrs to compute mean
% Trim Ti down using subsrefTUV
E = length(Ti.TimeStamp);
S = E - actHours+1;
TUVactual = subsrefTUV(Ti,':',S:E,false,false);
[meanU,count] = nanmean(TUVactual.U,2);
[meanV] = nanmean(TUVactual.V,2);
ind = count < minGoodMeanHrs;
meanU(ind) = NaN;
meanV(ind) = NaN;

TUVpredic.U = TUVpredic.U + repmat(meanU(:),1,length(predicTime));
TUVpredic.V = TUVpredic.V + repmat(meanV(:),1,length(predicTime));

% Add some metadata to the struct.
TUVpredic.OtherMetadata.predUV = p.predUV;

if p.predUV.writeFlag
    % Write the predicted u/v currents to a file.  
    [tdn,tfn] = datenum_to_directory_filename( p.predUV.BaseDir, D, ...
                                               p.predUV.FilePrefix, ...
                                               p.predUV.FileSuffix, ...
                                               p.MonthFlag );
    tdn = tdn{1};
    if ~exist( tdn, 'dir' )
        mkdir(tdn);
    end
    save(fullfile(tdn,tfn{1}),'TUVpredic');
end


%% Grid predicted currents, then calculate the predicted trajectories.

% Let's just calculate the predicted trajectories here, 

% Grid the predicted U/V struc, then call particle_track_ode_grid_LonLat.m
[TUVpredicGrid,predDIM,predIII] = gridTotals(TUVpredic,false,false);
LON = reshape(TUVpredicGrid.LonLat(:,1),predDIM);
LAT = reshape(TUVpredicGrid.LonLat(:,2),predDIM);
U = reshape( TUVpredicGrid.U, [ predDIM, size(TUVpredicGrid.U,2) ] );
V = reshape( TUVpredicGrid.V, [ predDIM, size(TUVpredicGrid.V,2) ] );


% Get some good option values for tracking - otherwise output is junk.
abs_tol = 1.0e-3; % Not sure about this
rel_tol = 1.0e-3; % Not sure about this
maxstep = 1/24/4; % 1/4 hour  
options = odeset('RelTol',rel_tol,'AbsTol',abs_tol,'MaxStep',maxstep);

% The particle starting locations - GET FROM CONF
LL = p.predTraj.StartLoc;

% Particle track, need to get grid stuff out of TUVpredicGrid.
% Usage: [PLon,PLat,TimeStamps] = particle_track_ode_grid_LonLat(Lon,Lat,U,V,tt, ...
% This calculates trajectories and puts in a TRAJ structure with some
% extra metadata (but not much).
PredTRAJoma = ptrack2TRAJstruct('particle_track_ode_grid_LonLat', ...
                         LON,LAT,U,V, ...
                         TUVpredicGrid.TimeStamp, ...
                         TUVpredicGrid.TimeStamp([1,end]), ...
                         LL, options );
% Put some more metadata into the TRAJ struct.
PredTRAJoma.TrajectoryDomain = TUVactual.DomainName;
PredTRAJoma.OtherMetadata.ptrack2TRAJstruct.options = options;

% Write the predicted trajectories to a file.  Then can make a
% predicted movie in another driver.
[tdn,tfn] = datenum_to_directory_filename( p.predTraj.BaseDir, D, ...
                                           p.predTraj.FilePrefix, ...
                                           p.predTraj.FileSuffix, ...
                                           p.MonthFlag );
tdn = tdn{1};
if ~exist( tdn, 'dir' )
    mkdir(tdn);
end
save(fullfile(tdn,tfn{1}),'PredTRAJoma')
                       
%% Cat analysis data and predicted data
% Grid first b/c problem concating act/pred flag and then gridding last.
[TUVactGrid,actDIM,actIII]=gridTotals(TUVactual,false,false);

% Set a true (actual, or real)/false (predicted) flag and place in 
% OtherMatrixVars, then cat whole thing together.
TUVactGrid.OtherMatrixVars.ActualData = true(size(TUVactGrid.U));
TUVpredicGrid.OtherMatrixVars.ActualData = false(size(TUVpredicGrid.U));
% The flagging seems to freak out gridTotals, so don't concat it.  Get
% number of times of actuals and predicted and insert after gridding.
TUVfinalGrid = temporalConcatTUV(TUVactGrid,TUVpredicGrid, ...
                                 false,true); % f=errors,t=OtherMatrixVars


%% write to netcdf file
% BEFORE WRITING OUT TO NETCDF FILE, NEED TO MAKE SURE THE DATA IS
% DIMENSIONED PROPERLY, IE. LON X LAT X TIME, OR TIME X LON X LAT, OR
% WHATEVER - I think I did this, but need to check in GNOME.
LONgnome = LON(1,:);
LATgnome = LAT(:,1);
U = reshape( TUVfinalGrid.U, [ predDIM, size(TUVfinalGrid.U,2) ] );
V = reshape( TUVfinalGrid.V, [ predDIM, size(TUVfinalGrid.V,2) ] );
% Get it time x lat x lon by shifting the dimensions of the 3-D matrices.
U = shiftdim(U,2);
V = shiftdim(V,2);

times = TUVfinalGrid.TimeStamp;
dom = p.Totals.DomainName;
author = p.Totals.CreationInfo;
[odn,ofn]=datenum_to_directory_filename(p.GNOME.BaseDir, ...
                                        TUVactGrid.TimeStamp(end), ...
                                        ['GNOME_',dom,'_'],'.nc',1);
odn = odn{1}; ofn = ofn{1};
ofn = fullfile(odn,ofn);
if ~exist( odn, 'dir' )
    mkdir(odn);
end

writeGnomeNetCDF(dom,LONgnome,LATgnome,times,U,V,ofn, ...
                 [],[],'',author);

