function conf = MNTY_conf
%%
% Call default configuration driver, then change only the settings that are
% necessary for the MNTY domain.

% Get a set of default config parameters - see HFRPdriver_default_conf for
% a list of parameters that will be set to default if not specified.
conf = HFRPdriver_default_conf;

% Program parameters
% Base directories.
baseDir = '/Users/cocmpmb/';
baseConfDir = fullfile(baseDir,'HFR_Progs','matlab','HFR_COCMP','data');
baseResultsDir ='/Volumes/Extras/RealTime/Data/';
baseRadialDir = '/Volumes/Extras/RealTime/Data/Radials/';

% IT IS CRITICAL THIS IS SET TO THE PROPER DOMAIN NAME.  MANY VARIABLES SET
% BELOW USE THIS VARIABLE.
domain = 'MNTY';

%% Config parameters for getting and processing Radials
% Where are the radials located up to the site name
conf.Radials.BaseDir = baseRadialDir;
conf.Radials.MonthFlag = false;
conf.Radials.TypeFlag = false;
conf.Radials.Sites = {'MONT','PILR','PESC','BIGC','SCRZ','MLML','NPGS','PPIN','GCYN','PSUR','PSLR','RAGG'};
conf.Radials.Types = {'RDLm','RDLi','RDLi','RDLi','RDLm','RDLi','RDLm','RDLi','RDLi','RDLi','RDLi','RDLm'};

numSites = length(conf.Radials.Sites);
for k = 1:numSites
    conf.Radials.FilePrefix{k} = [conf.Radials.Types{k},'_', ...
                                  conf.Radials.Sites{k},'_'];
end

% Don't define conf.Radials.RangeLims and conf.Radials.BearLims.  interpRadials
% will then use unique ranges and unique bearings.
 conf.Radials.RangeLims = [];
 conf.Radials.BearLims =  [];

% Make numSites x 2, with 1st col=0.3, 2nd col=0.5
conf.Radials.RangeBearSlop = ones(numSites,1) * [0.3, 0.5];
conf.Radials.MaskFiles = strcat(conf.Radials.Sites,'Mask.txt')';
conf.Radials.MaskFiles = fullfile_multiple(baseConfDir,'masks','ruv', ... 
                         conf.Radials.MaskFiles );
% Web stuff
conf.Radials.WebWrite = true;
conf.Radials.WebBase = '/Library/WebServer/Documents/images';
conf.Radials.WebName = ['ruv_',domain,'_latest.gif'];

%% Config parameters for making totals from radials
conf.Totals.DomainName = domain;
conf.Totals.CreationInfo = 'Mike Cook - NPS';
% TUV output directory
conf.Totals.BaseDir = fullfile(baseResultsDir,'Totals',conf.Totals.DomainName);
conf.Totals.FilePrefix = strcat('tuv_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix = '.mat';
% conf.Totals.GridFile = fullfile(baseConfDir,'grids', ...
%                                 [conf.Totals.DomainName,'.grid']);
conf.Totals.GridFile ='/Users/hroarty/Documents/MATLAB/HFR_Progs-2_1_3beta/matlab/demo/OtherDataFiles/cocmpMNTY.grid';              
                            
conf.Totals.spatthresh = 3;  % Km
conf.Totals.tempthresh = 1/24/2-eps;
conf.Totals.MaxTotSpeed = 100;
% Needs to be a cell array of cell arrays
conf.Totals.cleanTotalsVarargin = { { 'GDOPMaxOrthog','TotalErrors',2 } };

conf.Totals.MaskFile = '';

% GIS shape write stuff
conf.Totals.ShapeWrite = true;

% Web stuff
conf.Totals.WebWrite = true;
conf.Totals.WebBase = '/Library/WebServer/Documents/images';
conf.Totals.WebName = ['tuv_',conf.Totals.DomainName,'_latest.gif'];

%% OMA
conf.OMA.ModesFileName = [conf.Totals.DomainName,'_OMA_Domain.mat'];
conf.OMA.BoundaryFileName = [conf.Totals.DomainName,'_OMA_Boundary.mat'];
conf.OMA.BaseDir = fullfile(baseResultsDir,'Oma', ...
                            conf.Totals.DomainName);
conf.OMA.HourPlotDir = strrep(conf.OMA.BaseDir,'Data','Plots');

% Web stuff
conf.OMA.WebWrite = true;
conf.OMA.WebBase = '/Library/WebServer/Documents/images';
conf.OMA.WebName = ['oma_',conf.Totals.DomainName,'_latest.gif'];

conf.OMAerror.WebName=['oma_error_',conf.Totals.DomainName,'_latest.gif'];

%% Generic config parameters for making plots (totals and radials)

% SEEMS TO NEED THE .mat - without it won't load.
% I think the lambert projection may be the problem with the trajectories,
% lets try mercator - also make a new, bigger coastline to include the PSLR
% data.
% conf.Plot.coastFile = fullfile(baseConfDir,'coasts','COCMP_coast.mat');
% conf.Plot.Projection = 'lambert';
conf.Plot.coastFile = fullfile(baseConfDir,'coasts','COCMP_Big_mercat.mat');
conf.Plot.Projection = 'Mercator';
conf.Plot.plotBasemap_xargs = {'patch',[.5 .9 .5],'edgecolor','k'};
conf.Plot.m_grid_xargs = {'linewidth',2,'linestyle','--', ...
                          'tickdir','out','fontsize',18,'box','fancy' };
conf.Plot.Speckle = true;

conf.Plot.PaperWidth = 11;
conf.Plot.PaperHeight= 11;


%% Config parms for the hourly TUV plot

conf.HourPlot.BaseDir = strrep(conf.Totals.BaseDir,'Data','Plots');
conf.HourPlot.DomainName = conf.Totals.DomainName;
% conf.HourPlot.Type = 'OMA';
% % % conf.HourPlot.FilePrefix = strcat(conf.HourPlot.Type,...
% % %   '_',conf.HourPlot.DomainName,'_');

% Defaults to axisLims( Data, 0.1 ) if not given
conf.HourPlot.axisLims = [-123.45,-121.7,36.2,37.05];

% % % conf.HourPlot.VectorScale = 0.015;
conf.HourPlot.VectorScale = 0.015/2;
conf.HourPlot.VelocityScaleLength = 25;
conf.HourPlot.VelocityScaleLocation = [-121.8333, 37.01];

% Location to put a velocity scale.  Defaults to 10% from upper right corner.
conf.HourPlot.DistanceBarLength = 10;
conf.HourPlot.DistanceBarLocation = [-121.82,36.51];
%  Color scale to use for plotting vectors.  Defaults to 
%  0:10:max_velocity+10 if not supplied.
conf.HourPlot.ColorTicks = 0:10:80;
% % % conf.HourPlot.ColorMap = 'jet';
conf.HourPlot.plotData_xargs = {}; %
%conf.HourPlot.TitleString = {};
conf.HourPlot.Print = false;


%% Config parameters for making the whole domain radial plots

conf.RadialPlot.BaseDir = conf.HourPlot.BaseDir;
conf.RadialPlot.DomainName = conf.Totals.DomainName;
conf.RadialPlot.Type = conf.HourPlot.Type;
conf.RadialPlot.RadialType = 'Rorig'; %'RTUV'
conf.RadialPlot.FilePrefix = strcat('Rad_',conf.HourPlot.DomainName,'_');
conf.RadialPlot.axisLims = conf.HourPlot.axisLims;  % [-123.55,-121.45,35.45,38];
conf.RadialPlot.DistanceBarLength = conf.HourPlot.DistanceBarLength;
%conf.RadialPlot.ColorOrder = Defaults to get(gca,'colororder') before clearing plot.
conf.RadialPlot.DistanceBarLocation = conf.HourPlot.DistanceBarLocation;
conf.RadialPlot.plotData_xargs = {};
%conf.RadialPlot.TitleString = {};
conf.RadialPlot.Print = false; %true

%% For hourly individual radial coverage/interpolation and currents.
conf.IndivRadialPlot.BaseDir = strrep(baseResultsDir,'Data','Plots');
conf.IndivRadialPlot.BaseDir = fullfile(conf.IndivRadialPlot.BaseDir, ...
                               'Radials');
conf.IndivRadialPlot.CoverFilePrefix = 'Cover_';
conf.IndivRadialPlot.CurrentFilePrefix='Curr_';

%%
conf.meanTUV.Type = conf.HourPlot.Type;
conf.meanTUV.DomainName = conf.Totals.DomainName;
conf.meanTUV.BaseDir = fullfile(baseResultsDir,'AverageTotals', ...
                                conf.Totals.DomainName);
% Web stuff
conf.meanTUV.WebWrite = true;
conf.meanTUV.WebBase = '/Library/WebServer/Documents/images';
conf.meanTUV.WebName = ['tuvAvg_',conf.Totals.DomainName,'_latest.gif'];

% % % conf.meanTUV.FilePrefix = strcat('tuv_',conf.Totals.DomainName,'_');
conf.meanTUV.FileSuffix = '.mat';
conf.meanTUV.PlotDir = strrep(conf.meanTUV.BaseDir,'Data','Plots');
conf.meanTUV.Thresh = 18;   % how many hours required to plot mean arrow.
conf.meanTUV.avgTime = 25;  % # hours in averaging period

%% Actual trajectory confs
conf.Traj.BaseDir = fullfile(baseResultsDir,'Trajectories', ...
                             conf.Totals.DomainName);
conf.Traj.FilePrefix = strcat('trj_',conf.Totals.DomainName,'_');
conf.Traj.FileSuffix = conf.Totals.FileSuffix;
conf.Traj.MinTimes = 15;

% GIS shape file write.
conf.Traj.ShapeWrite = true;

% Web stuff
conf.Traj.WebWrite = true;
conf.Traj.WebBase = '/Library/WebServer/Documents/images';
conf.Traj.WebName = ['trj_',conf.Totals.DomainName,'_latest.gif'];

% The grid - may want to make a file - need data in a grid for GNOME and
% particle_track_ode_grid_LonLat.m
dat=load(conf.Totals.GridFile);
[LonGrid,LatGrid] = meshgrid_vector_data(dat(:,1),dat(:,2));
% Decimate
LonGrid = LonGrid(1:3:end,1:3:end);
LatGrid = LatGrid(1:3:end,1:3:end);
conf.Traj.StartLoc=[LonGrid(:), LatGrid(:)];

conf.Traj.PlotDir = strrep(conf.Traj.BaseDir,'Data','Plots');

%% Actual animation confs
conf.TrajAnim.convCommand = '/ImageMagick-6.4.0/bin/convert';
% % conf.TrajAnim.convCommand = '/sw/bin/convert';
conf.TrajAnim.convFlags = '-delay 15 -loop 0';
conf.TrajAnim.tmpDir = [baseDir,conf.Totals.DomainName,'_TRAJ_TMP_FRAMESDir'];
conf.TrajAnim.timeStep = 1/2/24;  % expressed in hours
conf.TrajAnim.trajColor = 'k';
conf.TrajAnim.tailLen = 12;  % expressed in time steps
conf.TrajAnim.headSize = 22;
conf.TrajAnim.PlotDir = conf.Traj.PlotDir;
conf.TrajAnim.FilePrefix = strcat('trjAnim_',conf.Totals.DomainName,'_');
conf.TrajAnim.FileSuffix = '.gif';

% Web stuff
conf.TrajAnim.WebWrite = true;
conf.TrajAnim.WebBase = '/Library/WebServer/Documents/images';
conf.TrajAnim.WebName = ['trjA_',conf.Totals.DomainName,'_latest.gif'];

%% Predicted trajectory confs
conf.predTraj.BaseDir=fullfile(baseResultsDir,'PredictedTrajectories', ...
                               conf.Totals.DomainName);
conf.predTraj.FilePrefix = strcat('pred_',conf.Traj.FilePrefix);
conf.predTraj.FileSuffix = conf.Traj.FileSuffix;
conf.predTraj.StartLoc = conf.Traj.StartLoc;
conf.predTraj.PlotDir = strrep(conf.predTraj.BaseDir,'Data','Plots');

% Web stuff
conf.predTraj.WebWrite = true;
conf.predTraj.WebBase = '/Library/WebServer/Documents/images';
conf.predTraj.WebName = ['trjp_',conf.Totals.DomainName,'_latest.gif'];

% Locations needed for prediction must be a on a rectangular grid.
conf.predTraj.Lon = LonGrid;
conf.predTraj.Lat = LatGrid;

%% These are the confs for the predicted tide, which will be used for the
% GNOME predicted U/V's and the predicted trajectories.
% Number of past U/V fields to use in tidal analysis for prediction.
conf.predUV.pastHours = 72; 
% # of UV fields that must be present to proceed.
conf.predUV.minGoodHours = 48;
% Interpolation time step, can be other than 1 hour, but generally set to 1
% hour.  This is to fill in individual gridpoints to reduce the gapiness.
conf.predUV.interpTimeStep = 1;
% Gaps bigger than this will be left uninterpolated.
conf.predUV.maxGap = 3;
% How far, in hours, to predict into the future.
conf.predUV.predicTime = 25;
% Number of actual hours in the past to consider in the mean to add to the
% tidal prediction
conf.predUV.actHours = 24;
% min # of good hours in actHours that must be present for predicted U/V to
% be written to output struct.
conf.predUV.minGoodMeanHrs = 18;

% THESE 4 LINES AREN'T IN THE SFOO_conf.m and ANVO_conf.m, IS THIS A
% PROBLEM?
conf.predUV.writeFlag = true;
conf.predUV.BaseDir = fullfile(baseResultsDir,'PredictedOma', ...
                            conf.Totals.DomainName);
conf.predUV.FilePrefix = [ 'pred_oma_' conf.Totals.DomainName '_' ];
conf.predUV.FileSuffix = '.mat';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
%% Predicted animation confs
conf.predTrajAnim.tmpDir = [baseDir,conf.Totals.DomainName,'_PREDTRAJ_TMP_FRAMESDIR'];
conf.predTrajAnim.timeStep = conf.TrajAnim.timeStep;
conf.predTrajAnim.trajColor = 'm';
conf.predTrajAnim.tailLen = conf.TrajAnim.tailLen;
conf.predTrajAnim.headSize = conf.TrajAnim.headSize;
conf.predTrajAnim.PlotDir = conf.predTraj.PlotDir;
conf.predTrajAnim.FilePrefix = strcat('pred_',conf.TrajAnim.FilePrefix);
conf.predTrajAnim.FileSuffix = conf.TrajAnim.FileSuffix;

% Web stuff
conf.predTrajAnim.WebWrite = true;
conf.predTrajAnim.WebBase = '/Library/WebServer/Documents/images';
conf.predTrajAnim.WebName = ['trjAp_',conf.Totals.DomainName,'_latest.gif'];

%% GNOME netcdf confs
conf.GNOME.BaseDir = fullfile(baseResultsDir,'Gnome', ...
                              conf.Totals.DomainName);

