function plotNumRadTS(baseDir,plotDir,ts,moFlag,tyFlag,clrs,sites,types,cenc)

Fnames = filenames_standard_filesystem(baseDir,sites(:),types(:),ts,moFlag,tyFlag);
RDLS = loadRDLFile(Fnames(:)); %load in radials
for l1 = 1:numel(sites)
    numRads = [];
    for l2 = l1:numel(sites):numel(RDLS)
        numRads = [numRads;numel(RDLS(l2).U)]; 
    end
    line(ts,numRads,'marker','.','markersize',18,'color',clrs(l1,:)); hold on;
end
set(gca,'fontsize',14,'fontweight','bold')
set(gca,'xlim',[ts(1) ts(end)])
set(gca,'xtick',ts(1):1:ts(end))
set(gca,'xticklabel',datestr(ts(1):1:ts(end),6))
xlabel('Date (mm/dd)','fontsize',18,'fontweight','bold') 
ylabel('Number of Radials','fontsize',18,'fontweight','bold')
legend(sites,'Location','EastOutside')
title({'Number of Radials per Hour',['From: ',datestr(ts(1),21)], ...
       ['To: ',datestr(ts(end),21)]},'fontsize',20,'fontweight','bold');
bgprint([plotDir,cenc,'_NumRadsTS.eps'],'-depsc2',11,11);
convertPlot([plotDir,cenc,'_NumRadsTS.eps'],'gif',true);