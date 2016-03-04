
clear all
close all

% % D = datenum(2008,3,26,2,0,0);
% % 
% % load('/Volumes/Extras/RealTime/Data/Totals/TEST/2008_03/tuv_TEST_2008_03_26_0200.mat')
% % conf = p;
% % 
% % % Pick a site
% % % k = 3; %DRAK
% % % k = 5; %SLID
% % % k = 1; %BML1
% % k = 2; %Prey

% % D = datenum(2008,03,26,3,0,0);
% % load('/Volumes/Extras/RealTime/Data/Totals/TEST/2008_03/tuv_TEST_2008_03_26_0300.mat')
% % conf = p;
% % % k = 29; %PAFS
% % k = 32; %BMLR

D = datenum(2008,03,28,23,0,0);
load('/Volumes/Extras/RealTime/Data/Totals/TEST/2008_03/tuv_TEST_2008_03_28_2300.mat')
conf = p;
% k = 4; %PILR
k = 14; %RAGG


fprintf('PROCESSING: %s\n',Rorig(k).SiteName);

conf.RadialPlot.axisLims = axisLims(Rorig(k),0.2);

conf.RadialPlot.TitleString = [Rorig(k).SiteName,' ',Rorig(k).Type,': ',datestr(D,'dd-mmm-yyyy HH:MM')];
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
hdls.Rorig = [];

% Original data
RR = Rorig(k);
RR = subsrefRADIAL( RR, isfinite( RR.RadComp ), ':' ); % Must have 1 timestep
hdls.Rorig(k) = plotData( RR, 'grid', 'm_plot', 'color','k', ...
                        conf.RadialPlot.plotData_xargs{:} );

                    
[boundary,bi,ptHand,lineHand] = makeDomainBoundary(conf.Plot.coastFile);
fprintf('%10.5f %9.5f\n',boundary')
m_plot(boundary(:,1),boundary(:,2),'k','linewidth',2.5);
