%% This m script was written to generate trajectory data from the 25 MHz systems 

close all
clear all

%% determine which computer you are running the script on
compType = computer;

if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes';
else
     root = '/home';
end

%% load the total data
        
conf.Totals.DomainName='MARA';
conf.Totals.BaseDir=[root '/codaradm/data/totals/maracoos/oi/mat/5MHz/'];
conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix='.mat';
conf.Totals.MonthFlag=1;
conf.Totals.Mask='/Users/hroarty/data/mask_files/25MHz_Mask.txt';

dtime=datenum(2014,10,25,0,0,2):1/24:datenum(2014,10,28,00,0,0);

%% create strings to use in the map filename
timestr_sd=datestr(dtime(1),'yyyymmdd');
timestr_ed=datestr(dtime(end),'yyyymmdd');


% F=filenames_standard_filesystem(conf.Radials.BaseDir,conf.Radials.Sites,...
%     conf.Radials.Types,dtime,conf.Radials.MonthFlag,conf.Radials.TypeFlag);

[f]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime,conf.Totals.FilePrefix,conf.Totals.FileSuffix,conf.Totals.MonthFlag);

%% Concatenate the total data
[TUVcat,goodCount]=catTotalStructs(f,'TUV',false,false,false,conf);

%% Mask the data based on the land mask for NY harbor
%% mask any totals outside axes limits
%[TUVcat,I]=maskTotals(TUVcat,conf.Totals.Mask,true); % true keeps vectors in box

%% Grid the total data onto a rectangular grid
[TUVcat,dim]=gridTotals(TUVcat,0,0);

%% generate the drifter release points
%% wp1 latitude longitude 
%wp1=[40.5 -70];
%wp1=[39.5 -73];
wp1=[40.4802 -72.5607];   
%wp1=[35.25 -75];
resolution=3;
range=30;

[wp]=release_point_generation_matrix(wp1,resolution,range);


X=TUVcat.LonLat(:,1);
Y=TUVcat.LonLat(:,2);
U=TUVcat.U;
V=TUVcat.V;
tt=TUVcat.TimeStamp;
tspan=TUVcat.TimeStamp;
drifter=[wp1(:,2) wp1(:,1)];


[X1,Y1]=meshgrid(unique(X),unique(Y));

[r,c]=size(X1);

U1=reshape(U,r,c,length(TUVcat.TimeStamp));
V1=reshape(V,r,c,length(TUVcat.TimeStamp));

%% generate the particle trajectories
[x,y,ts]=particle_track_ode_grid_LonLat(X1,Y1,U1,V1,tt,tspan,drifter);

%% plot the results
%% setup the basemap and plot the basemap
%conf.HourPlot.axisLims=[-71 -69 39.5 41.5];
conf.HourPlot.axisLims=[min(wp(:,2))-15/60 max(wp(:,2))+15/60 min(wp(:,1))-15/60 max(wp(:,1))+15/60];
conf.Plot.coastFile='/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.Plot.Projection='mercator';

conf.Plot.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS/20150515_Model_Skill_Score/20160303_Drifter_38689/';

[r1,c1]=size(x);

for ii=1:r1
hold on
%figure
plotBasemap(conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),...
    conf.Plot.coastFile,conf.Plot.Projection,'patch','g');

% if ii==1
%     m_plot(x(1,:),y(1,:),'.','Color','r');
% end

%% entire track
if ii>=2 
    m_plot(x(1:ii,:),y(1:ii,:),'-','Color',[0.5 0.5 0.5]);
end 


%% last 6 hours
if ii>6
    m_plot(x(ii-6:ii,:),y(ii-6:ii,:),'-','Color','k','LineWidth',2);
elseif ii>1
    m_plot(x(1:ii,:),y(1:ii,:),'-','Color','k','LineWidth',2);
end

%% last location of drifter
m_plot(x(ii,:),y(ii,:),'ro','MarkerFaceColor','r','Markersize',3);

%% release point
%m_plot(drifter(1),drifter(2),'r*')

N=append_zero(ii);


%%-------------------------------------------------
%% Add title string

conf.HourPlot.TitleString = [conf.Totals.DomainName,' Particle Trajectories: ', ...
                            datestr(tspan(ii),'yyyy/mm/dd HH:MM'),' ',TUVcat.TimeZone(1:3)];

hdls.title = title( conf.HourPlot.TitleString, 'fontsize', 16,'color',[0 0 0] );

print(1,'-dpng','-r200',[ conf.Plot.BaseDir conf.Totals.DomainName '_'  N '.png'])

close all
clear conf.HourPlot.TitleString
end






% timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_25.m')
% 
% 


