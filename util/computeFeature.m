function [val, feat] = computeFeature(data, param)
% returns pixel combination within a square patch
% sums the sum of two channels in this patch
if ~isstruct(param)
    d = 15;  % boxSize
    feat.rows = randi(d, 2, 1);
    feat.cols = randi(d, 2, 1);
    feat.channels = randi(3, 2, 1);
    feat.method = param;
else
    feat = param;
end
val = zeros(numel(data), 1);
% patches = cell(numel(data), 1);
% [patches(:)] = deal(data.patch);%?
for i = 1:numel(data)
    A = data(i).patch(feat.rows(1), feat.cols(1), feat.channels(1));
    B = data(i).patch(feat.rows(2), feat.cols(2), feat.channels(2));
    switch feat.method
      case 1% 'unary'
        val(i) = A;
      case 2% 'subAbs'
        val(i) = abs(A - B);        
      case 3% 'addTwo'
        val(i) = A + B;
      case 4%'sub'
        val(i) = A - B;
    end
end
