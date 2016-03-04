function [p] = drawpatch(x,y1,y2,patcolor)

% Draw a patch on the current plot (for timelines), or other uses.
%
% Assume:  y1 and y2 are 1x1
%          x1 is Nx1, or 1xN of times with NaN's
% 
%  Mike Cook, NPS Oceanography, Monterey, CA - 14 July 04

if nargin < 4
   patcolor = 'r';
end
p = [];

% Check for NaN as the 1st or last x, and remove all NaN's at beginning and
% end.  So now 1st and last values are valid data.
ind = find(isfinite(x));

% No valid case
if isempty(ind)
    return
end

% Trim NaN's at beginning and the end
x = x(ind(1):ind(end));

% I don't think I can know the exact number of patch handles except by
% counting the number of data chunks (data with NaN's in before and after)
% in time.  So be lazy and predefine say 1000 handles (enough for most
% applications), and then at the end of the program, trim off all the NaN's
% at the end.
% % p=nan(1000,1);
if any(isnan(x))
	% Now make a patch for each good block of data
    i = 0;
    while 1
        i = i + 1;
        % There should be no NaN's at the beginning or end of x
        % Find all the NaN's
        ind = find(isnan(x));
        
        % If no NaN's, have id'ed all the segments, except the last
        % segement from the last NaN to the end of the data.  Now plot this
        % and break out of the loop
        if isempty(ind)
            p(i) = patch([x(1),x(end),x(end),x(1)],[y1,y1,y2,y2],patcolor);
            break;
        end
        
        % Id the 1st good segment of data and plot as a patch
        xp = x(1:ind(1)-1);
        p(i) = patch([xp(1),xp(end),xp(end),xp(1)],[y1,y1,y2,y2],patcolor);
        % Remove the good segment of data
        x = x(ind(1)+1:end);
        % Trim any NaN's at beginning of new x
        ind = find(isfinite(x));
        if ind(1) ~=1
            x = x(ind(1):end);
        end
    end
else
   p = patch([x(1),x(end),x(end),x(1)],[y1,y1,y2,y2],patcolor);
end

% ind = isnan(p);
% p(ind) = [];
