function [splits] = sampleTrainingImages(config_file)
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

%%  select patches from each training images
if ~exist(path.trainingPatchesSub, 'file')
    rad = (boxSize-1)/2; % of patch
    data = struct([]);
    k = 1; 
    cform = makecform('srgb2lab');
    wait = waitbar(0, 'preprocessing data');
    for i = 1:numTrain
        I = imread(imageNames{i});
        L = imread(labelNames{i});
        Ilab = applycform(I, cform);    
        [r, c, ~] = size(I);
        indices = reshape(1:r*c, r, c);
        indices = indices(rad+1:sampleFreq:r-rad, rad+1:sampleFreq:c-rad);
        [ri, ci] = ind2sub([r,c], indices(:)); % subsampled center pixels of patches
        %% collect patches without transformation
        for j = 1:numel(indices)
            rgb = strtrim(sprintf('%d%d%d', L(ri(j)-rad, ci(j)-rad, :)));
            if isKey(CLASSES, rgb) 
                data(k).label = CLASSES(rgb);
                data(k).patch = Ilab(ri(j)-rad:ri(j)+rad, ci(j)-rad:ci(j)+rad, :);
                k = k + 1;
            end        
        end
        wait = waitbar(i/numTrain, wait, sprintf(['preprocessing training ' ...
                            'image: %d'], i));
    end
    close(wait);
    save(path.trainingPatchesSub, 'data');
end

%% make splits
load(path.trainingPatchesSub);
splits = cell(numTree, 1);
for i = 1:numTree
    splits{i} = data(rand(numel(data), 1) < dataPerTree);    
end
save(path.trainingSplit, 'splits');
