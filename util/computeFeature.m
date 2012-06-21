function [val, feat] = computeFeature(patches, param)
% returns pixel combination within a square patch
% sums the sum of two channels in this patch
% patches is a d x d x N x 3 matrix
if ~isstruct(param)
    d = size(patches, 1);  % boxSize
    feat.rows = randi(d, 2, 1);
    feat.cols = randi(d, 2, 1);
    feat.channels = randi(3, 2, 1);
    feat.method = param;
else
    feat = param;
end
A = patches(feat.rows(1), feat.cols(1), :, feat.channels(1));
B = patches(feat.rows(2), feat.cols(2), :, feat.channels(2));

switch feat.method
  case 1% 'unary'
    val = A;
  case 2% 'subAbs'
    val = abs(A - B);        
  case 3% 'addTwo'
    val = A + B;
  case 4%'sub'
    val = A - B;
end

val = double(val(:));

