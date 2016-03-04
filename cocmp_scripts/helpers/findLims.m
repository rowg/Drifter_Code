function lims = findLims(LonLat,f)


if ~exist( 'f', 'var' ) || isempty(f)
  f = 0;
end

lims = [min(LonLat); max(LonLat)];
d = diff(lims);

% Add in factor
lims(1,:) = lims(1,:) - f .* d;
lims(2,:) = lims(2,:) + f .* d;
lims = lims(:)';

