function [val, feat] = computeFeature(data, param)
% returns pixel combination within a square patch
% sums the sum of two channels in this patch
if isstr(param)
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
      case 'addTwo'
        val(i) = data(i).patch(feat.rows(1), feat.cols(1), feat.channels(1)) + ...
                 data(i).patch(feat.rows(2), feat.cols(2), ...
                               feat.channels(2));
      case 'subAbs'
        val(i) = abs(data(i).patch(feat.rows(1), feat.cols(1), feat.channels(1)) - ...
             data(i).patch(feat.rows(2), feat.cols(2), feat.channels(2)));        
      case 'sub'
        val(i) = data(i).patch(feat.rows(1), feat.cols(1), feat.channels(1)) - ...
             data(i).patch(feat.rows(2), feat.cols(2), feat.channels(2));        
      case 'unary'
        val(i) = data(i).patch(feat.rows(1), feat.cols(1), feat.channels(1));        
    end
end
