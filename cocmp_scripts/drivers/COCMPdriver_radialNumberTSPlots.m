%DRIVER FOR COCMP SPECIFIC RADIAL STATISTICS.
%This script will attempt to load radials for a given region and plot

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % IMPORANT PATH STUFF NOW NEEDED HERE AND NOT RELIED UPON AT THE CRON           %
% % cd /Volumes/Extras/RealTime/Progs/RT/trunk/HFR_Progs/matlab                     %
% % startup                                                                         %
% % startup('/Volumes/Extras/RealTime/Configs/RT')                                  %
% % startup('/Volumes/Extras/RealTime/Progs/RT/trunk/dpath2o/matlab')               %
% % addpath /Volumes/Extras/RealTime/Progs/RT/trunk/mike_stuff/HFR_COCMP/drivers    %
% % addpath /Volumes/Extras/RealTime/Progs/RT/trunk/mike_stuff/HFR_COCMP/helpers    %
% % addpath /Volumes/Extras/RealTime/Progs/RT/trunk/mike_stuff/HFR_COCMP/working    %
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

START_TIME=now;

fprintf('Starting: %s ... %s\n',mfilename,datestr(START_TIME,31));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is different from the rest of the driver type programs
% because it doesn't call a conf file, rather all it needs is defined by
% the parameters below.  MAY want to bring it into the fold. -MC
%PARAMETERS:
baseDir = '/Volumes/Extras/RealTime/Data/Radials/';
plotDir = '/Library/WebServer/Documents/images/';
stop    = getTime([]);
start   = stop-7;
ts      = start+eps:1/24:stop+0.0001;
moFlag  = true;
tyFlag  = true;
clrs = [ 1   0   0 ;
         0   1   0 ;
         0   0   1 ;
         1   1   0 ;
         0   1   1 ;
         1   0   1 ;
         0   0   0 ;
        .68 .09  0 ;
        .22 .88 .71];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cenc    = 'UCSC';
sites   = {'PESC','BIGC','SCRZ','MLML','NPGS','PPIN','GCYN','PSUR','PSLR'};
types   = {'RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi','RDLi'};
fprintf('Loading up UCSC sites to plot time series Number of Radials ...\n');
tic
delete(gcf); 
plotNumRadTS(baseDir,plotDir,ts,moFlag,tyFlag,clrs,sites,types,cenc);
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cenc    = 'SFSU_COAST';
sites   = {'COMM','SLID','FORT','MONT','PILR'};
types   = {'RDLi','RDLi','RDLi','RDLi','RDLi'};
fprintf('Loading up SFSU COASTAL sites to plot time series Number of Radials ...\n');
tic
delete(gcf); 
plotNumRadTS(baseDir,plotDir,ts,moFlag,tyFlag,clrs,sites,types,cenc);
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cenc    = 'SFSU_BAY';
sites   = {'RTC1','BRKY','TRES','CRIS'};
types   = {'RDLi','RDLi','RDLi','RDLi'};
fprintf('Loading up SFSU BAY sites to plot time series Number of Radials ...\n');
tic
delete(gcf); 
plotNumRadTS(baseDir,plotDir,ts,moFlag,tyFlag,clrs,sites,types,cenc);
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cenc    = 'UCD';
sites   = {'PAFS','BMLR','BML1','PREY'};
types   = {'RDLi','RDLi','RDLi','RDLi'};
fprintf('Loading up UCD sites to plot time series Number of Radials ...\n');
tic
delete(gcf); 
plotNumRadTS(baseDir,plotDir,ts,moFlag,tyFlag,clrs,sites,types,cenc);
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

END_TIME = now;
fprintf('COCMPdriver_radialNumberTSPlots.m complete ...\n');
fprintf('Start Time: %s,  End Time: %s\n', ...
    datestr(START_TIME,0),datestr(END_TIME,0));
disp('Exiting')
exit;
