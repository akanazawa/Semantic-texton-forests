function do_train(config_file)
%%%%%%%%%%%%%%%%%%%%
% Training STF
% 1. preprocess data (make patches)
% 2. learn the best splits based on information gain
% 3. fill the tree to get the class distribution at each node
%
% May 30 '12 Angjoo Kanzawa
%%%%%%%%%%%%%%%%%%%%
DEBUG = 0;
eval(config_file); % load settings


%% learn the splits
if ~exist(PATH.forestSkeleton, 'file')
    % make training patches
    if ~exist(PATH.trainingSplit, 'file')
        splits = sampleTrainingImages(config_file);
    else, load(PATH.trainingSplit); end
    % make label weights
    if ~exist(PATH.labelWeights, 'file')
        weights = computeLabelWeights(config_file);
    else, load(PATH.labelWeights); end
    
    fprintf('building the random forest\n');
    forest(1, FOREST.numTree) = DecisionTree();
    wait = waitbar(0, 'learning the splits');
    for i = 1:FOREST.numTree
        tree = DecisionTree(FOREST.maxDepth, FOREST.numFeature, FOREST.numThreshold, ...
                            FOREST.factory, weights);
        tree.trainDepthFirst(splits{i});
        forest(i) = tree;
        wait = waitbar(i/FOREST.numTree, wait, sprintf(['finished learning ' ...
                            'tree: %d'], i));
    end
    close(wait);
    clear splits;
    save(PATH.forestSkeleton, 'forest');
else
    load(PATH.forestSkeleton);
end

%% fill the forest

fid = fopen(PATH.trainingNames, 'r');
imageNames = textscan(fid, '%s');
imageNames = imageNames{1};
fclose(fid);
numTrain = numel(imageNames);

wait = waitbar(0, 'filling the tree');
for i = 1:numTrain
    data = getPatches(imageNames{i}, DIR, CLASSES, BOX, TRANSFORM, 0);
    for t = 1:FOREST.numTree
        forest(t).fillAll(data);
        fprintf('.');
    end    
    wait = waitbar(i/numTrain, wait, sprintf(['filling training ' ...
                        'image: %d'], i));    
end
save(PATH.forestFilled, 'forest');
keyboard
%%normalize tree
for t = 1:FOREST.numTree
    forest(t).normalizeAll();
end    
save(PATH.forestFilled, 'forest');
close(wait);

    
