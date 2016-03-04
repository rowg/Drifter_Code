function COCMPdriver_plot_radial_current(D,conf,varargin)

% plot the RTUV vectors for each site

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

% Might want to keep around so that TUV or OMA can be plotted from same
% program
% % % s = conf.RadialPlot.Type;

[tdn,tfn] = datenum_to_directory_filename( conf.Totals.BaseDir, D, ...
                                           conf.Totals.FilePrefix, ...
                                           conf.Totals.FileSuffix, ...
                                           conf.MonthFlag );
% % % [tdn,tfn] = datenum_to_directory_filename( conf.(s).BaseDir, D, ...
% % %                                            conf.(s).FilePrefix, ...
% % %                                            conf.(s).FileSuffix, p.MonthFlag )
tdn = tdn{1};

% Load total hour:  assume radial data in the standard RTUV radial
% structure.
load(fullfile(tdn,tfn{1}),'RTUV','Rorig','p');


%% Web write?
try, conf.IndivRadialPlot.WebWrite;
catch
    conf.IndivRadialPlot.WebWrite = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:numel(RTUV)
    figure
    
   % if it is elliptical, use Rorig (no interpolations), if radial, use 
   % RTUV (with interpolation)
    if isempty(strfind(char(Rorig(k).FileName),'.euv'));  % Radial file
        RR = RTUV(k);
    else
        RR = Rorig(k);
    end
    
    RR = subsrefRADIAL( RR, isfinite( RR.RadComp ), ':' ); % Must have 1 timestep
    
    conf.RadialPlot.axisLims = axisLims(RR,0.075);
    conf.RadialPlot.TitleString = [RR.SiteName,' ',RR.Type,': ',datestr(D,'dd-mmm-yyyy HH:MM')];
    conf.RadialPlot.DistanceBarLocation = conf.RadialPlot.axisLims([1,3]) + ...
        0.9 * diff(reshape(conf.RadialPlot.axisLims,[2,2]));
    
    plotBasemap( conf.RadialPlot.axisLims(1:2), conf.RadialPlot.axisLims(3:4), ...
             conf.Plot.coastFile, conf.Plot.Projection, conf.Plot.plotBasemap_xargs{:} ...
             );
    m_ungrid;
    m_grid( conf.Plot.m_grid_xargs{:} );

    hold on

    if conf.Plot.Speckle
        m_usercoast( conf.Plot.coastFile, 'speckle', 'color', 'k' )
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot Data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hdls.RR = [];

    hdls.RR(k) = plotData( RR, 'm_vec', D, conf.HourPlot.VectorScale, ...
                            conf.RadialPlot.plotData_xargs{:} );
    hdls.RadialsSites(k) = m_plot(RR.SiteOrigin(1),RR.SiteOrigin(2), ...
                                  '^k','markersize',10,'linewidth',3);
    try
      conf.HourPlot.ColorTicks;
    catch
      ss = max( cart2magn( RR.U, RR.V ) );
      conf.HourPlot.ColorTicks = 0:10:ss+10;
    end

    conf.HourPlot.VelocityScaleLocation = conf.RadialPlot.axisLims([1,3]) + ...
      0.9 * diff(reshape(conf.RadialPlot.axisLims,[2,2]));
  
% %     conf.HourPlot.DistanceBarLocation = conf.HourPlot.VelocityScaleLocation - ...
% %       [0,0.05] .* diff(reshape(conf.HourPlot.axisLims,[2,2]));
    conf.HourPlot.DistanceBarLocation = conf.RadialPlot.axisLims([1,3]) + ...
      [0.9,0.82] .* diff(reshape(conf.RadialPlot.axisLims,[2,2]));

    
    caxis( [ min(conf.HourPlot.ColorTicks), max(conf.HourPlot.ColorTicks) ] );
    colormap( feval( conf.HourPlot.ColorMap, numel(conf.HourPlot.ColorTicks)-1 ) );
    cax = colorbar;
    hdls.colorbar(k) = cax;
    hdls.ylabel(k) = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                                   'saturated.'], 'fontsize', 14 );
    hdls.xlabel(k) = xlabel( cax, 'cm/s', 'fontsize', 14 );

    set(cax,'ytick',conf.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')
                          
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add distance and (velocity bar)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [hdls.DistanceBar,hdls.DistanceBarText,conf.RadialPlot.DistanceBarLocation] = ...
        m_distance_bar( conf.RadialPlot.DistanceBarLength, ...
                        conf.HourPlot.DistanceBarLocation,'horiz',0.2 );
    set(hdls.DistanceBar,'linewidth',2 );
    set(hdls.DistanceBarText,'fontsize',16,'fontweight','bold')

    
    [hdls.VelocityScaleArrow,hdls.VelocityScaleText,conf.HourPlot.VelocityScaleLocation] ...
    = plotVelocityScale( conf.HourPlot.VelocityScaleLength,conf.HourPlot.VectorScale, ...
                         [num2str(conf.HourPlot.VelocityScaleLength) ' cm/s'], ...
                         conf.HourPlot.VelocityScaleLocation,'horiz', ...
                         'm_vec','linewidth',2 );
    set(hdls.VelocityScaleText,'fontsize',16,'fontweight','bold')
    set(hdls.VelocityScaleArrow,'facecolor','k')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add title string
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hdls.title = title( conf.RadialPlot.TitleString, 'fontsize', 20 );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print if desired
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if conf.RadialPlot.Print
        [odn,ofn] = datenum_to_directory_filename( fullfile(conf.IndivRadialPlot.BaseDir, ...
                                                 'Currents', ...
                                                 p.Radials.Sites{k},p.Radials.Types{k}), ...
                                                 D,[p.Radials.FilePrefix{k}, ...
                                                 conf.IndivRadialPlot.CurrentFilePrefix], ...
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
                     '_Currents_latest.gif']));
        end
    end

    hold off
end
