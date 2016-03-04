function [ ofn, hdls, p ] = COCMPdriver_plot_meanTUV( D, p, varargin )

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
% Load totals data (of OMA or Totals type depending on config)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.meanTUV.FilePrefix = strcat(p.meanTUV.Type,int2str(p.meanTUV.avgTime),'hr_',p.Totals.DomainName,'_');
[tdn,tfn] = datenum_to_directory_filename( p.meanTUV.BaseDir, D, ...
                                           p.meanTUV.FilePrefix, ...
                                           p.meanTUV.FileSuffix, p.MonthFlag );
tdn = tdn{1};

try
    load(fullfile(tdn,tfn{1}),'TUV','TUVcat');
catch
    fprintf('%s doesn''t exist, no plotting\n',fullfile(tdn,tfn{1}));
    ofn = []; hdls = [];
    return;
end
% Plot only the points that meet a threshold number of hours
ind = sum(~isnan(TUVcat.U),2) >= p.meanTUV.Thresh;
TUV.U(~ind) = NaN;
TUV.V(~ind) = NaN;

% Set the title if not specified.
try, p.meanTUV.TitleString;
catch
  p.meanTUV.TitleString = {[p.meanTUV.DomainName,' ',p.meanTUV.Type, ...
                           ' ',int2str(p.meanTUV.avgTime),'hr mean: ', ...
                           'From ',datestr(TUVcat.TimeStamp(1),'dd-mmm-yyyy HH:MM')],
                           ['to ',datestr(TUVcat.TimeStamp(end),'dd-mmm-yyyy HH:MM'),' ',TUV.TimeZone]};
end

% Web stuff
try, p.meanTUV.WebWrite;
catch
    p.meanTUV.WebWrite = false;
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

%%
% Plot the basemap
[hdls] = makeBase(p,true);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Data - NOTE:  IF ALL TUV DATA ARE NAN, plotData function, at least
% with the m_vec call, FAILS!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdls = [];
[hdls.plotData,I] = plotData( TUV, 'm_vec', D, p.HourPlot.VectorScale, ...
                              p.HourPlot.plotData_xargs{:} );

try
  p.HourPlot.ColorTicks;
catch
  ss = max( cart2magn( TUV.U(:,I), TUV.V(:,I) ) );
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
hdls.title = title( p.meanTUV.TitleString, 'fontsize', 20 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print if desired
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if p.HourPlot.Print
    [odn,ofn] = datenum_to_directory_filename( p.meanTUV.PlotDir, D, ...
                                               p.meanTUV.FilePrefix, ...
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
    if p.meanTUV.WebWrite
        copyfile(outF,fullfile(p.meanTUV.WebBase,p.meanTUV.WebName));
    end
end

hold off
