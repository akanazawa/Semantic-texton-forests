function do_train(config_file)
%%%%%%%%%%%%%%%%%%%%
% Training STF
%
%
% May 30 '12 Angjoo Kanzawa
%%%%%%%%%%%%%%%%%%%%

eval(config_file); % load settings

% make training patches
if ~exist(path.trainingSplit)
    [splits, data] = sampleTrainingImages(config_file);
else
    load(path.trainingSplit); % splits
                              %    load(path.trainingPatches); % data
end
% make label weights
if ~exist(path.labelWeights)
    weights = computeLabelWeights(config_file);
else, load(path.labelWeights); end;
fprintf('building the random forest\n');
forest = zeros(numTree, 1);
for i = 1:numTree
    tree = DecisionTree(maxDepth, numFeature, numThreshold, ...
                        factory, weights);
    tree.trainDepthFirst(splits{i});
    forest(i) = tree;
end

