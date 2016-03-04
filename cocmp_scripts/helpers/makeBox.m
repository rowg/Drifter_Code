function rect = makeBox(limits)
% MAKEBOX make a closed rectangle from a set of limits.
%
% This function takes a set of limits, in the order used by the AXIS
% command, to create a closed rectangle.  This is useful for use in the
% inpolygon command to determine if data is inside or outside this 
% rectangle.
%
% Usage: RECT = makeBox( LIMITS )
%
% Inputs:
% ------
%     LIMITS = 1 x 4 vector of the limits of a rectangle as defined by the
%              AXIS command, [ XMin, XMax, YMin, YMax ]
%
% Outputs:
% --------
%     RECT = 5 x 2 array of points defining the vertices of a rectangle
%            from the input LIMITS as:
%            RECT(1) = Lower Left Corner
%            RECT(2) = Lower Right Corner
%            RECT(3) = Upper Right Corner
%            RECT(4) = Upper Left Corner
%            RECT(5) = RECT(1)

rect = [ limits([1,3]);
         limits([2,3]);
         limits([2,4]);
         limits([1,4]);
         limits([1,3]) ];