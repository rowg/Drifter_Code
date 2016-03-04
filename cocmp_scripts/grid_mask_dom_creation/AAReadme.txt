This directory creates the master grid, and the tuv subgrids for each 
COCMP subdomain.  See makeMasterCOCMPgrid.m and makeSubGrids.m for 
procedure.  

Data created by above functions:
COCMP_Master_Grid_3km.dat and XXXX.grid, where XXXX is the tuv subdomain.
The data is manually copied into the proper subfolder under the data folder.

*******************************************************************************

There is a makeTrajGrid.m in this folder, but I'm currently thinking these
grids can be made on the fly in the XXXX_conf.m every time it is called.

*******************************************************************************

Readme for OMA boundary and grid creation.

See makeOMA.m for procedure.  A makeOMA_XXXX.m, where XXXX is the 
OMA subdomain, exists for each COCMP OMA subdomain created.  Hopefully 
I've left enough bread crumbs to remember what I did.

Data created by one of the m files:
XXXX_OMA_Boundary.mat - boundary data for OMA domain, see makeOMA_XXXX for 
more info.

XXXX_OMA_Domain.mat - data needed by OMA programs, soo makeOMA_XXXX for info.