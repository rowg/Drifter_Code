function [ ofn, hdls, p ] = COCMP_pred_trajectory_movie_bg(D, p, varargin)

% Code to make trajectory movies - should be generic enough to play oma or
% tuv trajectories, forward or back in time, and actual or predicted.  Key
% on the TRAJ*.mat files.
%
% Need:
%       trajfilename - can pass in or create in function like rest of
%       driver function
%
%       tmp frame directory - place to store frames for movie - delete this
%       directory after done, check to see if it exists before and if it
%       does DELETE IT - THIS IS DANGEREOUS
%
%       time step for movie - the oma stuff at least is at a time step that
%       seems to be choosen in one of DMK's programs.  Can't seem to set it
%       to a fixed time, so need to interp the data to time step before
%       making movie.  Use hours, so 30 minutes is passed in as 1/2/24.
%
%       maybe use varargin to pass additional arguments and flags to
%       convert when making the movie.

%% Get the trajectory file to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters and parameter checks

% Merge
p = HFRPdriver_default_conf( p );

% Merge
mand_params = { 'HourPlot.VectorScale','Totals.DomainName' };
p = checkParamValInputArgs( p, {}, mand_params, varargin{:} );


% Load the data file.
[tdn,tfn] = datenum_to_directory_filename( p.predTraj.BaseDir, D, ...
                                           p.predTraj.FilePrefix, ...
                                           p.predTraj.FileSuffix, ...
                                           p.MonthFlag );
tdn = tdn{1};

try
    load(fullfile(tdn,tfn{1}),'PredTRAJoma');
catch
    fprintf('%s doesn''t exist, no animation made\n',fullfile(tdn,tfn{1}));
    ofn = []; hdls = [];
    return;
end

%% Flag any trajectory data outside of the domain
try
    load(p.OMA.BoundaryFileName)
    TRAJoma = flagTrajs(TRAJoma,OMA_boundary);
catch
    fprintf('No trajectory boundary masking\n')
end

%% Web write?
try, p.predTrajAnim.WebWrite;
catch
    p.predTrajAnim.WebWrite = false;
end

%%
% Set up the tmp frame directory.
try
    frameDir = p.predTrajAnim.tmpDir;
catch
    frameDir = fullfile(pwd,'TEMP_ANIMATION_DIRECTORY')
end
% Get the tmp directory setup - if it exists IT WILL BE DELETED - BE VERY
% VERY CAREFUL
% Matlab has a function called rmdir - it has many ways to call it - use
% the form that will remove the directory AND EVERTHING IT RECURSIVELY.
if exist(frameDir,'dir')
    fprintf('%s is recursively removing the directory:\n%s\n', ...
             mfilename, frameDir);
    [a,b,c] = rmdir(frameDir,'s');
end
if ~exist( frameDir, 'dir' )
    fprintf('%s is creating the directory:\n%s\n',mfilename,frameDir);
    mkdir(frameDir);
end

%%
% interpolation step
try
    timeStep = p.predTrajAnim.timeStep;
catch
    timeStep = 1/2/24
end
% A uniformly spaced vector of times for the interpolation
intTime = PredTRAJoma.TimeStamp(1):timeStep:PredTRAJoma.TimeStamp(end)+eps;
% Trajectory position data is organized as:
% TRAJoma.lon, and TRAJoma.lon --> npts x times - transpose to get it in
% the times x npts format needed by interp1
intLon = interp1(PredTRAJoma.TimeStamp,PredTRAJoma.Lon',intTime);  % times x pts
intLat = interp1(PredTRAJoma.TimeStamp,PredTRAJoma.Lat',intTime);

%% Set up the base map limits and 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define axis limits if necessary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try 
    p.HourPlot.axisLims;
catch
    p.HourPlot.axisLims = axisLims( data.TUV, 0.1 ); 
end

%% This code makes the frames
try 
    trajColor = p.predTrajAnim.trajColor;
catch
    trajColor = 'm'
end
try
    tailLen = p.predTrajAnim.tailLen;
catch
    tailLen = 12  % In timesteps
end
try
    headSize = p.predTrajAnim.headSize;
catch
    headSize = 22
end
ext = 'eps';

numFrames = size(intTime(:),1);
for i = 1:numFrames
    fprintf('%s: Processing frame%03d\n',mfilename,i);
    % There have been problems making movies in the background.  The image
    % size isn't consistent.  It is normal sized sometimes, and tiny
    % sometimes when I make movies in the conventional way (1 figure and
    % manipulate the data thru handles).  The brute force approach seems to
    % fix this.  Clear all figures and make a new basemap for every frame.
    % Must not speckle in this case because it varies from frame to frame.
    % Clearing all
    close all
    % Plot the basemap
    [hdls] = makeBase(p,false,'Plot.Speckle',false);

    % Length of data traversed so far is less then tail   
    if i == 1
        % Do nothing, just make the head, no tail
    elseif i > 1  &&  i <= tailLen
        % Make tail from start of data to now.
        h1 = m_line(intLon(1:i,:),intLat(1:i,:), ...
                   'lineStyle','-','linewidth',2,'color',trajColor);
    else
        % Make the past tail.  Add 1 to prevent the situation where Lon(1:1,:) &
        % Lat(1:1,:), and all starting positions are connected.  Just draw
        % first, and the last 
        h3 = m_line(intLon(1:i-tailLen+1,:),intLat(1:i-tailLen+1,:), ...
                    'lineStyle','-','linewidth',2,'color',[0.7,0.7,0.7]);
        % Make the tail from now to tailLen dt's ago.
        h1 = m_line(intLon(i-tailLen:i,:),intLat(i-tailLen:i,:), ...
                    'lineStyle','-','linewidth',2,'color',trajColor);
    end
    
    % Make the head
    h2 = m_line(intLon(i,:),intLat(i,:),'lineStyle','none','Color','r', ...
                'marker','.','markerSize',headSize);

    title( {sprintf('*PREDICTED* %s Particle Trajectories From', ...
                     p.HourPlot.DomainName) , ...
            sprintf('OMA Derived Currents at %s %s', ...
                     datestr(intTime(i),'dd-mmm-yyyy HH:MM'), ...
                     PredTRAJoma.TimeZone)} , ...
                     'fontsize',20)
                 
    frameName = fullfile(frameDir,sprintf('frame%03d.%s',i,ext));
    % After this call should have a gif frame
    framePlotter(p,frameName,'-depsc2');
    fprintf('Width=%g, Height=%g\n',p.Plot.PaperWidth,p.Plot.PaperHeight);
end
% 
% Repeat the ending frame a set number of times.
% Determine last actual frame number and add to it.
cnt = i;
numRepeatLastFrame = 8;
for j = 1:numRepeatLastFrame
    cnt = cnt + 1;
    
    frameName = fullfile(frameDir,sprintf('frame%03d.%s',cnt,ext));
    % After this call should have a gif frame
    framePlotter(p,frameName,'-depsc2');
end

%% Convert frames into a movie - from trjplt_driver.m on rt server

% Copy the animation to the proper directory
[odn,ofn] = datenum_to_directory_filename( p.predTrajAnim.PlotDir, D, ...
                                           p.predTrajAnim.FilePrefix, ...
                                           p.predTrajAnim.FileSuffix, p.MonthFlag );
odn = odn{1}; ofn = ofn{1};
ofn = fullfile(odn,ofn);
if ~exist( odn, 'dir' )
    mkdir(odn);
end

system(['source /Users/cocmpmb/.bashrc;', ...
        p.TrajAnim.convCommand,' ',p.TrajAnim.convFlags,' ', ...
        fullfile(frameDir,['frame*.gif']),' ',ofn]);
    
% THIS IS TOTAL MAGIC FOR THE WEB PAGE
if p.predTrajAnim.WebWrite
    copyfile(ofn,fullfile(p.predTrajAnim.WebBase,p.predTrajAnim.WebName));
end

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p] = framePlotter(p,ofn,plotDev)
    % print a figure as type plotDev and convert to gif - this function is
    % used to print background plots that sometimes have size problems.


    % Set the figure for background mode, and print to file
    bgprint(ofn,plotDev,p.Plot.PaperWidth,p.Plot.PaperHeight);
    % Convert to gif format
    [outF,suc]=convertPlot(ofn,'gif',true);
    
    % Sometimes the trajectory plot will be ok when run interactively, but
    % when run from a cron process, will be small and messed up.  So
    % it appears in cron batch matlab jobs the plot can get screwed up.
    % Not sure why, doesn't appear to be a renderer, line drawing, the 
    % type of m_map projections (lambert and mercator have been tried), or 
    % how saved (eps, png, ps).  But resizing the plot using the 
    % paperposition command does fix the problem.  So add some code to 
    % resize the plot if the gif images seems too small.
    % ADD CODE HERE TO CHECK AND TRY LIKE 3 TIMES TO RESIZE THE PLOT, SAVE
    % AND CHECK AGAIN
    d = dir(outF);
    cnt = 0;
    % Check to see if file is small, less than 1000 bytes.  This might have
    % to be changed in the future.
    while (d.bytes < 1000  &&  cnt < 3)
        cnt = cnt + 1;
        % change paper size a little - currently at 0.0001 inches
        p.Plot.PaperWidth  = p.Plot.PaperWidth + 0.0001;
        bgprint(ofn,plotDev,p.Plot.PaperWidth,p.Plot.PaperHeight);
        [outF,suc]=convertPlot(ofn,'gif',true);
        d = dir(outF);
    end
    fprintf('Adjusted %d times - final paper width = %f, height = %f\n', ...
        cnt,p.Plot.PaperWidth,p.Plot.PaperHeight);
 
return
