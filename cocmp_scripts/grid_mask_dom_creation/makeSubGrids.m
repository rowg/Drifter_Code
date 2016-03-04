function makeSubGrids

f = 0.05;   % Axis scaling factor.
% Load the master grid, use inpolygon to cut out the piece of interest, and
% save as the subdomain grids.
pts = load('COCMP_Master_Grid_3km.dat');

%%%%%%%%%%%%%%%

XB = load('BMLCMask.txt');
lims = findLims(XB,f);

pltMask(XB,lims,'k-');

ind = inpolygon(pts(:,1),pts(:,2),XB(:,1),XB(:,2));
BML = pts(ind,1:2);
m_plot(BML(:,1),BML(:,2),'.r');
fid = fopen('BMLC.grid','w');
fprintf(fid,'%% Bodega grid created by %s at %s\n', ...
        mfilename,datestr(now,0));
fprintf(fid,'%10.5f %9.5f\n',BML');
fclose(fid);

%%%%%%%%%%%%%%%

XB = load('BDGAMask.txt');
lims = findLims(XB,f);

pltMask(XB,lims,'k-');

ind = inpolygon(pts(:,1),pts(:,2),XB(:,1),XB(:,2));
BML = pts(ind,1:2);
m_plot(BML(:,1),BML(:,2),'.r');
fid = fopen('BDGA.grid','w');
fprintf(fid,'%% Bodega grid created by %s at %s\n', ...
        mfilename,datestr(now,0));
fprintf(fid,'%10.5f %9.5f\n',BML');
fclose(fid);
%%%%%%%%%%%%%%%

XS = load('SFOOMask.txt');
lims = findLims(XS,f);

pltMask(XS,lims,'b-');

ind = inpolygon(pts(:,1),pts(:,2),XS(:,1),XS(:,2));
SFO = pts(ind,1:2);
m_plot(SFO(:,1),SFO(:,2),'.r');
fid = fopen('SFOO.grid','w');
fprintf(fid,'%% San Francisco grid created by %s at %s\n', ...
        mfilename,datestr(now,0));
fprintf(fid,'%10.5f %9.5f\n',SFO');
fclose(fid);

%%%%%%%%%%%%%%%

XA = load('ANVOMask.txt');
lims = findLims(XA,f);

pltMask(XA,lims,'k-');

ind = inpolygon(pts(:,1),pts(:,2),XA(:,1),XA(:,2));
ANV = pts(ind,1:2);
m_plot(ANV(:,1),ANV(:,2),'.r');
fid = fopen('ANVO.grid','w');
fprintf(fid,'%% Ano Nuevo grid created by %s at %s\n', ...
        mfilename,datestr(now,0));
fprintf(fid,'%10.5f %9.5f\n',ANV');
fclose(fid);

%%%%%%%%%%%%%%%

XM = load('MNTYMask.txt');
lims = findLims(XM,f);

pltMask(XM,lims,'b-');

ind = inpolygon(pts(:,1),pts(:,2),XM(:,1),XM(:,2));
MTY = pts(ind,1:2);
m_plot(MTY(:,1),MTY(:,2),'.r');
fid = fopen('MNTY.grid','w');
fprintf(fid,'%% Monterey grid created by %s at %s\n', ...
        mfilename,datestr(now,0));
fprintf(fid,'%10.5f %9.5f\n',MTY');
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pltMask(maskXY,lims,cl)
figure
plotBasemap(lims(1:2),lims(3:4),'COCMP_Big_mercat','mercator');
hold on
m_plot(maskXY(:,1),maskXY(:,2),cl);

