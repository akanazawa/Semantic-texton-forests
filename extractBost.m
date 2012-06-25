function [bost, prior] = extractBost(I, mask, forest, d)
%%%%%%%%%%%%%%%%%%%%
% Given an image and a logical mask, extracts bags of semantic
% textons, which is a histogram of the path each pixels in the
% region took in the forest
% Returns:
%   bost - N by 1 array where N is the number of nodes in the forest. 
%   prior - numClasses by 1 array, the region category prior  which
%   is the average of all leaf nodes reached by each pixel in the region
%%%%%%%%%%%%%%%%%%%%
rad = (d-1)/2; % size of patch
Ipad = padarray(I, [rad, rad], 'symmetric');
maskPad = padarray(mask, [rad, rad]);
[r, c, ~] = size(Ipad);
Ilab = applycform(Ipad, makecform('srgb2lab'));
[ri, ci] = ndgrid(1:r, 1:c);
ri = ri(maskPad); ci = ci(maskPad);
R = length(ri);
data = struct([]); %struct is faster than zero arrays
for i = 1:length(ri)
    data(i).patch = Ilab(ri(i)-rad:ri(i)+rad, ci(i)-rad:ci(i)+rad,:);
end
patches = reshape([data.patch], [d, d, numel(ri2), 3]);
numTree = numel(forest);
% do not count the roots
numNodes = sum([forest.numNodes]) - numTree;
bost = zeros(numNodes, 1);
prior = zeros(forest(1).numClass, 1);
start = 0; endInd = 0;
for t = 1:numTree
    start = endInd+1;
    endInd = endInd + forest(t).numNodes-1;    
    [dists, hist] = forest(t).classify(patches);
    assert(all(bost(start:endInd) == 0));
    bost(start:endInd) = hist;
    prior = prior + sum(dists, 2)./R;
end
prior = prior./numTree;
