%==============================================================================
% skill_score_ncls_example $Revision: 1.0                    Date: 2015/06/18
%
%          Copyright (C) USF, Yonggang Liu, 2015. 
%
% This is an examle code to calculate and display the skill scores of trajectory 
% simulation in the Gulf of Mexico.  Also show the corresponding modeled and 
% observed trajectories.  This MATLAB code reproduce Figure 3 of Liu et al.(2014).
% The definition of the skill score can be found in Liu and Weisberg (2011) and
% Liu e tal. (2014).
%
% The following MATLAB functions are needed:
%  
%  skill_score_ncls.m  
%  sw_dist.m
%  plot_google_map.m
%  crop.m
%
%
% References:
%
%  Liu, Y., and R.H. Weisberg (2011), Evaluation of trajectory modeling in 
%  different dynamic regions using normalized cumulative Lagrangian separation,
%  Journal of Geophysical Research, 116, C09013, doi:10.1029/2010JC006837. 
%
%  Liu, Y., R. H. Weisberg, S. Vignudelli, and G. T. Mitchum (2014), Evaluation
%  of altimetry-derived surface current products using Lagrangian drifter
%  trajectories in the eastern Gulf of Mexico, J. Geophys. Res. Oceans, 119,
%  2827-2842, doi:10.1002/2013JC009710.
%
%
% Author contact information:
%
%  Yonggang Liu
%  University of South Florida
%  College of Marine Science
%  St. Petersburg, Florida 33701,
%  U.S.A.
%
% Email: yliu@mail.usf.edu
%        yliu18@gmail.com
%
% http://ocgweb.marine.usf.edu/~liu
%
%===============================================================================

   
%% load the trajectory model output: 

% drifter_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20150515_Model_Skill_Score/20160303_Drifter_Data_Virtual_HFR/';
% drifter_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20150515_Model_Skill_Score/20160329_Drifter_Data_Virtual_HYCOM/';
%  drifter_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160410_CG_Drifter_Experiment/20160606_Drifter_Data_Virtual_HFR_05/';
% drifter_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160410_CG_Drifter_Experiment/20160606_Drifter_Data_Virtual_HFR_13/';
% drifter_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160410_CG_Drifter_Experiment/20160606_Drifter_Data_Virtual_HYCOM/';
drifter_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160410_CG_Drifter_Experiment/20160607_Drifter_Data_Virtual_HFR_13_QC/'

data_type='HFR';
% data_type='HYCOM';
file_type='*.mat';
d=dir([drifter_path file_type]);

%% loop to pick the particular drifter
for kk=1:3
    D=load([drifter_path d(kk).name]);
% end %% put end here if you want to plot the drifters one at a time
 
 
 % The trajectory model output is saved in a structure D, which also comprises
   % of the observed drifter locations. The trajectory model was initialized 
   % every day from the observed drifter location, and simulated for 5 days
   % (actually 39*3 = 117 hours).  
   %
   % Observed drifter locations:
   % 
   %   D.x    hourly longitude [deg]
   %   D.y    hourly latitude [deg]
   %   D.ti   hourly timestamp [datenum]
   %
   %   D.xd   3-hourly longitude [deg]
   %   D.yd   3-hourly latitude [deg]
   %   D.tid  3-hourly timestamp [datenum]
   % 
   % Simulated drifter locations:
   %
   %   For drifter initiated on day 1:
   %   D.p1.x        3-hourly longitude [deg]
   %   D.p1.y        3-hourly latitude [deg]
   %   D.p1.dateini  time of initialization [datenum], not to be used in this code
   %   D.p1.iter     number of output time steps, not to be  used in this code
   %
   %   For drifter initiated on day 2:
   %   D.p2.x        3-hourly longitude [deg]
   %   D.p2.y        3-hourly latitude [deg]
   %   D.p2.dateini  time of initialization [datenum], not to be used in this code
   %   D.p2.iter     number of output time steps, not to be  used in this code
   %
   %   ...... and so on ...... for every day (22 days in this example).
   %
   %   D.ti_dpls     timestamp of trajectory model initialization [datenum]
    
 
  figure('visible','on'); orient tall;
  

 % Plot simulated drifter trajectories:
 % The trajectory model was initiated every day from the observed drifter
 % location. So, plot a simulated trajectory for a new virtual drifter each day.

%   nday = length(D.ti_dpls);  % number of days we released drifters
  nday=23;
  ti=1;      % interval between estimates 1 for 1 hour
  ts=24/ti;  % time step for plotting
  length=floor(D.p1.iter/24);  % length of time the drifters go for
  
  hold on;
  
  for ii = 1:nday
      eval(['px = D.p' num2str(ii) '.x(1:end);']); % 3 days
      eval(['py = D.p' num2str(ii) '.y(1:end);']);
      lmod = plot(px,py,'m-'); hold on;
      plot(px(ts:ts:length*ts),py(ts:ts:length*ts),'mo','markersize',4); % daily markers
                                   
  end
    
 

 % plot observed drifter trajectory:
 
  %nlast = nday*ts + length*ts;
  nlast = floor(nday*ts); 
  lobs = plot(D.x(1:nlast),D.y(1:nlast),'k-','linewidth',1); hold on;
 
  %% add legend for real and virtual drifter
  L = legend([lmod, lobs],'modeled','observed',2,'Location','NorthWest');
  set(L,'color','w','TextColor','k', 'fontsize',9);
  
 % label drifter timestamp every step days:
 step=3;

 
  x5 = D.x(1:ti*ts*step:end);
  y5 = D.y(1:ti*ts*step:end);
  ti5 = D.ti(1:ti*ts*step:end);
  txt5 = datestr(ti5,6);
  
 
  scatter(x5,y5,'ko','filled'); hold on
  text(x5+0.08,y5,txt5,'fontsize',10,'color','w');
 
 
 % calculate skill scores:
  [xo, yo, s3o, N] = skill_score_ncls_v2(D,ts);
  
  
  cmap = colormap(jet);
  scatter(xo(~isnan(s3o)),yo(~isnan(s3o)),70,s3o(~isnan(s3o)),'filled');
  caxis([0,1]); hold on; % stopped working HJR 20160303
%  scatter(xo,yo,70,s3o,'filled'); caxis([0,1]); hold on;
  
%% determine bounds of plotting box upon the drifter data
lon.min=floor(min(D.x));
lon.max=ceil(max(D.x));
lat.min=floor(min(D.y));
lat.max=ceil(max(D.y));
    
xlim = [lon.min, lon.max];
ylim = [lat.min, lat.max];

% xlim = [-73, -72];
% ylim = [40, 41];


  xtick = [floor(xlim(1)) :0.5: ceil(xlim(end))]; 
  ytick = [floor(ylim(1)) :0.5: ceil(ylim(end))]; 
  mlr = pi*mean(ylim)/180;
   
  set(gca,'xlim',xlim,'ylim',ylim, ...
          'xtick',xtick,'ytick',ytick,...
	  'xticklabel',-xtick,'yticklabel',ytick,...
	  'tickdir','out','fontsize',10,'dataaspectratio',[1/cos(mlr) 1 1]);
  
  xlabel('Longitude (^oW)','FontSize',12);
  ylabel('Latitude (^oN)','FontSize',12);

  title([data_type ' Skill Score for Drifter ' D.name_str])
      
plot_google_map('maptype','satellite','alpha',1,'AutoAxis',0);
%  plot_google_map
  pos = [.8, .6, .015 .2];

 % colorbarv4GE(pos,[0:.1:1],[0:.2:1],' Skill score',1)
  colorbarv4GE(pos,[0:.1:1],[0:.2:1],'s_3',1)

  png0 = ['skill_score_' data_type '_map_' D.name_str '.png'];
  eval(['print  -dpng -r300 ' png0 ';']); crop(png0);
  
  figure(2)
 
  plot(D.ti_dpls,s3o,'-','LineWidth',2,'Color','k')
  hold on
  scatter(D.ti_dpls,s3o,N*5,'k')
 format_axis(gca,D.ti(1),D.ti(end),7,1,'mm/dd',0,1,0.2)
 s3o_str=nanmean(s3o);
 textbp(['Mean Skill Score: ' sprintf('%5.2f',s3o_str)])
 
 xlabel('Date')
 ylabel('Skill Score')
 title([data_type ' Skill Score for Drifter ' D.name_str])
 timestamp(2,'skill_score_HFR_example.m')
 print(2,'-dpng','-r400',['skill_score_' data_type '_ts_' D.name_str '.png'])
 
 close all
 
end
  disp('DONE!');
