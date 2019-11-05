function [xo, yo, ss3,N] = skill_score_6(D)
%
% function [xo, yo, ss3] = skill_score_ncls(D);
%==============================================================================
% kill_score_ncls $Revision: 1.0                           Date: 2015/06/18
%
%          Copyright (C) USF, Yonggang Liu, 2015.
%
% Calculate skill scores of trajectory simulation for one drifter after 3 days'
% simulation. The skill score is defined as the normalized cumulative Lagrangian
% separation distance [Liu and Weisberg, 2011; Liu et al. 2014].  The viable
% names (d1 d2 d3, lo1, lo2, lo3, n, s, ss3 ...) are the same as those shown
% Figure 3 of Liu and Weisberg (2011).
%
% The following MATLAB functions are needed:
%
%  sw_dist.m
%
%
% References:
%
%  Liu, Y., and R.H. Weisberg (2011), Evaluation of trajectory modeling in
%  different dynamic regions using normalized cumulative Lagrangian separation,
%  Journal of Geophysical Research, 116, C09013, doi:10.1029/2010JC006837.
%
%  Liu, Y., R. H. Weisberg, S. Vignudelli, and G. T. Mitchum (2014), Evaluation
%  of altimetry-derived surface current products using Lagrangian drifter
%  trajectories in the eastern Gulf of Mexico, J. Geophys. Res. Oceans, 119,
%  2827-2842, doi:10.1002/2013JC009710.
%
% Author contact information:
%
%  Yonggang Liu
%  University of South Florida
%  College of Marine Science
%  St. Petersburg, Florida 33701,
%  U.S.A.
%
% Email: yliu@mail.usf.edu
%        yliu18@gmail.com
%
% http://ocgweb.marine.usf.edu/~liu
%
% Modified by Hugh Roarty to not assume that you have a full 48 hours of
% data 20160401
%
% Modified by Teresa Updyke
%  Release frequency: every 6 hours (hard coded)
%  Number of segments: 6 (hard coded)
%  Segment length: 1 hour, if less than six hours available skill gets NaN
%  Sum for track length: use all hourly positions
%
%
%===============================================================================
xo = []; % first position of modeled drifter track, will match with release point
yo = [];
N = [];

for i = 1:length(D.ti_dpls)  % for each virtual drifter
    eval(['Di = D.p' num2str(i) ';']);
    
    % determine where the NaNs are in the modelled trajectory data
    % and remove them
    notnan=~isnan(Di.x);
    xm=Di.x(notnan);    % assign modeled positions xm, ym
    ym=Di.y(notnan);
    
    % determine the length of the remaining data set
    dlength=length(xm);
    % store the number of data points in the variable N
    N(i)=dlength;
    
    % the number of segments will be 6
    nseg = 6;
    
    if dlength == 7
        

        
        % segments will be 1 hour in length
        
        % extract same time period in actual trajectory so indices
        % for observed track and modeled will be the same
        clear istart obsT obsX obsY
        istart = find(D.ti == Di.dateini);
        obsT = D.ti(istart:istart+dlength-1);
        obsX = D.x(istart:istart+dlength-1);
        obsY = D.y(istart:istart+dlength-1);
        
        %define indices for each segment
        ind = zeros(nseg,1);
        ind = [2 3 4 5 6 7];
        
        % initial release location, output to function, but not used
        % elsewhere in this function
        xo(i) = Di.x(1); % first position of modeled drifter track, will match with release point
        yo(i) = Di.y(1);
        
        
        % Calculate the Lagrangian separation distance between the end locations of
        % the observed and simulated trajectories:
        
        % segment loop
        
        for seg = 1:nseg
            
            % location of the modelled trajectory
            xm1 = Di.x(ind(seg));
            ym1 = Di.y(ind(seg));
            
            % location of the actual trajectory
            xo1 = obsX(ind(seg));
            yo1 = obsY(ind(seg));
            
            d1(i,seg) = sw_dist([yo1,ym1], [xo1,xm1],'km');
            clear xm1 ym1 xo1 yo1
            
        end
        
        
        % Calculate the length of observed trajectory:
        dl = sw_dist(obsY, obsX,'km');
        cdl = cumsum(dl);  % cumulative along the path
        
        for seg = 1:nseg
            lo1(i,seg) = cdl(ind(seg)-1);
        end
        
        
    else
        
        % There were not 6 hours of forecast positions in the modeled
        % track.
        d1(i,1:nseg) = zeros(1,nseg).*NaN;
        lo1(i,1:nseg) = zeros(1,nseg).*NaN;
        
    end
end


% Sum of separation distances / sum of cumulative track lengths

cd3 = sum(d1,2);
cl3 = sum(lo1,2);

s = cd3./cl3;

n = 1.0;  % Tolerance threshold n is set to be 1 following the discussions
% of Liu and Weisberg (2011) and Liu et al. (2014).  This means
% the trajectory model is considered to have no skill if the
% cumulative Lagrangian sepration is larger than the length of
% the drifter path.

ss3  = 1 - s/n;

ss3(ss3<=0) = 0.000000001;  % Reset the negative values to 0.000000001,
% so that the skill scores are in the range
% of [0-1].

%  OK!
