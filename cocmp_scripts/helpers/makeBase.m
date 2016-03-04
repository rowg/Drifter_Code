function [hdls] = makeBase(p,velArrowFlag,varargin)

% This is a set of plot objects that we place on plots. 
%
% These objects go on all plots:
% coastline
% distance scale
% the velocity scale, and the distance bar
% 
% Inputs:
%         p - the configuration structure
%         velArrowFlag - draw velocity arrow - false by default

if ~exist('velArrowFlag','var')  ||  isempty(velArrowFlag)
    velArrowFlag = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters and parameter checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = HFRPdriver_default_conf( p );

% Merge
mand_params = { 'HourPlot.VectorScale' };

p = checkParamValInputArgs( p, {}, mand_params, varargin{:} );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Basemap with nice boundary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clf
plotBasemap( p.HourPlot.axisLims(1:2), p.HourPlot.axisLims(3:4), ...
             p.Plot.coastFile, p.Plot.Projection, p.Plot.plotBasemap_xargs{:} ...
             );
m_ungrid;
m_grid( p.Plot.m_grid_xargs{:} );

hold on

if p.Plot.Speckle
  m_usercoast( p.Plot.coastFile, 'speckle', 'color', 'k' )
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add distance bar and velocity bar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First do the velocity bar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if velArrowFlag
    [hdls.VelocityScaleArrow,hdls.VelocityScaleText,p.HourPlot.VelocityScaleLocation] ...
    = plotVelocityScale( p.HourPlot.VelocityScaleLength, p.HourPlot.VectorScale, ...
                         [num2str(p.HourPlot.VelocityScaleLength) ' cm/s'], ...
                         p.HourPlot.VelocityScaleLocation,'horiz', ...
                         'm_vec','linewidth',2 );
    set(hdls.VelocityScaleText,'fontsize',16,'fontweight','bold')
    set(hdls.VelocityScaleArrow,'facecolor','k')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add distance bar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[hdls.DistanceBar,hdls.DistanceBarText, ...
    p.HourPlot.DistanceBarLocation] = ...
                    m_distance_bar( p.HourPlot.DistanceBarLength, ...
                    p.HourPlot.DistanceBarLocation,'horiz',0.2 );
set(hdls.DistanceBar,'linewidth',2 );
set(hdls.DistanceBarText,'fontsize',16,'fontweight','bold');

