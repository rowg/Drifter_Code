function [ ofn, hdls, p ] = COCMP_trajectory_movie( D, p, varargin )

% Non-background movie making function.
%
% Code to make trajectory movies - should be generic enough to play oma or
% tuv trajectories, forward or back in time, and actual or predicted.  Key
% on the TRAJ*.mat files.
%
% IS THIS FUNCTION ABLE TO PLAY MOVIES BACK IN TIME AS IS??  I THINK SO,
% BUT NEED TO HAVE A MAT FILE ALREADY PASSED THROUGH THE
% COCMPDRIVER_CALCTRAJ.M THAT WAS CALCULATED IN REVERSE TIME.  SEE
% TESTTRAJDRIVER.M IN THE OTHER/ DIRECTORY AS A FIRST EXAMPLE.
%
%% Get the trajectory file to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters and parameter checks

% Merge
p = HFRPdriver_default_conf( p );

% Merge
mand_params = { 'HourPlot.VectorScale','Totals.DomainName' };
p = checkParamValInputArgs( p, {}, mand_params, varargin{:} );


% Load the data file.
[tdn,tfn] = datenum_to_directory_filename( p.Traj.BaseDir, D, ...
                                           p.Traj.FilePrefix, ...
                                           p.Traj.FileSuffix, p.MonthFlag );
tdn = tdn{1};

try
    load(fullfile(tdn,tfn{1}),'TRAJoma');
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

%% Set up the tmp frame directory.
try
    frameDir = p.TrajAnim.tmpDir;
catch
    frameDir = fullfile(pwd, ...
                        ['TEMP_ANIMATION_DIRECTORY_',p.Totals.DomainName]);
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

%% interpolation step
try
    timeStep = p.TrajAnim.timeStep;
catch
    timeStep = 1/2/24
end
% A uniformly spaced vector of times for the interpolation
intTime = TRAJoma.TimeStamp(1):timeStep:TRAJoma.TimeStamp(end)+eps;
% Trajectory position data is organized as:
% TRAJoma.lon, and TRAJoma.lon --> npts x times - transpose to get it in
% the times x npts format needed by interp1
intLon = interp1(TRAJoma.TimeStamp,TRAJoma.Lon',intTime);  % times x pts
intLat = interp1(TRAJoma.TimeStamp,TRAJoma.Lat',intTime);

%% Set up the base map
% Set up the base map for the animation - set it up once and then 
% set handles up to the data for each frame, and delete after it it done.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define axis limits if necessary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try 
    p.HourPlot.axisLims;
catch
    p.HourPlot.axisLims = axisLims( data.TUV, 0.1 ); 
end

% Plot the basemap
[hdls] = makeBase(p);


%% This code makes the frames
try 
    trajColor = p.TrajAnim.trajColor;
catch
    trajColor = 'k'
end
try
    tailLen = p.TrajAnim.tailLen;
catch
    tailLen = 12  % In timesteps
end
try
    headSize = p.TrajAnim.headSize;
catch
    headSize = 22
end
ext = 'eps';

% Initialize plot handles to avoid annoying error messages
h1 = [];  % Handle to active tail
h2 = [];  % Handle to Head
h3 = [];  % Handle to past tail (from start to end of active tail)
numFrames = size(intTime(:),1);
for i = 1:numFrames
    fprintf('%s: Processing frame%03d\n',mfilename,i);
    % Get rid of the time(i-1) worms.
    delete(h1);
    delete(h2);
    delete(h3);
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

    title( {sprintf('%s Particle Trajectories From OMA Derived',p.HourPlot.DomainName) , ...
            sprintf('Currents at %s %s', ...
                     datestr(intTime(i),'dd-mmm-yyyy HH:MM'), ...
                     TRAJoma.TimeZone)} , ...
                     'fontsize',20)
             
    print('-depsc',fullfile(frameDir,sprintf('frame%03d.%s',i,ext)));
end
% 
% Add code repeat the ending frame a set number of times.
% Determine last actual frame number and add to it.
cnt = i;
numRepeatLastFrame = 8;
for j = 1:numRepeatLastFrame
    cnt = cnt + 1;
    
    print('-depsc2',fullfile(frameDir,sprintf('frame%03d.%s',cnt,ext)));
end

%% Convert frames into a movie - from trjplt_driver.m on rt server
% THIS IS THE UGLY PART!
%%%%%%%%%%%%%%%%%%% KLUDGE ALERT KLUDGE ALERT KLUDGE ALERT %%%%%%%%%%%%%%%%%%%%%
% KLUDGY FOR NOW, BUT I'M SURE IT WILL BE FIXED UP AT SOME POINT.  CAN'T GET
% THE SYSTEM CALL TO ACCEPT VARIABLE STRINGS.  NEED TO FIGURE OUT.-MC
% OK here's the work around

% % % currentDir = pwd;
% % % % cd to frames directory
% % % cd(frameDir)
% % % % Hardcode whole command, write to a static file name = trjAnimation_latest.gif
% % % % Should now have a bunch of frames as: frame*.gif
% % % system('/sw/bin/convert -delay 15 -loop 0 frame*.eps trjAnimation_latest.gif');
% % % 
% Copy the animation to the proper directory
[odn,ofn] = datenum_to_directory_filename( p.TrajAnim.PlotDir, D, ...
                                           p.TrajAnim.FilePrefix, ...
                                           p.TrajAnim.FileSuffix, ...
                                           p.MonthFlag );
odn = odn{1}; ofn = ofn{1};
ofn = fullfile(odn,ofn);
if ~exist( odn, 'dir' )
    mkdir(odn);
end
% % % 
% % % % Put the movie in the proper archive location.
% % % movefile('trjAnimation_latest.gif',ofn);
% % % 
% % % cd(currentDir);
%%%%%%%%%%%%%% END KLUDGE ALERT END KLUDGE ALERT END KLUDGE ALERT %%%%%%%%%%%%%%

% OK, let's DE-KLUDGE!
system([p.TrajAnim.convCommand,' ',p.TrajAnim.convFlags,' ', ...
        fullfile(frameDir,['frame*.',ext]),' ',ofn]);

