function [xo, yo, ss3,N] = skill_score_ncls_v2(D,index_step)
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
%
%
%===============================================================================
  
  ind = [1:length(D.tid)];
  ind2 = [1:length(D.ti_dpls)];

  for i = 1:length(D.ti_dpls)
     
      eval(['Di = D.p' num2str(ind2(i)) ';']);

      %% determine where the NaNs are in the modelled trajectory data
      %% and remove them
      ind3=~isnan(Di.x);
      xm=Di.x(ind3);
      ym=Di.y(ind3);
      
      %% determine the length of the remaining data set
      dlength=length(xm);
      
      if dlength>2*index_step
          day1=1;
          day2=2;
      else
          day1=dlength/(2*index_step);
          day2=dlength/index_step;
      end
      
      xo(i) = D.xd((i-1)*8+1);
      yo(i) = D.yd((i-1)*8+1);

     % Calculate the Lagragian separation distance between the end locations of
     % the observed and simulated trajectories:
        
     %% first half of modelled trajectory
      %% location of the modelled trajectory
      ind_m1=floor(day1*index_step);
      
      if ind_m1<1
          ind_m1=1;
      end
      
      xm1 = Di.x(ind_m1);
      ym1 = Di.y(ind_m1); 
      %% location of the actual trajectory
      ind_a1=floor((i-1+day1)*8);
      
      if ind_a1<1
          ind_a1=1;
      end
      
      xo1 = D.xd(ind_a1);
      yo1 = D.yd(ind_a1);
      d1(i) = sw_dist([yo1,ym1], [xo1,xm1],'km');
     
      %% second half of modeleld trajectory
      ind_m2=ceil(day2*index_step);
      xm2 = Di.x(ind_m2);
      ym2 = Di.y(ind_m2);
      ind_a2=ceil((i-1+day2)*8);
      xo2 = D.xd(ind_a2);
      yo2 = D.yd(ind_a2);
      d2(i) = sw_dist([yo2,ym2], [xo2,xm2],'km');
      
     %% store teh number of data points in the variable N
      N(i)=dlength;
     
%       day = 3; % commented out HJR 20160304
%       xm3 = Di.x(day*8);
%       ym3 = Di.y(day*8);
%       xo3 = D.xd((i-1+day)*8);
%       yo3 = D.yd((i-1+day)*8);
%       d3(i) = sw_dist([yo3,ym3], [xo3,xm3],'km');     

     
     % Calculate the length of observed trajectory:
     ind3=(i-1)*8+1;
      dl = sw_dist(D.yd(ind3:end), D.xd(ind3:end),'km');  
         
      cdl = cumsum(dl);  % cumulative along the path
	
      %% commented out 20160519
%       lo1(i) = cdl(floor(day1*8)+1);
%       lo2(i) = cdl(ceil(day2*8)+1);
      
      lo1(i) = cdl(floor(day1*8)+1);
      lo2(i) = cdl(ceil(day2*8));
      
      
%       lo3(i) = cdl(3*8);% commented out HJR 20160304
	   
  end

  
 % Take an average for the first 3 days:
  % This is especially useful if the flow field has dramatic changes during
  % the 3 days, for example, in the case eddies. If a drifter is deployed in 
  % an eddy, d3 could be a lot smaller than d2, and the model skill could be
  % overestimated. By averaging, this overestimation or underestimation may be
  % limited. 
     
%   cd3 = d1 + d2 + d3;% commented out HJR 20160304
%   cl3 = lo1 + lo2 + lo3;
 
  cd3 = d1 + d2;
  cl3 = lo1 + lo2;
  
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
