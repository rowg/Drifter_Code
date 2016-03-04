function conf = MNTY_conf
%%
% Call default configuration driver, then change only the settings that are
% necessary for the MNTY domain.

% Get a set of default config parameters - see HFRPdriver_default_conf for
% a list of parameters that will be set to default if not specified.
conf = HFRPdriver_default_conf;

% Program parameters
% Base directory for ???.
baseDir = '/Users/cook/';
baseConfDir = fullfile(baseDir,'HFR_Progs','matlab','HFR_COCMP','data');
baseResultsDir = fullfile(baseDir,'HFR_Results');
baseRadialDir = '/Volumes/Extras/RealTime_Archive/Data/';

% Reset all the parameters needed for the MNTY case

%% Config parameters for getting and processing Radials
% Where are the radials located up to the site name
conf.Radials.BaseDir = baseRadialDir;
conf.Radials.Sites = {'PESC','BIGC','SCRZ','MLML','NPGS','PPIN','GCYN','PSUR'};
conf.Radials.Types = {'RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi'};

numSites = length(conf.Radials.Sites);
for k = 1:numSites
    conf.Radials.FilePrefix{k} = [conf.Radials.Types{k},'_',conf.Radials.Sites{k},'_'];
end

conf.Radials.RangeLims =  [2.9257, 2.9257,  84.8453;
                           2.9257, 2.9257,  90.6987;
                           3.0341, 3.0341,  81.9207;
                           1.9980, 0.9980,  29.9700;
                           1.4895, 1.4895,  56.6010;
                           3.0341, 3.0341,  81.9207;
                           3.0341, 0.0341, 103.1594;
                           2.9257, 2.9257,  84.8453];
                           %0,5,50]; % PURPOSELY MAKE INTERP FAIL FOR PSUR
                       
conf.Radials.BearLims = [ 83,5,288;
                         132,5,307;
                         153,5,3  ;
                         115,5,255;
                          58,5,153;
                          62,5,257;
                         106,5,281;
                          80,5,305]; 
                          %83,5,308]; % Purposely fail
                          
% Make numSites x 2, with 1st col=0.3, 2nd col=0.5
conf.Radials.RangeBearSlop = ones(numSites,1) * [0.3, 0.5];
conf.Radials.MaskFiles = strcat(conf.Radials.Sites,'Mask.txt')';
conf.Radials.MaskFiles = fullfile_multiple(baseConfDir,'masks', ... 
                         conf.Radials.MaskFiles );

%% Config parameters for making totals from radials
conf.Totals.DomainName = 'MNTY';
conf.Totals.CreationInfo = 'Mike Cook - NPS';
% TUV output directory
conf.Totals.BaseDir = fullfile(baseResultsDir,'Data',conf.Totals.DomainName,'tuv');
conf.Totals.FilePrefix = strcat('tuv_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix = '.mat';
conf.Totals.GridFile = fullfile(baseConfDir,'grids','MNTY.grid');
conf.Totals.spatthresh = 3;  % Km
conf.Totals.tempthresh = 1/24/2-eps;
conf.Totals.MaxTotSpeed = 100;
% Needs to be a cell array of cell arrays
conf.Totals.cleanTotalsVarargin = { { 'GDOPMaxOrthog','TotalErrors',2 } };

conf.Totals.MaskFile = '';

%% OMA
conf.OMA.ModesFileName = 'MNTY_10kmB_10kmS.mat';
conf.OMA.BaseDir = fullfile(baseResultsDir,'Data',conf.Totals.DomainName,'oma');
conf.OMA.HourPlotDir = strrep(conf.OMA.BaseDir,'Data','Plots');

%% Generic config parameters for making plots (totals and radials)

% SEEMS TO NEED THE .mat - without it won't load.
conf.Plot.coastFile = fullfile(baseConfDir,'coasts','COCMP_coast.mat');
conf.Plot.Projection = 'lambert';
conf.Plot.plotBasemap_xargs = {'patch',[.5 .9 .5],'edgecolor','k'};
conf.Plot.m_grid_xargs = {'linewidth',2,'linestyle','--','tickdir','out','fontsize',18,'box','fancy' };
conf.Plot.Speckle = true;


%% Config parms for the hourly TUV plot

conf.HourPlot.BaseDir = strrep(conf.Totals.BaseDir,'Data','Plots');
conf.HourPlot.DomainName = conf.Totals.DomainName;
% conf.HourPlot.Type = 'OMA';
% % % conf.HourPlot.FilePrefix = strcat(conf.HourPlot.Type,...
% % %   '_',conf.HourPlot.DomainName,'_');

% Defaults to axisLims( Data, 0.1 ) if not given
%conf.HourPlot.axisLims = [-122.42,-121.7,36.5,37.05];
conf.HourPlot.axisLims = [-123.45,-121.7,36.2,37.05];

% % % conf.HourPlot.VectorScale = 0.015;
conf.HourPlot.VectorScale = 0.015/2;
conf.HourPlot.VelocityScaleLength = 25;
conf.HourPlot.VelocityScaleLocation = [-121.8333, 37.01];

% Location to put a velocity scale.  Defaults to 10% from upper right corner.
conf.HourPlot.DistanceBarLength = 10;
conf.HourPlot.DistanceBarLocation = [-121.82,36.51];
%Color scale to use for plotting vectors. Defaults to 0:10:max_velocity+10.
% % % conf.HourPlot.ColorTicks = 5:5:50;
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
conf.IndivRadialPlot.BaseDir = fullfile(baseResultsDir,'Plots');
conf.IndivRadialPlot.CoverFilePrefix = 'Cover_';
conf.IndivRadialPlot.CurrentFilePrefix='Curr_';

%%
conf.meanTUV.Type = conf.HourPlot.Type;
conf.meanTUV.DomainName = conf.Totals.DomainName;
conf.meanTUV.BaseDir = fullfile(baseResultsDir,'Data',conf.Totals.DomainName,'tuvAVG');
% % % conf.meanTUV.FilePrefix = strcat('tuv_',conf.Totals.DomainName,'_');
conf.meanTUV.FileSuffix = '.mat';
conf.meanTUV.PlotDir = strrep(conf.meanTUV.BaseDir,'Data','Plots');
conf.meanTUV.Thresh = 18;   % how many hours required to plot mean arrow.
conf.meanTUV.avgTime = 25;  % # hours in averaging period

%%
conf.Traj.BaseDir = fullfile(baseResultsDir,'Data',conf.Totals.DomainName,'traj');
conf.Traj.FilePrefix = strcat('trj_',conf.Totals.DomainName,'_');
conf.Traj.FileSuffix = conf.Totals.FileSuffix;
conf.Traj.MinTimes = 12;

x = linspace(-122,-122.3333,6);
y=linspace(36.5,36.9,5);
[X,Y]=meshgrid(x,y);
conf.Traj.StartLoc=[X(:), Y(:)];

conf.Traj.PlotDir = strrep(conf.Traj.BaseDir,'Data','Plots');

