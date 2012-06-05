function do_train(config_file)
%%%%%%%%%%%%%%%%%%%%
% Training STF
%
%
% May 30 '12 Angjoo Kanzawa
%%%%%%%%%%%%%%%%%%%%

eval(config_file); % load settings

if ~exist(path.trainingSplit)
    [splits, data] = sampleTrainingImages(config_file);
else
    load(path.trainingSample);
    load(path.trainingPatches);
end
keyboard
% compute weight for labels
if ~exist(path.labelWeights)
    labelWeights = zeros(numClasses, 1);
    save(path.labelWeights, 'labelWeights');
else, load(path.labelWeights); end;

forest = zeros(numTree, 1);
for i = 1:numTree
    tree = DecisionTree(maxDepth, numFeature, numThreshold, numClass, ...
                        factory, labelWeights);
    tree.trainDepthFirst(splits{i});
end


keyboard
