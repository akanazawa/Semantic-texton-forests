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
    if ~exist(PATH.trainingPatches, 'file')
        data = sampleTrainingImages(config_file);
    else, load(PATH.trainingPatches); end
    % if ~exist(PATH.trainingPointsSub, 'file')
    %     [data, Is] = sampleTrainingImagesByImages(config_file);
    % else, load(PATH.trainingPointsSub); end

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
        % randomly pick dataPerTree amount of training data for
        % each tree
        subData = data(rand(numel(data), 1) < FOREST.dataPerTree);
        patches = [subData.patch];
        % make it d by d by N by 3
        patches = reshape(patches, size(patches, 1), ...
                          size(patches, 1), length(subData), 3);
        labels = double([subData.label]);
        tree.trainDepthFirst(patches, labels);
        % tree.trainDepthFirstByImages(subData, Is);
        forest(i) = tree;
        wait = waitbar(i/FOREST.numTree, wait, sprintf(['finished learning ' ...
                            'tree: %d'], i));
    end
    close(wait);
    save(PATH.forestSkeleton, 'forest');
else
    load(PATH.forestSkeleton);
end

%% fill the forest
if ~exist(PATH.forestFilled, 'file');
    fprintf('fill the forest\n');
    fid = fopen(PATH.trainingNames, 'r');
    imageNames = textscan(fid, '%s');
    imageNames = imageNames{1};
    fclose(fid);
    numTrain = numel(imageNames);

    wait = waitbar(0, 'filling the tree');
    for i = 1:numTrain
        data = getPatches(imageNames{i}, DIR, LABELS, BOX, TRANSFORM);
        if ~isempty(data)
            patches = [data.patch];
            % make it d by d by N by 3
            patches = reshape(patches, size(patches, 1), ...
                              size(patches, 1), numel(data), 3);
            labels = double([data.label]);        
            for t = 1:FOREST.numTree
                forest(t).fillAll(patches, labels);            
            end    
        end
        wait = waitbar(i/numTrain, wait, sprintf(['filling training ' ...
                            'image: %d'], i));    
    end
    % for i = 1:numTrain
    %     [data, Is] = getPatchesByImages(imageNames{i}, DIR, LABELS, BOX, TRANSFORM);
    %     if ~isempty(data)
    %         for t = 1:FOREST.numTree
    %             forest(t).fillAll(data, Is);            
    %         end    
    %     end
    %     wait = waitbar(i/numTrain, wait, sprintf(['filling training ' ...
    %                         'image: %d'], i));    
    % end
    fprintf('normalize tree\n');
    for t = 1:FOREST.numTree
        forest(t).normalizeAll();
    end    
    save(PATH.forestFilled, 'forest');
    close(wait);
end

    
