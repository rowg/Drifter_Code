function [rectPts] = makeRectfromLimits(axisLimits)
% Make a rectangle from a 1x4 vector from the axis command

% assume axisLimits is a 4 element vector of: [minX, maxX, minY, maxY]
%
% form the rectangle in a CCW sense starting at the lower left point.

rectPts = [axisLimits(1), axisLimits(3)
           axisLimits(2), axisLimits(3)
           axisLimits(2), axisLimits(4)
           axisLimits(1), axisLimits(4)
           axisLimits(1), axisLimits(3)];
       