function do_train(config_file)
%%%%%%%%%%%%%%%%%%%%
% Training STF
%
%
% May 30 '12 Angjoo Kanzawa
%%%%%%%%%%%%%%%%%%%%
DEBUG = 1;
eval(config_file); % load settings

% make training patches
if ~exist(path.trainingSplit)
    [splits, data] = sampleTrainingImages(config_file);
else
    load(path.trainingSplit); % splits
end
% make label weights
if ~exist(path.labelWeights)
    weights = computeLabelWeights(config_file);
else, load(path.labelWeights); end;
fprintf('building the random forest\n');

%% learn the splits
forest = zeros(numTree, 1);
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
save(path.forest, 'forest', 'config_file');


load(path.trainingPatches); % load data
load(path.trainingPatchesTransformed); % load dataT
                                       
% sanity check.. luv2rgb takes a while
if DEBUG
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
for j = 1:numTree
    forest(j).fillAll([data; dataT]);
end




