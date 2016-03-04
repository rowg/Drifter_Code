function COCMPdriver_meanTUV( times, p, varargin )

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters and parameter checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = HFRPdriver_default_conf( p );

% Merge
mand_params = { };
p = checkParamValInputArgs( p, {}, mand_params, varargin{:} );

%%
try, p.OMA.DomainName;
catch
  p.OMA.DomainName = p.Totals.DomainName;
end

try, p.OMA.FilePrefix;
catch
  p.OMA.FilePrefix = [ 'oma_' p.OMA.DomainName '_' ];
end

s = p.meanTUV.Type;


%%
[f] = datenum_to_directory_filename( p.(s).BaseDir, times, ...
                                     p.(s).FilePrefix, ...
                                     p.(s).FileSuffix, p.MonthFlag );
[TUVcat,goodCount] = catTotalStructs(f,'TUV');
numTimes = length(f);


% Now mean
fprintf('Temporal Averaging: %d of %d hours present\n',goodCount,numTimes);
if goodCount < p.meanTUV.Thresh
    fprintf('No mean current calculation for %s\n',datestr(times(end)));
    return
end

TUVavg = nanmeanTotals(TUVcat);



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.meanTUV.FilePrefix = strcat(p.meanTUV.Type,int2str(numTimes),'hr_',p.Totals.DomainName,'_');
[tdn,tfn] = datenum_to_directory_filename( p.meanTUV.BaseDir, times(end), ...
                                           p.meanTUV.FilePrefix, ...
                                           p.meanTUV.FileSuffix, p.MonthFlag );
tdn = tdn{1};

if ~exist( tdn, 'dir' )
  mkdir(tdn);
end
TUV = TUVavg;
TUV.OtherMetadata.nanmeanTotals.Total_avgHrs = numTimes;
TUV.OtherMetadata.nanmeanTotals.Actual_avgHrs = goodCount;

save(fullfile(tdn,tfn{1}),'TUV','TUVcat');
