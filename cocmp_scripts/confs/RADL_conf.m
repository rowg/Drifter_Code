function conf = RADL_conf
%%
% Call default configuration driver, then change only the settings that are
% necessary for the entire central california region.

% Get a set of default config parameters - see HFRPdriver_default_conf for
% a list of parameters that will be set to default if not specified.
conf = HFRPdriver_default_conf;

% Program parameters
% Base directories.
baseDir = '/Users/cocmpmb/';
baseConfDir = fullfile(baseDir,'HFR_Progs','matlab','HFR_COCMP','data');
baseResultsDir ='/Volumes/Extras/RealTime/Data/';
baseRadialDir = '/Volumes/Extras/RealTime/Data/Radials/';

domain = 'TEST';
% Reset all the parameters needed for the MNTY case

%% Config parameters for getting and processing Radials
% Where are the radials located up to the site name
conf.Radials.MonthFlag = true;
conf.Radials.TypeFlag = true;
conf.Radials.Sites = {'DRAK','COMM','SLID','FORT','MONT','PILR','PESC','BIGC','SCRZ','MLML','NPGS','PPIN','GCYN','PSUR','PSLR','RAGG', ...
                      'DRAK','COMM','SLID','FORT','MONT','PILR','PESC','BIGC','SCRZ','MLML','NPGS','PPIN','GCYN','PSUR','PSLR','RAGG', ...
                      'BML1','BMLR','PREY','CRIS','PAFS','RTC1','BRKY','TRES', ...
                      'BML1','BMLR','PREY','CRIS','PAFS','RTC1','BRKY','TRES'};
conf.Radials.Types = {'RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi', ...
                      'RDLm','RDLm','RDLm','RDLm','RDLm','RDLm','RDLm','RDLm','RDLm','RDLm','RDLm','RDLm','RDLm','RDLm','RDLm','RDLm', ...
                      'RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi', ...
                      'RDLm','RDLm','RDLm','RDLm','RDLm','RDLm','RDLm','RDLm'};

conf.Radials.BaseDir = baseRadialDir;
                  
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
conf.Totals.GridFile = fullfile(baseConfDir,'grids','TEST.grid');
conf.Totals.spatthresh = 3;  % Km
conf.Totals.tempthresh = 1/24/2-eps;
conf.Totals.MaxTotSpeed = 100;
% Needs to be a cell array of cell arrays
conf.Totals.cleanTotalsVarargin = { { 'GDOPMaxOrthog','TotalErrors',2 } };

conf.Totals.MaskFile = '';

% Web stuff
conf.Totals.WebWrite = true;
conf.Totals.WebBase = '/Library/WebServer/Documents/images';
conf.Totals.WebName = ['tuv_',conf.Totals.DomainName,'_latest.gif'];

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
conf.HourPlot.axisLims = [-123.5,-121.7,36.2,38.05];

% % % conf.HourPlot.VectorScale = 0.015;
conf.HourPlot.VectorScale = 0.015/2;
conf.HourPlot.VelocityScaleLength = 25;
conf.HourPlot.VelocityScaleLocation = [-121.8333, 37.75];

% Location to put a velocity scale.  Defaults to 10% from upper right corner.
conf.HourPlot.DistanceBarLength = 10;
conf.HourPlot.DistanceBarLocation = [-121.82,37.6];
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
conf.RadialPlot.axisLims = conf.HourPlot.axisLims; 
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

conf.IndivRadialPlot.WebWrite = true;
conf.IndivRadialPlot.WebBase = '/Library/WebServer/Documents/images';

%% For weekly individual radial coverage maps
conf.WeeklyRadialPlot.BaseDir = conf.IndivRadialPlot.BaseDir;
conf.WeeklyRadialPlot.CoverFilePrefix = 'WeekCover_';

conf.WeeklyRadialPlot.WebWrite = true;
conf.WeeklyRadialPlot.WebBase = '/Library/WebServer/Documents/images';
