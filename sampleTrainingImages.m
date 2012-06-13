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
dataT = struct([]);
k = 1; kt = 1;
cform = makecform('srgb2lab');
wait = waitbar(0, 'preprocessing data');
for i = 1:numTrain
    I = imread(imageNames{i});
    L = imread(labelNames{i});
    Ilab = applycform(I, cform);    
    [r, c, ~] = size(I);
    indices = reshape(1:r*c, r, c);
    indices = indices(boxSize:sampleFreq:r-boxSize, boxSize:sampleFreq:c-boxSize);
    [ri, ci] = ind2sub([r,c], indices(:)); % subsampled center pixels of patches
                                           
    %% collect patches without transformation
    for j = 1:numel(indices)
        rgb = strtrim((num2str(L(ri(j), ci(j), :), '%d%d%d')));
        if isKey(CLASSES, rgb) 
            data(k).label = CLASSES(rgb);
            data(k).patch = Ilab(ri(j)-rad:ri(j)+rad, ...
                              ci(j)-rad:ci(j)+rad, :);
            k = k + 1;
        end        
    end
    %% collect patches after transformation
    for t = 1:numTransform
        [Ilab2, L2] = transformImage(I, L, transform);
        [r, c, ~] = size(Ilab2);
        indices = reshape(1:r*c, r, c);
        indices = indices(boxSize:sampleFreq:r-boxSize, boxSize:sampleFreq:c-boxSize);
        [ri, ci] = ind2sub([r,c], indices(:)); % subsampled center pixels of patches
        for j=1:numel(indices)
            rgb = strtrim((num2str(L2(ri(j), ci(j), :), '%d%d%d')));
            if isKey(CLASSES, rgb) 
                dataT(kt).label = CLASSES(rgb);
                dataT(kt).patch = Ilab2(ri(j)-rad:ri(j)+rad, ...
                                        ci(j)-rad:ci(j)+rad, :);
                kt = kt + 1;
            end                
        end
    end
    wait = waitbar(i/numTrain, wait, sprintf(['preprocessing training ' ...
                        'image: %d'], i));
end
close(wait);
save(path.trainingPatches, 'data');
save(path.trainingPatchesTransformed, 'dataT');

splits = cell(numTree, 1);

for i = 1:numTree
    splits{i} = data(rand(numel(data), 1) < dataPerTree);    
end

save(path.trainingSplit, 'splits');
