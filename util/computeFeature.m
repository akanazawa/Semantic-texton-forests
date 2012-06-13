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
for i = 1:numel(data)
    switch feat.method
      case 1% 'addTwo'
        val(i) = data(i).patch(feat.rows(1), feat.cols(1), feat.channels(1)) + ...
                 data(i).patch(feat.rows(2), feat.cols(2), ...
                               feat.channels(2));
      case 2% 'subAbs'
        val(i) = abs(data(i).patch(feat.rows(1), feat.cols(1), feat.channels(1)) - ...
             data(i).patch(feat.rows(2), feat.cols(2), feat.channels(2)));        
      case 3%'sub'
        val(i) = data(i).patch(feat.rows(1), feat.cols(1), feat.channels(1)) - ...
             data(i).patch(feat.rows(2), feat.cols(2), feat.channels(2));        
      case 4%'unary'
        val(i) = data(i).patch(feat.rows(1), feat.cols(1), feat.channels(1));        
    end
end
