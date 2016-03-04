clear all
close all

f = 0.05;

%%%%%%%%%%%%%%%%%%%%

dat=load('BMLC.grid');

[BGln,BGlt] = meshgrid_vector_data(dat(:,1),dat(:,2));

lims = findLims([BGln(:),BGlt(:)],f);

% Decimate
BMLC_tg_lon = BGln(1:3:end,1:3:end);
BMLC_tg_lat = BGlt(1:3:end,1:3:end);

figure
plotBasemap(lims(1:2),lims(3:4),'COCMP_Big_mercat','mercator');
hold on
% Whole grid
% m_plot(BGln,BGlt,'k.');
% Traj grid
m_plot(BMLC_tg_lon,BMLC_tg_lat,'r.');

%%%%%%%%%%%%%%%%%%%%

dat=load('SFOO.grid');

[SFln,SFlt] = meshgrid_vector_data(dat(:,1),dat(:,2));

lims = findLims([SFln(:),SFlt(:)],f);

% Decimate
SFOO_tg_lon = SFln(1:3:end,1:3:end);
SFOO_tg_lat = SFlt(1:3:end,1:3:end);

figure
plotBasemap(lims(1:2),lims(3:4),'COCMP_Big_mercat','mercator');
hold on
% Whole grid
% m_plot(SFln,SFlt,'k.');
% Traj grid
m_plot(SFOO_tg_lon,SFOO_tg_lat,'r.');

%%%%%%%%%%%%%%%%%%%%

dat=load('ANVO.grid');

[AVln,AVlt] = meshgrid_vector_data(dat(:,1),dat(:,2));

lims = findLims([AVln(:),AVlt(:)],f);

% Decimate
ANVO_tg_lon = AVln(1:3:end,1:3:end);
ANVO_tg_lat = AVlt(1:3:end,1:3:end);

figure
plotBasemap(lims(1:2),lims(3:4),'COCMP_Big_mercat','mercator');
hold on
% Whole grid
% m_plot(AVln,AVlt,'k.');
% Traj grid
m_plot(ANVO_tg_lon,ANVO_tg_lat,'r.');

%%%%%%%%%%%%%%%%%%%%

dat=load('MNTY.grid');

[MNln,MNlt] = meshgrid_vector_data(dat(:,1),dat(:,2));

lims = findLims([MNln(:),MNlt(:)],f);

% Decimate
MNTY_tg_lon = MNln(1:3:end,1:3:end);
MNTY_tg_lat = MNlt(1:3:end,1:3:end);

figure
plotBasemap(lims(1:2),lims(3:4),'COCMP_Big_mercat','mercator');
hold on
% Whole grid
% m_plot(MNln,MNlt,'k.');
% Traj grid
m_plot(MNTY_tg_lon,MNTY_tg_lat,'r.');


