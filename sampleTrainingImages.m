function data = sampleTrainingImages(config_file)
% subsamples the image by BOX.sampleFreq and for each subsampled
% pixel, if the label is valid, stores its label and extracts boxSize x boxSize x 3 patches for each image,
% Returns data, a struct array with fields label and patch.
eval(config_file);

fid = fopen(PATH.trainingNames, 'r');
imageNames = textscan(fid, '%s');
imageNames = imageNames{1};
fclose(fid);

labelNames = strcat([DIR.groundTruth, '/'], regexprep(imageNames, '\.(bmp|jpg)$', '_GT.bmp'));
imageNames = strcat([DIR.images, '/'], imageNames);
numTrain = numel(imageNames);

%%  select patches from each training images
if ~exist(PATH.trainingPatches, 'file')
    rad = (BOX.size-1)/2; % of patch
    data = struct([]);
    k = 1; 
    wait = waitbar(0, 'preprocessing data');
    for i = 1:numTrain
        I = imread(imageNames{i});
        L = imread(labelNames{i});
        Ilab = applycform(I, BOX.cform);    
        [r, c, ~] = size(I);
        [ri, ci] = ndgrid(1:r, 1:c);
        % subsampled center pixels of patches
        ri = ri(rad+1:BOX.sampleFreq:r-rad,rad+1:BOX.sampleFreq:c-rad);
        ci = ci(rad+1:BOX.sampleFreq:r-rad,rad+1:BOX.sampleFreq:c-rad);
        for j = 1:numel(ri)
            gt = find(L(ri(j), ci(j), 1) == LABELS(:, 1) & ...
                      L(ri(j), ci(j), 2) == LABELS(:, 2) & ...
                      L(ri(j), ci(j), 3) == LABELS(:, 3) );            
            if ~isempty(gt)
                data(k).label = gt;                            
                data(k).patch = Ilab(ri(j)-rad:ri(j)+rad, ci(j)-rad:ci(j)+rad, :);
                k = k + 1;
            end        
        end
        wait = waitbar(i/numTrain, wait, sprintf(['preprocessing training ' ...
                            'image: %d'], i));
    end
    close(wait);
    save(PATH.trainingPatches, 'data', '-v7.3');
end
