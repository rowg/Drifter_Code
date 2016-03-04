% Procedure for creating an OMA domain.  Some of the steps require
% interaction from the users.  They are commented out and noted.  So the
% way to use this is to run the 1st interactive thing, save the data with
% the filename indicated, then comment it out and load the saved data, move
% on to the next interactive thing, and so on until the file runs to
% completion.

clear all
close all

% First need to make a OMA mask that is smaller than the Totals mask.  
% Procedure:  put basemap up, use makepoly to mark the oma domain while the
% plot is in lon/lat space, then use makeDomainBoundary.m to make the OMA
% domain.  Unfortunately makeDomainBoundary puts the map into another
% coordinate system, so it's hard to tell where you are, hence the reason
% for using makePoly first.


% OK make the basemap
lims=[-123.4,-122.2,37.45,38.05];
coastFileName = 'COCMP_Big_mercat.mat';
figure
% This is a mercator basemap
plotBasemap(lims(1:2),lims(3:4),coastFileName,'mercator','patch','g');
% This is a lambert
% plotBasemap(lims(1:2),lims(3:4),coastFileName,'lambert','patch','g');
hold on

% Put on the TUV mask just for reference.
sfoMask = load('SFOOMask.txt');
m_plot(sfoMask(:,1),sfoMask(:,2),'b-');

%%

% OK now lets use makePoly to set the water portion (open boundary) of the
% OMA domain.  Remember this is so that you can see where to make the
% boundary for makeDomainBoundary.

% OK this is the first interactive bit -
% % [X,Y,ptHand,lineHand] = makePoly;
% When done with above, save to makePolyStuff and uncomment the load here:
load makePolyStuff X Y
% % m_plot(X,Y,'b-');

%%

% OK now let's make the OMA domain boundary.  Make sure you pass back at
% least the first 2 arguments so that smoothDomainBoundary works.
% OK here's the 2nd interactive bit - 
% % [OMA_boundary,OMA_bi,OMA_ptHand,OMA_lineHand] = makeDomainBoundary(coastFileName);
% Save.  And this is the load for the 2nd interactive bit.
load makeDomainBoundaryStuff OMA_boundary OMA_bi
% SAVE THE ORIGINAL BOUNDARY AND WATER/LAND INDEX POINTS TO A FILE.  IF YOU
% WANT TO GENERATE ANOTHER OMA DOMAIN, YOU WILL NEED BOTH OF THESE.
% So save with Domain name in the file name.
% % save SFOO_OMA_Boundary OMA_boundary OMA_bi
% If you want to see the original, unsmoothed boundary.  Useful if you want
% to see the distribution of points around the boundary.
% % m_plot(OMA_boundary(:,1),OMA_boundary(:,2),'-m*');

%%

% Need to supply the 3rd argument to smoothDomainBoundary or this function 
% doesn't work.
[OMA_boundary_smooth,OMA_bi_smooth,OMA_ds_smooth] = smoothDomainBoundary(OMA_boundary,3000,OMA_bi);
m_plot(OMA_boundary_smooth(:,1),OMA_boundary_smooth(:,2),'-r*')


% OK now let's create the OMA modes.

% In preparation for OMA domain creation, prepare the smoothed domain
% boundary for use in generate_OMA_modes.  If this file was created with
% makeDomainBoundary, the last point is the same as the 1st point, and must
% be removed.  See help on makeDomainBoundary.
OMA_boundary_smooth = OMA_boundary_smooth(1:end-1,:);

%%

% First time through the function generate_OMA_modes, you have to set it up
% to drop into keyboard mode, so you can get some information about your
% specific domain.  Here's the call for it to stop:
% % generate_OMA_modes('SFOO_Test',OMA_boundary_smooth, ...
% %                    10,{},{},[],[],true);
% After the program stops, the domain boundary will be placed on a figure.
% Select "Boundary", then "Boundary Mode" from the menu.  Then from the
% same "Boundary" menu, select "Show Edge Labels".  This will place numbers
% on the boundary.  Now assign the proper number to the open boundary and
% the dirichlet boundary.
% See help on the generate_OMA_modes for a discussion of the
% open_boundary_nums (ob_nums) and dirichlet_boundary_nums (db_nums).
% They are critical for getting the OMA domain set up correctly.

disp('OK type R-E-T-U-R-N to continue and make OMA domain')
keyboard

close all

% Open boundary segments, first is the open ocean, 2nd is SF bay mouth
ob_nums = { [1:33], 45 };
% % The magic number ... ?
db_nums = { 55, 55 };
% Make sure the domain file has the .mat specified, it doesn't put one on
% automatically.
generate_OMA_modes('SFOO_OMA_Domain_5km.mat',OMA_boundary_smooth, ...
                   5,ob_nums,db_nums,[],[],false);

%%

% Interpolate OMA modes to TUV gridpoints, trim off gridpoints outside OMA 
% domain, and save into OMA mat file.  Actually trim off gridpoints outside
% original unsmoothed boundary, which follows the coast better.
grid = load('SFOO.grid');
% Add the Golden Gate tidal Location - moved into the OMA domain.
grid(end+1,:) = [-122.5263, 37.7998];
ind = inpolygon(grid(:,1),grid(:,2),OMA_boundary(:,1),OMA_boundary(:,2));
OMA_grid = grid(ind,:);
interp_OMA_modes_to_grid(OMA_grid,'SFOO_OMA_Domain_5km.mat',[]);
