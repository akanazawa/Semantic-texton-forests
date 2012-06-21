%%IF patches weren't given as d x d x 3, but just the center point
%%and the id to it's corresponding image I
function [val, feat] = computeFeatureByImages(data, Is, param)
if ~isstruct(param)
    d = size(patches, 1);  % boxSize
    feat.rows = randi(2*d, 2, 1) - d;
    feat.cols = randi(2*d, 2, 1) - d;
    feat.channels = randi(3, 2, 1);
    feat.method = param;
else
    feat = param;
end

A = zeros(length(data), 1);
B = zeros(length(data), 1);
for i = 1:length(data)
    A(i) = Is{data.imageId}(data.row+feat.rows(1), data.col+feat.cols(1), feat.channels(1));
    B(i) = Is{data.imageId}(data.row+feat.rows(2), data.col+feat.cols(2), feat.channels(2));
end

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
