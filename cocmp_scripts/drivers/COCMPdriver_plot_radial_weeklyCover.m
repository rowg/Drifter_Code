function COCMPdriver_plot_radial_weeklyCover(D,conf,varargin)

% Load radial files from .ruv files and make dot coverage plots.

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters and parameter checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
conf = HFRPdriver_default_conf( conf );

% Merge
mand_params = { };
conf = checkParamValInputArgs( conf, {}, mand_params, varargin{:} );

%% Web write?
try, conf.WeeklyRadialPlot.WebWrite;
catch
    conf.WeeklyRadialPlot.WebWrite = false;
end

%% Specify the times and load the radial data
% Hardwire the coverage to be 1 week into the past from time D.
times = (D-7)+eps:1/24:D+eps*2;

% Loop over each site
for i = 1:numel(conf.Radials.Sites)
    siteName = conf.Radials.Sites{i};
    radType = conf.Radials.Types{i};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get filenames together
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    F = filenames_standard_filesystem( conf.Radials.BaseDir, siteName, ...
                                       radType, times,  ...
                                       conf.Radials.MonthFlag, ...
                                       conf.Radials.TypeFlag);

    %% Get rid of any missing/empty radials and temporally concat
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Radials work - load in all at once, masking, cleaning interpolation
    %
    % When loading, for each time, load all radials from all sites in an
    % element of a single cell array - this will be useful for later saving
    % radials from each time with the appropriate totals files.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Rorig = loadRDLFile(F);

    % Deal with possible missing files
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
      fprintf('No radial data for %s %s for the entire week ending %s ... skipping\n', ...
               siteName,radType,datestr(D));
      continue;
    end

    fprintf('Temporal Concating %s\n',siteName);
    Rcat = temporalConcatRadials(Rorig,0.1,0.1,0.1,0.1);


    %% The plot dynamic options and make the basemap
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Define axis limits and Distance legend location.
    % Basemap keys on the Totals plotting parameters, so replace them 
    % instead of the radial parameter stuff.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    conf.HourPlot.axisLims = axisLims( Rcat, 0.05 );

    conf.HourPlot.DistanceBarLocation = conf.HourPlot.axisLims([1,3]) + ...
       0.9 * diff(reshape(conf.HourPlot.axisLims,[2,2]));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Basemap with nice boundary
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clf
    [hdls] = makeBase(conf,false);
    hold on

    percentLimits = [0,100];
    conf.RadialPlot.ColorTicks = 0:10:100;
    % This is where the work is done.
    [h,ts]=plotData(Rcat,'perc','m_line',percentLimits);
    set(h,'markersize',20);

    cax = colorbar;
    hdls.colorbar = cax;
    hdls.ylabel = ylabel( cax, 'Coverage (Percent)', 'fontsize', 16,'fontweight','bold' );
    % hdls.xlabel = xlabel( cax, '%', 'fontsize', 14 );

    set(cax,'ytick',conf.RadialPlot.ColorTicks,'fontsize',14,'fontweight','bold');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add title string
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    titleStr = {sprintf('%s %s Coverage, %d of %d possible hourly maps', ...
                        siteName,radType,length(Rcat.TimeStamp),length(ii)),
                sprintf('From %s to %s',datestr(times(1)),datestr(times(end)))};
    hdls.title = title(titleStr, 'fontsize', 20 );

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print if desired
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if conf.RadialPlot.Print
        % If a site is missing, then there is no longer a 1-1 match between
        % the conf.Radials parameters struct and the Rorig data struct.
        % Must use strmatch to eliminate any missing files - the list of
        % missing files is contained in the TUV mat file - load it too.
        [odn,ofn] = datenum_to_directory_filename( fullfile(conf.WeeklyRadialPlot.BaseDir, ...
                                'WeeklyCoverage', ...
                                siteName,radType), ...
                                D,[conf.Radials.FilePrefix{i}, ...
                                conf.WeeklyRadialPlot.CoverFilePrefix], ...
                                '.eps',conf.MonthFlag);
        odn = odn{1}; ofn = ofn{1};
        ofn = fullfile(odn,ofn);
        if ~exist( odn, 'dir' )
            mkdir(odn);
        end
        
        % Sometimes the coverage plot will be OK when run interactively,
        % but when run from a cron process, will be small and messed up.
        % Don't know why, doesn't appear to be a renderer, line drawing,
        % the type of m_map projection (lambert and mercator have been
        % tried), or how saved (eps, png, ps).  But resizing the plot using
        % the paperposition command does fix the problem.  So add some code
        % to resize the plot if the gif images seems too small.
        % Try a few times to prevent an infinite loop.
        minBytes = 3000;
        d.bytes = 1;
        cnt = 0;
        % Check to see if file is small, too small to be a valid plot.
        while d.bytes < minBytes && cnt <= 4
            cnt = cnt + 1;
            % Change paper size a little -> 0.01 inches.
            conf.Plot.PaperWidth = conf.Plot.PaperWidth + 0.01;
            % Set the figure for background mode, and print to file
            bgprint(ofn,'-depsc2',conf.Plot.PaperWidth,conf.Plot.PaperHeight);
            % Convert to gif format
            [outF,suc]=convertPlot(ofn,'gif',true);
            d = dir(outF);
            if d.bytes >= minBytes
                fprintf('Adjusted %d times - final paper width = %f\n', ...
                    cnt, conf.Plot.PaperWidth);
                break;
            end
        end

        if conf.WeeklyRadialPlot.WebWrite
            copyfile(outF, fullfile(conf.WeeklyRadialPlot.WebBase, ...
                    [radType,'_',siteName, ...
                     '_WeekCover_latest.gif']));
        end
    end

    hold off 
    
end
