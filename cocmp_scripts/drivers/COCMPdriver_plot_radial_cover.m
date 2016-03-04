function COCMPdriver_plot_radial_cover(D,conf,varargin)

% plot the Rorig, Rmask (if there), and Rinterp (if there)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters and parameter checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
conf = HFRPdriver_default_conf( conf );

% Merge
mand_params = { };
conf = checkParamValInputArgs( conf, {}, mand_params, varargin{:} );

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load totals data (of OMA or Totals type depending on config)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % s = conf.RadialPlot.Type;

[tdn,tfn] = datenum_to_directory_filename( conf.Totals.BaseDir, D, ...
                                           conf.Totals.FilePrefix, ...
                                           conf.Totals.FileSuffix, ...
                                           conf.MonthFlag );
% % % [tdn,tfn] = datenum_to_directory_filename( conf.(s).BaseDir, D, ...
% % %                                            conf.(s).FilePrefix, ...
% % %                                            conf.(s).FileSuffix, p.MonthFlag )
tdn = tdn{1};

% Load total hour:  assume it has Rorig, Rmask, Rinterp
load(fullfile(tdn,tfn{1}),'Rorig','Rmask','Rinterp','p');

%% Web write?
try, conf.IndivRadialPlot.WebWrite;
catch
    conf.IndivRadialPlot.WebWrite = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:numel(Rorig)
    figure
    try
        % Try to Load mask file
        mask = load(Rmask(k).OtherMetadata.maskRadials.maskFileName);

        % Sort out axis limits
        t(1,:) = axisLims(Rorig(k),0.1);
        t(2,:) = axisLims(mask,0.1);
        conf.RadialPlot.axisLims = [min(t(:,1)),max(t(:,2)), ...
                                    min(t(:,3)),max(t(:,4))];
    catch
        % No mask, so set axisLims to just the data
        fprintf('No Mask file for: %s\n',Rorig(k).SiteName);
        conf.RadialPlot.axisLims = axisLims(Rorig(k),0.1);
        mask = [NaN, NaN];  % Do this to keep plot of mask later from failing.
    end

    conf.RadialPlot.TitleString = [Rorig(k).SiteName,' ',Rorig(k).Type,': ',datestr(D,'dd-mmm-yyyy HH:MM')];
    conf.RadialPlot.DistanceBarLocation = conf.RadialPlot.axisLims([1,3]) + ...
        0.9 * diff(reshape(conf.RadialPlot.axisLims,[2,2]));
    
%%
    plotBasemap( conf.RadialPlot.axisLims(1:2), conf.RadialPlot.axisLims(3:4), ...
             conf.Plot.coastFile, conf.Plot.Projection, conf.Plot.plotBasemap_xargs{:} ...
             );
    m_ungrid;
    m_grid( conf.Plot.m_grid_xargs{:} );

    hold on

    if conf.Plot.Speckle
        m_usercoast( conf.Plot.coastFile, 'speckle', 'color', 'k' )
    end

%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot Data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hdls.Rorig = [];

    % Original data
    RR = Rorig(k);
    RR = subsrefRADIAL( RR, isfinite( RR.RadComp ), ':' ); % Must have 1 timestep
    hdls.Rorig(k) = plotData( RR, 'grid', 'm_plot', 'color', [.35,.35,.35], ...
                            conf.RadialPlot.plotData_xargs{:} );
    
    % Masked data
    RR = Rmask(k);
    RR = subsrefRADIAL( RR, isfinite( RR.RadComp ), ':' ); % Must have 1 timestep
    hdls.Rmask(k) = plotData( RR, 'grid', 'm_plot', 'color', 'b', ...
                            conf.RadialPlot.plotData_xargs{:} );
                        
    % Plot any interpolated data
    % if it is elliptical, don't plot anything
    if isempty(strfind(char(Rorig(k).FileName),'.euv'));  % Radial file
        RR = Rinterp(k);
        RR = subsrefRADIAL( RR, isfinite( RR.RadComp ), ':' ); % Must have 1 timestep
        ind = RR.Flag > 1;
        % Make sure there is something to plot
        if sum(ind) > 0
            hdls.Rinterp(k) = m_plot(RR.LonLat(ind,1),RR.LonLat(ind,2),'*k');
        end

        hdls.RadialsSites = m_plot(RR.SiteOrigin(1),RR.SiteOrigin(2), ...
                                      '^k','markersize',10,'linewidth',3);
    else   % Elliptical file
        fprintf('No interp plot of %s\n',char(Rorig(k).FileName));
    end
    
    % Now add mask file
    m_plot(mask(:,1),mask(:,2),'r','linewidth',2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add distance and (velocity bar)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [hdls.DistanceBar,hdls.DistanceBarText,conf.RadialPlot.DistanceBarLocation] = ...
        m_distance_bar( conf.RadialPlot.DistanceBarLength, ...
                        conf.RadialPlot.DistanceBarLocation,'horiz',0.2 );
    set(hdls.DistanceBar,'linewidth',2 );
    set(hdls.DistanceBarText,'fontsize',16)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add title string
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hdls.title = title( conf.RadialPlot.TitleString, 'fontsize', 20 );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print if desired
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if conf.RadialPlot.Print
        % If a site is missing, then there is no longer a 1-1 match between
        % the conf.Radials parameters struct and the Rorig data struct.
        % Must use strmatch to eliminate any missing files - the list of
        % missing files is contained in the TUV mat file - load it too.
        [odn,ofn] = datenum_to_directory_filename( fullfile(conf.IndivRadialPlot.BaseDir, ...
                                            'HourCoverage', ...
                                            p.Radials.Sites{k},p.Radials.Types{k}), ...
                                            D,[p.Radials.FilePrefix{k}, ...
                                            conf.IndivRadialPlot.CoverFilePrefix], ...
                                            '.eps',conf.MonthFlag);
        odn = odn{1}; ofn = ofn{1};
        ofn = fullfile(odn,ofn);
        if ~exist( odn, 'dir' )
            mkdir(odn);
        end
        % Set the figure for background mode, and print to file
        bgprint(ofn,'-depsc2',conf.Plot.PaperWidth,conf.Plot.PaperHeight)
        % Convert to gif format
        [outF,suc]=convertPlot(ofn,'gif',true);
        
        if conf.IndivRadialPlot.WebWrite
            copyfile(outF, fullfile(conf.IndivRadialPlot.WebBase, ...
                    [p.Radials.Types{k},'_',p.Radials.Sites{k}, ...
                     '_Cover_latest.gif']));
        end
    end

    hold off
end

