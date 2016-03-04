function plotSmoothDomainBound(coastFileName,lims,OMAdomBoundaryMatFile,dx)

% This file is created by makeDomainBoundary using the following output
% variable names:
%[OMA_boundary,OMA_bi,OMA_ptHand,OMA_lineHand] = makeDomainBoundary(coast);
load(OMAdomBoundaryMatFile);

figure
plotBasemap(lims(1:2),lims(3:4),coastFileName,'lambert','patch','g');
hold on
m_plot(OMA_boundary(:,1),OMA_boundary(:,2),'-*r')
title('Original Boundary (before smoothing)');

for i = 1:length(dx)
    figure
    plotBasemap(lims(1:2),lims(3:4),coastFileName,'lambert','patch','g');
    hold on
    % Need to supply the 3rd argument or this function doesn't work.
    [Xs] = smoothDomainBoundary(OMA_boundary,dx(i)*1000,OMA_bi);
    m_plot(Xs(:,1),Xs(:,2),'-*r')
    title(sprintf('Smoothing = %d km\n',dx(i)));
end