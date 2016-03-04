function [ ofn, hdls, p ] = COCMPdriver_plot_hourly_totals( D, p, varargin )
% COCMPDRIVER_PLOT_HOURLY_TOTALS - This is an example driver function that
% automates generating plots of totals or OMA data
%
% Usage: [ofn,handles,conf] = COCMPdriver_Totals_OMA(TimeStamp,conf,PARAM1,VAL1, ... )
%
% Inputs
% ------
% TimeStamp = Timestamp to work on in datenum format.
% conf = a structure with configuration parameters, can be empty
% PARAMn,VALn = name,value pairs that can override configuration parameters.
%
% Outputs
% -------
% ofn = name of file where the printed results are or would be if one had
%       chosen to print.
% handles = some of the handles from the plot
% conf = final configuration matrix
%
% Configuration Parameters
% ------------------------
% This function uses some of the parameters described in
% COCMPdriver_Totals_OMA.  In particular, it uses conf.Totals or conf.OMA
% to find the totals files for plotting.
%
% OTHER Parameters:
%
% conf.Plot.coastFile = Name of coastline file to be passed to plotBasemap.
%                       Defaults to 'hour_plot_coastline.mat'.
% conf.Plot.Projection = m_map projection to use.  Defaults to
%                        'lambert'.
% conf.Plot.plotBasemap_xargs = Cell array of extra arguments to pass to
%                               plotBasemap.  Defaults to {}.
% conf.Plot.m_grid_xargs = Cell array of extra arguments to pass to
%                          m_grid.  Defaults to some standard options.
% conf.Plot.Speckle = Boolean indicating whether to speckle
%                     coastline. Defaults to true.
%
% conf.HourPlot.BaseDir = Defaults to '.'
% conf.HourPlot.DomainName = name of totals domain.  Defaults to
%                            Totals.DomainName.
% conf.HourPlot.Type = type of data to plot.  Typically 'Totals' or
%                      'OMA'.  Defaults to 'Totals'.
% conf.HourPlot.FilePrefix = Defaults to [ 'hour_plot_' Type '_' DomainName '_' ]
% conf.HourPlot.axisLims = [ minlon, maxlon, minlat, maxlat ].  Defaults
%                          to axisLims( Data, 0.1 ) if not given.
% conf.HourPlot.VectorScale = Scale to use in plotData for making
%                             vectors.  THIS ARGUMENT MUST BE SUPPLIED.
% conf.HourPlot.VelocityScaleLength = Length of velocity scale.  Defaults
%                                     to 50 cm/s.
% conf.HourPlot.VelocityScaleLocation = Location to put a velocity
%                         scale.  Defaults to 10% from upper right
%                         corner.
% conf.HourPlot.DistanceBarLength = Length of distance bar.  Defaults to
%                                   10 km.
% conf.HourPlot.DistanceBarLocation = Location to put distance scale.
%                                     Defaults to just below velocity scale.
% conf.HourPlot.ColorTicks = Color scale to use for plotting vectors.
%                            Defaults to 0:10:max_velocity.
% conf.HourPlot.ColorMap = Color map to use for plotting vectors.
%                          Defaults to 'jet'.
% conf.HourPlot.plotData_xargs = Cell array of extra arguments for plotData.
%                                Defaults to {}.
% conf.HourPlot.TitleString = string to put on title of plot.  Defaults
%                             to datestr(TimeStamp)
% conf.HourPlot.Print = A boolean indicating whether or not to print to a
%                       file.  Defaults to false.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	$Id: HFRPdriver_plot_hourly_totals.m 465 2007-07-23 23:58:13Z dmk $	
%
% Copyright (C) 2007 David M. Kaplan
% Licence: GPL (Gnu Public License)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters and parameter checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = HFRPdriver_default_conf( p );

% Merge
mand_params = { 'HourPlot.VectorScale' };
p = checkParamValInputArgs( p, {}, mand_params, varargin{:} );

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fix default inputs that can only be done afterwards
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try, p.Totals.FilePrefix;
catch
  p.Totals.FilePrefix = [ 'tuv_' p.Totals.DomainName '_' ];
end

try, p.OMA.DomainName;
catch
  p.OMA.DomainName = p.Totals.DomainName;
end

try, p.OMA.FilePrefix;
catch
  p.OMA.FilePrefix = [ 'oma_' p.OMA.DomainName '_' ];
end

try, p.HourPlot.DomainName;
catch
  p.HourPlot.DomainName = p.Totals.DomainName;
end

try, p.HourPlot.FilePrefix;
catch
  p.HourPlot.FilePrefix = [ 'hour_plot_' p.HourPlot.Type '_' ...
                      p.HourPlot.DomainName '_' ];
end

% Web write stuff
try, p.Totals.WebWrite;
catch
    p.Totals.WebWrite = false;
end
try, p.OMA.WebWrite;
catch
    p.OMA.WebWrite = false;
end

% Place the OMA boundary over the totals plot?  Set false by default.
try 
    p.Totals.OMAboundary;
catch
    p.Totals.OMAboundary = false;
end

%%
% OK, if requested, load the OMA boundary
if p.Totals.OMAboundary
    % These boundaries were created using makeOMA_XXXX.m, in the
    % makeDomainBoundary(coastFileName) part of the program.  This program
    % expects the variable containing the OMA boundary to be named
    % OMA_boundary, containing a variable called OMA_boundary
    try
        load(p.OMA.BoundaryFileName);
    catch
        p.Totals.OMAboundary = false;
        fprintf('OMA boundary file not found ... skip plotting it\n');
    end
end

%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load totals data (of OMA or Totals type depending on config)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = p.HourPlot.Type;
[tdn,tfn] = datenum_to_directory_filename( p.(s).BaseDir, D, ...
                                           p.(s).FilePrefix, ...
                                           p.(s).FileSuffix, p.MonthFlag );
tdn = tdn{1};

if ~exist( tdn, 'dir' )
  mkdir(tdn);
end

data = load(fullfile(tdn,tfn{1}));

% Set the title if not specified.
try, p.HourPlot.TitleString;
catch
  p.HourPlot.TitleString = [p.HourPlot.DomainName,' ',p.HourPlot.Type,': ', ...
                            datestr(D,'dd-mmm-yyyy HH:MM'),' ',data.TUV.TimeZone];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define axis limits if necessary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try, p.HourPlot.axisLims;
catch, p.HourPlot.axisLims = axisLims( data.TUV, 0.1 ); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define Distance Bar and Velocity Scale location if necessary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try, p.HourPlot.VelocityScaleLocation;
catch
  p.HourPlot.VelocityScaleLocation = p.HourPlot.axisLims([1,3]) + ...
      0.9 * diff(reshape(p.HourPlot.axisLims,[2,2]));
end
try, p.HourPlot.DistanceBarLocation;
catch
  p.HourPlot.DistanceBarLocation = p.HourPlot.VelocityScaleLocation - ...
      [0,0.05] .* diff(reshape(p.HourPlot.axisLims,[2,2]));
end


%%
% Plot the basemap
[hdls] = makeBase(p,true);
hold on
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Data - NOTE:  IF ALL TUV DATA ARE NAN, plotData function, at least
% with the m_vec call, FAILS!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdls = [];
[hdls.plotData,I] = plotData( data.TUV, 'm_vec', D, p.HourPlot.VectorScale, ...
                              p.HourPlot.plotData_xargs{:} );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot location of sites
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sl = vertcat( data.RTUV.SiteOrigin );
% m_plot will plot symbols just outside the plot box, and it looks crappy.
% So only plot the ones that are inside the plot limits.
plotRect = makeBox(p.HourPlot.axisLims);
ins = inpolygon(sl(:,1),sl(:,2),plotRect(:,1),plotRect(:,2));
hdls.RadialSites = m_plot( sl(ins,1), sl(ins,2), ...
                         '^k','markersize',10,'linewidth',3);
%%
% If requested, plot the OMA boundary in a light gray line
if p.Totals.OMAboundary
    m_plot(OMA_boundary(:,1),OMA_boundary(:,2),'-','color',[0.75,0.75,0.75])
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make sure color ticks are defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  p.HourPlot.ColorTicks;
catch
  ss = max( cart2magn( data.TUV.U(:,I), data.TUV.V(:,I) ) );
  p.HourPlot.ColorTicks = 0:10:ss+10;
end
caxis( [ min(p.HourPlot.ColorTicks), max(p.HourPlot.ColorTicks) ] );
colormap( feval( p.HourPlot.ColorMap, numel(p.HourPlot.ColorTicks)-1 ) );
cax = colorbar;
hdls.colorbar = cax;
hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                    'saturated.'], 'fontsize', 14 );
hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 14 );

set(cax,'ytick',p.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add title string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdls.title = title( p.HourPlot.TitleString, 'fontsize', 20 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print if desired
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if p.HourPlot.Print
    [odn,ofn] = datenum_to_directory_filename( p.HourPlot.BaseDir, D, ...
                                               p.HourPlot.FilePrefix, ...
                                               '.eps', p.MonthFlag );
    odn = odn{1}; ofn = ofn{1};
    ofn = fullfile(odn,ofn);
    if ~exist( odn, 'dir' )
        mkdir(odn);
    end
    
    % Set the figure for background mode, and print to file
    bgprint(ofn,'-depsc2',p.Plot.PaperWidth,p.Plot.PaperHeight)
    % Convert to gif format
    [outF,suc]=convertPlot(ofn,'gif',true);
    
    % THIS IS TOTAL MAGIC FOR THE WEB PAGE
    if p.(s).WebWrite
        copyfile(outF,fullfile(p.(s).WebBase,p.(s).WebName));
    end
end

hold off
