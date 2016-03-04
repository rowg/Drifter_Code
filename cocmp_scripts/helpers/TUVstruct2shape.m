function TUVstruct2shape(TUV,pathFile)

% USAGE:
%    TUVstruct2shape(TUV,pathFile)
%    will take the TUV struct, remove any NaN U,V currents, and write the
%    rest to a shapefile for use in GIS programs like ArcView.


% No NaN's allowed in shapewrite function - id all
ind = ~(isnan(TUV.U)  |  isnan(TUV.V));
if sum(ind) == 0
    fprintf('No data in this TUV struct, no shape files written')
    return;
end

[Lon,Lat,U,V] = deal(TUV.LonLat(ind,1),TUV.LonLat(ind,2), ...
                     TUV.U(ind),TUV.V(ind));

writeShapePoints(Lon,Lat,U,V,pathFile,TUV.Type);
