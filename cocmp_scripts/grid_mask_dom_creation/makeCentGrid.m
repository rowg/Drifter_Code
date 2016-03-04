clear all
close all

coastFileName = 'COCMP_Big_mercat.mat';
lims=[-123.5,-121.7,36.2,38.05];

plotBasemap(lims(1:2),lims(3:4),coastFileName,'mercator','patch','g');
hold on

dat = load('COCMP_Master_Grid_3km.dat');
[Lon,Lat]=meshgrid_vector_data(dat(:,1),dat(:,2));
Lon = Lon(1:2:end,1:2:end);
Lat = Lat(1:2:end,1:2:end);
Lon = Lon(:);
Lat = Lat(:);

% [X,bi,ptH,lineH]=makeDomainBoundary('COCMP_Big_mercat.mat');
% save centMask X bi lims coastFileName
load centMask

ind = inpolygon(Lon,Lat,X(:,1),X(:,2));
centGrid = [Lon(ind),Lat(ind)];
m_plot(centGrid(:,1),centGrid(:,2),'m.')

fid = fopen('CENT.grid','w');
fprintf(fid,'%10.5f %9.4f\n',centGrid');
fclose(fid);