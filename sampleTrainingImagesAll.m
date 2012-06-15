function [data, dataT] = sampleTrainingImagesAll(config_file)
% creates nImages split for each tree and samples boxSize x boxSize
% patches for each image
% returns a cell of nImages x 1 each containing names of image names
% No subsampling, collect patches from all pixels. Edge cases are
% treated by replication
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
    Ipad = padarray(I, [rad, rad], 'symmetric');
    [r, c, ~] = size(Ipad);
    Ilab = applycform(Ipad, cform);    
    indices = reshape(1:r*c, r, c);
    indices = indices(rad+1:r-rad, rad+1:c-rad);
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
    %% collect patches after transformation
    for t = 1:numTransform
        [Ilab2, L2] = transformImage(I, L, transform);
        Ilab2 = padarray(Ilab2, [rad, rad], 'symmetric');
        [r, c, ~] = size(Ilab2);
        indices = reshape(1:r*c, r, c);
        indices = indices(rad+1:r-rad, rad+1:c-rad);
        [ri, ci] = ind2sub([r,c], indices(:)); % subsampled center pixels of patches
        for j=1:numel(indices)           
            rgb = strtrim(sprintf('%d%d%d', L2(ri(j)-rad, ci(j)-rad, :)));
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
save(path.trainingPatchesAll, 'data');
save(path.trainingPatchesTransformed, 'dataT');

