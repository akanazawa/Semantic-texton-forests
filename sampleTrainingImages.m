function [splits] = sampleTrainingImages(config_file)
% creates nImages split for each tree and samples boxSize x boxSize
% patches for each image
% returns a cell of nImages x 1 each containing names of image names
eval(config_file);

fid = fopen(PATH.trainingNames, 'r');
imageNames = textscan(fid, '%s');
imageNames = imageNames{1};
fclose(fid);

labelNames = strcat([DIR.groundTruth, '/'], regexprep(imageNames, '\.bmp$', '_GT.bmp'));
imageNames = strcat([DIR.images, '/'], imageNames);
numTrain = numel(imageNames);

%%  select patches from each training images
if ~exist(PATH.trainingPatchesSub, 'file')
    rad = (BOX.size-1)/2; % of patch
    data = struct([]);
    k = 1; 
    wait = waitbar(0, 'preprocessing data');
    for i = 1:numTrain
        I = imread(imageNames{i});
        L = imread(labelNames{i});
        Ilab = applycform(I, BOX.cform);    
        [r, c, ~] = size(I);
        indices = reshape(1:r*c, r, c);
        indices = indices(rad+1:BOX.sampleFreq:r-rad, rad+1:BOX.sampleFreq:c-rad);
        [ri, ci] = ind2sub([r,c], indices(:)); % subsampled center pixels of patches
        for j = 1:numel(indices)
            % rgb = strtrim(sprintf('%d%d%d', L(ri(j), ci(j), :)));
            gt = find(L(ri(j), ci(j), 1) == LABELS(:, 1) & ...
                      L(ri(j), ci(j), 2) == LABELS(:, 2) & ...
                      L(ri(j), ci(j), 3) == LABELS(:, 3) );            
            if ~isempty(gt)
                data(k).label = gt;                            
            % if isKey(CLASSES, rgb) 
            %     data(k).label = CLASSES(rgb);
            %assert(gt == CLASSES(rgb));
                data(k).patch = Ilab(ri(j)-rad:ri(j)+rad, ci(j)-rad:ci(j)+rad, :);
                k = k + 1;
            end        
        end
        wait = waitbar(i/numTrain, wait, sprintf(['preprocessing training ' ...
                            'image: %d'], i));
    end
    close(wait);
    save(PATH.trainingPatchesSub, 'data');
end

%% make splits
if ~exist(data, 'var'), load(PATH.trainingPatchesSub); end
splits = cell(FOREST.numTree, 1);
for i = 1:numTree
    splits{i} = data(rand(numel(data), 1) < FOREST.dataPerTree);    
end
save(PATH.trainingSplit, 'splits');
