function [ ofn, hdls, p ] = COCMPdriver_plot_pred_trajectory(D,p,varargin)

ofn= [];
hdls = [];
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters and parameter checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = HFRPdriver_default_conf( p );

% Merge
mand_params = { 'HourPlot.VectorScale' };
p = checkParamValInputArgs( p, {}, mand_params, varargin{:} );



[tdn,tfn] = datenum_to_directory_filename( p.predTraj.BaseDir, D, ...
                                           p.predTraj.FilePrefix, ...
                                           p.predTraj.FileSuffix, p.MonthFlag );
tdn = tdn{1};

try
    load(fullfile(tdn,tfn{1}),'PredTRAJoma');
catch
    fprintf('%s doesn''t exist, no plotting\n',fullfile(tdn,tfn{1}));
    ofn = []; hdls = [];
    return;
end

%% Flag any trajectory data outside of the domain
try
    load(p.OMA.BoundaryFileName)
    PredTRAJoma = flagTrajs(PredTRAJoma,OMA_boundary);
catch
    fprintf('No trajectory boundary masking\n')
end

%% Plotting defaults
% Set the title if not specified.
try, p.HourPlot.TitleString;
catch
%   p.HourPlot.TitleString = [p.HourPlot.DomainName,': ', ...
%                             datestr(D,0),' ',TRAJoma.TimeZone];
  p.HourPlot.TitleString = {[p.HourPlot.DomainName,': ', ...
                            'From ',datestr(PredTRAJoma.TimeStamp(1), ...
                            'dd-mmm-yyyy HH:MM')],
                            ['to ',datestr(PredTRAJoma.TimeStamp(end), ...
                            'dd-mmm-yyyy HH:MM'), ...
                            ' ',PredTRAJoma.TimeZone]};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define axis limits if necessary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try, p.HourPlot.axisLims;
catch, p.HourPlot.axisLims = axisLims( data.TUV, 0.1 ); end

try, p.HourPlot.VelocityScaleLocation;
catch
  p.HourPlot.VelocityScaleLocation = p.HourPlot.axisLims([1,3]) + ...
      0.9 * diff(reshape(p.HourPlot.axisLims,[2,2]));
end

try, p.predTraj.WebWrite;
catch
    p.predTraj.WebWrite = false;
end

%%
% Plot the basemap
[hdls] = makeBase(p);


%%
% Plot data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot location of start points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdls.StartLoc = m_plot( PredTRAJoma.Lon(:,1),PredTRAJoma.Lat(:,1), ...
                      'xb','markersize',12,'linewidth',1.5);
hdls.Path = m_plot(PredTRAJoma.Lon',PredTRAJoma.Lat','-m','linewidth',1);
% Only mark the ends of track that finish in the domain. TrajectoryDuration
% equal to length of trajectoy time in water means it stayed in the domain 
% for the whole period.  
% ind = PredTRAJoma.TrajectoryDuration < 1;
ind = PredTRAJoma.TrajectoryDuration < ...
      (PredTRAJoma.TimeStamp(end)-PredTRAJoma.TimeStamp(1)-eps);
% hdls.EndLoc = m_plot( PredTRAJoma.FinalLonLat(~ind,1), ...
%                       PredTRAJoma.FinalLonLat(~ind,2), ...
%                       'xb','markersize',12,'linewidth',1.5);
hdls.EndLoc = m_plot( PredTRAJoma.Lon(~ind,end), ...
                      PredTRAJoma.Lat(~ind,end), ...
                    '.r', 'markersize',18);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add title string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdls.title = title( p.HourPlot.TitleString, 'fontsize', 20 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print if desired
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if p.HourPlot.Print
    [odn,ofn] = datenum_to_directory_filename( p.predTraj.PlotDir, D, ...
                                               p.predTraj.FilePrefix, ...
                                              '.eps', p.MonthFlag );
    odn = odn{1}; ofn = ofn{1};
    ofn = fullfile(odn,ofn);
    if ~exist( odn, 'dir' )
        mkdir(odn);
    end
    % Set the figure for background mode, and print to file
    % bgprint(ofn,'-depsc2',p.Plot.PaperWidth,p.Plot.PaperHeight,'-DEBUG');
    bgprint(ofn,'-depsc2',p.Plot.PaperWidth,p.Plot.PaperHeight);
    % Display the renderer used.
    disp('Renderer is:')
    get(gcf,'Renderer')
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
    while d.bytes < 1000  &&  cnt <= 3
        cnt = cnt + 1;
        % change paper size a little - 0.01 inches
        p.Plot.PaperWidth = p.Plot.PaperWidth + 0.01;
        % bgprint(ofn,'-depsc2',p.Plot.PaperWidth,p.Plot.PaperHeight,'-DEBUG');
        bgprint(ofn,'-depsc2',p.Plot.PaperWidth,p.Plot.PaperHeight);
        [outF,suc]=convertPlot(ofn,'gif',true);
        d = dir(outF);
        if d.bytes >= 1000
            fprintf('Adjusted %d times - final paper width = %f\n', ...
                    cnt,p.Plot.PaperWidth);
            break;
        end
    end  
    % THIS IS TOTAL MAGIC FOR THE WEB PAGE
    if p.predTraj.WebWrite
        copyfile(outF,fullfile(p.predTraj.WebBase,p.predTraj.WebName));
    end
              
end

hold off
