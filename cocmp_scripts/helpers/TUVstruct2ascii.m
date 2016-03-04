function TUVstruct2ascii(T,outDir)

try, outDir;
catch
    outDir = pwd;
end

uvFlag = 9999.0;

% See how many valid times exist
index = find(isfinite(T.TimeStamp));
if isempty(index)
    return;
end

for i = 1:length(index)
    
    [yy,mm,dd,hh,MM,ss]=datevec(T.TimeStamp(index(i)));
    % Create the file name
    fname = sprintf('%s_%s_%.4d_%.2d_%.2d_%.2d00.txt', ...
            T.Type,T.DomainName,yy,mm,dd,hh);
    fname = fullfile(outDir,fname);
    fout = fopen(fname,'w');
    
    % Create the header information
    fprintf(fout,'%%TimeStamp: %.4d %.2d %.2d %.2d 00\n', yy,mm,dd,hh);
    fprintf(fout,'%%TimeZone: %s\n',T.TimeZone);
    fprintf(fout,'%%Domain: %s\n',T.DomainName);
    fprintf(fout,'%%Type: %s\n',T.Type);
    fprintf(fout,'%%DataCreationInfo: %s\n',T.CreationInfo);
    fprintf(fout,'%%DataCreationTimeStamp: %s\n', ...
                  datestr(T.CreateTimeStamp,0));
    fprintf(fout,'%%DataCreationTimeZone: %s\n',T.CreateTimeZone);
    fprintf(fout,'%%ProcessingProgram: %s %s\n',mfilename,datestr(now));
    fprintf(fout,'%%TUV_structVersion: %s\n',T.TUV_struct_version);
    fprintf(fout,'%%Longitude  Latitude  U comp  V comp\n');
    fprintf(fout,'%% (deg)      (deg)    (cm/s)  (cm/s)\n');
    
    % Create the data - flag any NaN's with uvFlag for ascii output
    U = T.U(:,index(i));
    V = T.V(:,index(i));
    
    ind = isnan(U);
    U(ind) = uvFlag;
    V(ind) = uvFlag;
    ind = isnan(V);
    U(ind) = uvFlag;
    V(ind) = uvFlag;    
    
    out = [T.LonLat,U,V];
    fprintf(fout,'%10.5f %9.5f %7.2f %7.2f\n',out');
    fclose(fout);
end
