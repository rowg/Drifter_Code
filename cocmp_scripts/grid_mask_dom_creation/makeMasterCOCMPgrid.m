clear all
close all

plotBasemap([-124.1,-121.2],[35.5,39],'COCMP_Big_mercat','mercator');

% Set the region of interest - this will be the boundary of the master
% grid.
vert = [-124,   35.5
        -121.25,35.5
        -121.25,38.75
        -124,   38.756];
vert(end+1,:) = vert(1,:);

hold on
m_plot(vert(:,1),vert(:,2),'*-r')


% Make a master COCMP grid with 3 km spacing in both lon and lat.
[Lon,Lat]=LonLat_grid(vert(1,:),vert(3,:),[3,3]);
m_plot(Lon,Lat,'.g');


% Create the indexing for the Lon Lat grid
[r,c]=size(Lon);
[col,row]=meshgrid(1:c,1:r);

% Write it out to a file
out = [Lon(:),Lat(:),row(:),col(:)];
fid = fopen('COCMP_Master_Grid_3km.dat','w');
fprintf(fid,'%10.5f %9.5f %3d %3d\n',out');
fclose(fid);