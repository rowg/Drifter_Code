%% This m script was written to generate trajectory data from the 5 MHz systems 

close all
clear all

%% determine which computer you are running the script on
compType = computer;

if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes';
else
     root = '/home';
end

%% declare some configuration variables
conf.Plot.script_path='/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/';
conf.Plot.script_name='trajectories_from_13_drifters.m';
conf.Data.Institution='Rutgers University';
conf.Data.Contact='Hugh Roarty hroarty@marine.rutgers.edu';
conf.Data.Info='This data file is US Coast Guard drifter data from SLDMB as provided by ASA along with virtual drifter data from HFR';
%conf.Save.directory='/Users/hroarty/COOL/01_CODAR/MARACOOS/20150515_Model_Skill_Score/20160303_Drifter_Data_Virtual_HFR/';
% conf.Save.directory='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160410_CG_Drifter_Experiment/20160607_Drifter_Data_Virtual_HFR_13_QC/';
conf.Save.directory='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160410_CG_Drifter_Experiment/20180530_Drifter_Data_Virtual_HFR_13_no_clean/';


%% load the drifter data
%drifter_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20150515_Model_Skill_Score/20150615_Drifter_Data/mat_files/';
% drifter_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160410_CG_Drifter_Experiment/20160510_Drifter_Data/mat_files/';
drifter_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160410_CG_Drifter_Experiment/20160510_Drifter_Data/mat_files_20160510_to_20160706/';

file_type='*.mat';
d=dir([drifter_path file_type]);

%% loop to pick the particular drifter
drifter_loop=[4 5 7];

for ii=drifter_loop
    drifter=load([drifter_path d(ii).name]);
%end

%% determine bounds of mask based upon the drifter data
lon.min=floor(min(drifter.Lon));
lon.max=ceil(max(drifter.Lon));
lat.min=floor(min(drifter.Lat));
lat.max=ceil(max(drifter.Lat));
 ax =[lon.min lon.max lat.min lat.max];
conf.HourPlot.mask=[ax([1 2 2 1 1])' ax([3 3 4 4 3])'];


%% load the total data
        
conf.Totals.DomainName='BPU';
conf.Totals.BaseDir=[root '/codaradm/data/totals/maracoos/oi/mat/13MHz/'];
% conf.Totals.BaseDir=[root '/hroarty/data/realtime/totals/maracoos/oi/mat/13MHz/'];
conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix='.mat';
conf.Totals.MonthFlag=1;


%% find the index of where we want to start the drifter scenarios
tmp = abs(drifter.time-datenum(2016,5,10));
[~,I] = min(tmp); %index of closest value
%dtime=min(drifter.time):1/24:max(drifter.time);
%dtime=drifter.time(I):1/24:max(drifter.time);
dtime=drifter.time(I):1/24:drifter.time(end);

%% find the index of where we want to end the drifter scenarios
% tmp = abs(drifter.time-datenum(2015,4,14));
% [~,I] = min(tmp); %index of closest value
% %dtime=min(drifter.time):1/24:max(drifter.time);
% dtime=drifter.time(1):1/24:max(drifter.time(I));
% %dtime=drifter.time(I):1/24:drifter.time(I)+6;

%% create strings to use in the map filename
timestr_sd=datestr(dtime(1),'yyyymmdd');
timestr_ed=datestr(dtime(end),'yyyymmdd');


% F=filenames_standard_filesystem(conf.Radials.BaseDir,conf.Radials.Sites,...
%     conf.Radials.Types,dtime,conf.Radials.MonthFlag,conf.Radials.TypeFlag);

[f]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime,conf.Totals.FilePrefix,conf.Totals.FileSuffix,conf.Totals.MonthFlag);

%% Concatenate the total data
[TUVcat,goodCount]=catTotalStructs(f,'TUV',false,false,true,conf);
% [TUVcat,goodCount]=catTotalStructs(f,'TUVosn',false,false,false,conf);

% Clean the total field 
% TUVcat=cleanTotals(TUVcat,conf.Totals.MaxTotSpeed,conf.OI.cleanTotalsVarargin{:});

%% Mask the data based on the land mask for NY harbor
%% mask any totals outside axes limits
%[TUVcat,I]=maskTotals(TUVcat,conf.Totals.Mask,true); % true keeps vectors in box

%% Grid the total data onto a rectangular grid
[TUVcat,dim]=gridTotals(TUVcat,0,0);

X=TUVcat.LonLat(:,1);
Y=TUVcat.LonLat(:,2);
U=TUVcat.U;
V=TUVcat.V;
tt=TUVcat.TimeStamp;

[X1,Y1]=meshgrid(unique(X),unique(Y));

[r,c]=size(X1);

U1=reshape(U,r,c,length(TUVcat.TimeStamp));
V1=reshape(V,r,c,length(TUVcat.TimeStamp));



%% loop through the real drifter data to generate the release point every
%% 24 hours, since the data is hourly 24 index spots is 24 hours
%% 24*3 simulate for 3 days
  days=2;
%% loop to start at I
% loop1=I:24:length(drifter.time)-days*24;
%% loop to stop at end of I
loop1=I:24:length(drifter.time)-days*24;

for jj=1:length(loop1)
    
    %% generate the drifter release points
    %% wp1 latitude longitude 
    wp=[drifter.Lon(loop1(jj)) drifter.Lat(loop1(jj)) ];

    %% declare the time that you want to generate the trajectories for
  
    tspan=drifter.time(loop1(jj)):1/24:drifter.time(loop1(jj))+days;
    
    %% generate the particle trajectories
    [x,y,ts]=particle_track_ode_grid_LonLat(X1,Y1,U1,V1,tt,tspan,wp);
    
    %% save the virtual drifter data in a structured array
    D.(sprintf('p%d',jj)).x=x;
    D.(sprintf('p%d',jj)).y=y;
    D.(sprintf('p%d',jj)).dateini=ts(1);
    D.(sprintf('p%d',jj)).iter=length(ts);
    
end


%% save the actual drifter data with the virtual data
% this is the hourly data
D.x=drifter.Lon(I:end)';
D.y=drifter.Lat(I:end)';
D.ti=drifter.time(I:end)';

% this is data every 3 hours
D.xd=drifter.Lon(I:3:end);
D.yd=drifter.Lat(I:3:end);
D.tid=drifter.time(I:3:end);

D.ti_dpls=drifter.time(loop1);

% this is the name of the drifter
D.name_num=drifter.name_num;
D.name_str=drifter.name_str;

 %% add metadata to mat file that will be saved
D.MetaData.Script=conf.Plot.script_name;
D.MetaData.Institution=conf.Data.Institution;
D.MetaData.Contact=conf.Data.Contact;
D.MetaData.Information=conf.Data.Info;

%% save the particle trajectory to a mat file
save([conf.Save.directory 'USCG_' drifter.name_str '_HFR_skill_score_' datestr(min(D.ti),'yyyy_mm_dd') '.mat'], '-struct', 'D');

end

% %% plot the results
% %% setup the basemap and plot the basemap
% %conf.HourPlot.axisLims=[-71 -69 39.5 41.5];
% conf.HourPlot.axisLims=[min(wp(:,2))-15/60 max(wp(:,2))+15/60 min(wp(:,1))-15/60 max(wp(:,1))+15/60];
% conf.Plot.coastFile='/Users/hroarty/data/coast_files/MARA_coast.mat';
% conf.Plot.Projection='mercator';
% 
% conf.Plot.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS/20150611_NE_drifters/';
% 
% [r1,c1]=size(x);
% 
% for ii=1:r1
% hold on
% %figure
% plotBasemap(conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),...
%     conf.Plot.coastFile,conf.Plot.Projection,'patch','g');
% 
% % if ii==1
% %     m_plot(x(1,:),y(1,:),'.','Color','r');
% % end
% 
% %% entire track
% if ii>=2 
%     m_plot(x(1:ii,:),y(1:ii,:),'-','Color',[0.5 0.5 0.5]);
% end 
% 
% 
% %% last 6 hours
% if ii>6
%     m_plot(x(ii-6:ii,:),y(ii-6:ii,:),'-','Color','k','LineWidth',2);
% elseif ii>1
%     m_plot(x(1:ii,:),y(1:ii,:),'-','Color','k','LineWidth',2);
% end
% 
% %% last location of drifter
% m_plot(x(ii,:),y(ii,:),'ro','MarkerFaceColor','r','Markersize',3);
% 
% %% release point
% %m_plot(drifter(1),drifter(2),'r*')
% 
% N=append_zero(ii);
% 
% 
% %%-------------------------------------------------
% %% Add title string
% 
% conf.HourPlot.TitleString = [conf.Totals.DomainName,' Particle Trajectories: ', ...
%                             datestr(tspan(ii),'yyyy/mm/dd HH:MM'),' ',TUVcat.TimeZone(1:3)];
% 
% hdls.title = title( conf.HourPlot.TitleString, 'fontsize', 16,'color',[0 0 0] );
% 
% print(1,'-dpng','-r200',[ conf.Plot.BaseDir conf.Totals.DomainName '_'  N '.png'])
% 
% close all
% clear conf.HourPlot.TitleString
% end
%
% timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_25.m')
% 
% 


