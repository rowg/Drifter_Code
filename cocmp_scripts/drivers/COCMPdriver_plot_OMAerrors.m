function [ ofn, hdls, p ] = COCMPdriver_plot_OMAerrors( D, p, varargin )

ofn = '';
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters and parameter checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = HFRPdriver_default_conf( p );

% Merge
mand_params = { 'OMA.BaseDir' };
p = checkParamValInputArgs( p, {}, mand_params, varargin{:} );


%%
% THIS function currently only works for OMA, maybe for TUV in the future,
% so just hardwire for now.
p.HourPlot.Type='OMA';

%%
try, p.OMA.DomainName;
catch
    p.OMA.DomainName = p.Totals.DomainName;
end
try, p.OMA.FilePrefix;
catch
    p.OMA.FilePrefix = [ 'oma_' p.OMA.DomainName '_' ];
end

try, p.HourPlot.FilePrefix;
catch
  p.HourPlot.FilePrefix = [ 'hour_plot_' p.HourPlot.Type 'error_' ...
                      p.HourPlot.DomainName '_' ];
end

% Web write stuff
try, p.OMA.WebWrite;
catch
    p.OMA.WebWrite = false;
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load OMA data - NOTE: OMA data has a conf
% struct saved as p - need to deal with this!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = p.HourPlot.Type;
pp = p;
[tdn,tfn] = datenum_to_directory_filename( p.(s).BaseDir, D, ...
                                           p.(s).FilePrefix, ...
                                           p.(s).FileSuffix, p.MonthFlag );
tdn = tdn{1};

if ~exist( tdn, 'dir' )
  mkdir(tdn);
end

load(fullfile(tdn,tfn{1}));
% Now the p struct is the one loaded from the OMA file, replace with the
% one input in the function definition.
p = pp;

%%
% Set the title if not specified.
try, p.HourPlot.TitleString;
catch
    p.HourPlot.TitleString = [p.HourPlot.DomainName,' ', ...
        p.HourPlot.Type,' Error: ', ...
        datestr(D,'dd-mmm-yyyy HH:MM'),' (10*TotalError)'];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define axis limits if necessary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try, p.HourPlot.axisLims;
catch, p.HourPlot.axisLims = axisLims( TUV, 0.1 ); 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define Distance Bar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try, p.HourPlot.DistanceBarLocation;
catch
    p.HourPlot.DistanceBarLocation = p.HourPlot.VelocityScaleLocation - ...
    [0,0.05] .* diff(reshape(p.HourPlot.axisLims,[2,2]));
end
%%
% Plot the basemap
[hdls] = makeBase(p,false);
hold on
%%
% Grid the OMA data - gridTotals ASSUMES that the OMA lon/lat points are on
% a rectangular, but incomplete grid, SO... your OMA grid must be in this
% form.
% Remove any extra currents off the end of the OMA struct if necessary.
try
    TUV.U = TUV.U(1:end-TUV.OtherMetadata.AddUV.Number,:);
    TUV.V = TUV.V(1:end-TUV.OtherMetadata.AddUV.Number,:);
    TUV.LonLat = TUV.LonLat(1:end-TUV.OtherMetadata.AddUV.Number,:);
    TUV.Depth = TUV.Depth(1:end-TUV.OtherMetadata.AddUV.Number);
catch
    disp('No extra currents on the end')
end
[TG,a,b]=gridTotals(TUV,true,false);
Lon = reshape(TG.LonLat(:,1),a);
Lon = reshape(TG.LonLat(:,1),a);
Lat = reshape(TG.LonLat(:,2),a);
EE = reshape(TG.ErrorEstimates(1).TotalErrors,a);

% FUDGE IS A MAGIC NUMBER TO GIVE THE ERROR MEASURMENTS A 0-10 RANGE.
fudge = 10;
[cs,h]=m_contourf(Lon,Lat,EE*fudge);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make sure color ticks are defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HARDWIRE THE RANGE FOR NOW AS WELL
p.HourPlot.ColorTicks = 0:1:10;
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

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add title string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdls.title = title( p.HourPlot.TitleString, 'fontsize', 20 );

%%
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
    if p.OMA.WebWrite
        copyfile(outF,fullfile(p.OMA.WebBase,p.OMAerror.WebName));
    end
end

hold off

