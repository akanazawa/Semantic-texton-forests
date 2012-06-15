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
if ~exist(path.forestSkeleton, 'file')
    % make training patches
    if ~exist(path.trainingSplit, 'file')
        splits = sampleTrainingImages(config_file);
    else, load(path.trainingSplit); end
    % make label weights
    if ~exist(path.labelWeights, 'file')
        weights = computeLabelWeights(config_file);
    else, load(path.labelWeights); end
    
    fprintf('building the random forest\n');
    forest(1, numTree) = DecisionTree();
    wait = waitbar(0, 'learning the splits');
    for i = 1:numTree
        tree = DecisionTree(maxDepth, numFeature, numThreshold, ...
                            factory, weights);
        tree.trainDepthFirst(splits{i});
        forest(i) = tree;
        wait = waitbar(i/numTree, wait, sprintf(['finished learning ' ...
                            'tree: %d'], i));
    end
    close(wait);
    clear splits;
    save(path.forestSkeleton, 'forest');
else
    load(path.forestSkeleton);
end

%% Fill the forsest
if ~exist(path.trainingPatchesAll, 'file')
    [data, dataT] = sampleTrainingImagesAll(config_file);
else
    load(path.trainingPatchesAll); % load data
                                   %    load(path.trainingPatchesTransformed); % load dataT
end
                                       
% sanity check.. luv2rgb takes a while
if DEBUG
    %    patches = cell(numel(data), 1);
    %    [patches{:}] = deal(data.patch);
    cform = makecform('lab2srgb');
    start = randi(numel(data)-500);
    range = start:start+500;
    debug = uint8(zeros(boxSize, boxSize, 3, numel(range)));
    debugT = uint8(zeros(boxSize, boxSize, 3, numel(range)));
    for i = 1:numel(range)
        debug(:, :, :, i) = data(range(i)).patch;%applycform(data(range(i)).patch, cform);
        debugT(:, :, :, i) = dataT(range(i)).patch;%applycform(dataT(range(i)).patch, cform);
    end
    sfigure; montage(debug); 
    sfigure; montage(debugT);
end
%% fill the forest
for i = 1:numTree
    forest(i).fillAll([data, dataT]);
end

save(path.forestFilled, 'forest');


