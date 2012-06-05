function val = sub(patch)
% returns pixel combination within a square patch
% sums the sum of two channels in this patch
return patch(5,5,1) + patch(4, 2, 2);
