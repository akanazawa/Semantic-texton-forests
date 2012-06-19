function bost = extractBost(I, mask, forest)
%%%%%%%%%%%%%%%%%%%%
% Given an image and a region mask, extracts bags of semantic
% textons, which is a histogram of the path each pixels in the
% region took in the forest
%%%%%%%%%%%%%%%%%%%%

region = I(mask);
numTree = numel(forest);
numNodes = zeros(numTree, 1);
for t = 1:numTree
    numNodes(t) = forest(t).numNodes;
end
bost = sparse(sum(numNodes), numel(region));
for i = 1:numel(region)
    for t = 1:numTree
        hist = forest(t).computeBost(region(i))
        if t == 1
            bost(1:numNodes(t), i) = hist; 
        else 
            bost(numNodes(t-1)+1:numNodes(t), i) = hist; 
        end                
    end        
end
