function [splits, data] = sampleTrainingImages(config_file)
% creates nImages split for each tree and samples boxSize x boxSize
% patches for each image
% returns a cell of nImages x 1 each containing names of image names
eval(config_file);

fid = fopen(path.trainingNames, 'r');
imageNames = textscan(fid, '%s');
imageNames = imageNames{1};
fclose(fid);

labelNames = strcat([DIR.groundTruth, '/'], regexprep(imageNames, '\.bmp$', '_GT.bmp'));
imageNames = strcat([DIR.images, '/'], imageNames);
numTrain = numel(imageNames);

%% first select patches for each training images
rad = (boxSize-1)/2; % of patch

data = struct([]);
k = 1;
wait = waitbar(0, 'preprocessing data');
for i = 1:numTrain
    [r, c, ~] = size(imread(imageNames{i}));
    indices = reshape(1:r*c, r, c);
    indices = indices(boxSize:sampleFreq:r-boxSize, boxSize:sampleFreq:c-boxSize);
    [ri, ci] = ind2sub([r,c], indices(:)); % subsampled center pixels of patches
    I = imread(imageNames{i});
    L = imread(labelNames{i});
    for j = 1:numel(indices)                                    
        if isKey(CLASSES, sprintf('%d', L(ri(j), ci(j), :)))            
            data(k).label = CLASSES(sprintf('%d', L(ri(j), ci(j), :)));
            data(k).patch = I(ri(j)-rad:ri(j)+rad, ...
                              ci(j)-rad:ci(j)+rad, :);            
            sfigure; imagesc(data(k).patch);
            k = k + 1;
        end

    end
    keyboard
    wait = waitbar(i/numTrain, wait, sprintf(['preprocessing training ' ...
                        'image: %d'], i));
end
close(wait);
save(path.trainingPatches, 'data');

splits = cell(numTree, 1);

for i = 1:numTree
    splits{i} = data(rand(numel(data), 1) < dataPerTree);    
end

save(path.trainingSplit, 'splits');


