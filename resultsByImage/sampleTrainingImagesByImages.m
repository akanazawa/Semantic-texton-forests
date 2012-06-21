function [data, Is] = sampleTrainingImagesByImages(config_file)
% subsamples the image by BOX.sampleFreq and for each subsampled
% pixel, if the label is valid, stores its label, row, col, and
% it's image ID (the image this pixel belongs to) in a struct
eval(config_file);

fid = fopen(PATH.trainingNames, 'r');
imageNames = textscan(fid, '%s');
imageNames = imageNames{1};
fclose(fid);

labelNames = strcat([DIR.groundTruth, '/'], regexprep(imageNames, '\.bmp$', '_GT.bmp'));
imageNames = strcat([DIR.images, '/'], imageNames);
numTrain = numel(imageNames);
Is = cell(numTrain, 1);
%%  select patch centers from each training images
if ~exist(PATH.trainingPatches, 'file')
    rad = (BOX.size-1)/2; % of patch
    data = struct([]);
    k = 1; 
    wait = waitbar(0, 'preprocessing data');
    for i = 1:numTrain        
        I = imread(imageNames{i});
        L = imread(labelNames{i});
        Ilab = applycform(I, BOX.cform);    
        Is{i} = Ilab;
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
                data(k).imageId = i;
                data(k).row = ri(j);
                data(k).col = ci(j);
                k = k + 1;
            end        
        end
        wait = waitbar(i/numTrain, wait, sprintf(['preprocessing training ' ...
                            'image: %d'], i));
    end
    close(wait);
    save(PATH.trainingPointsSub, 'data', 'Is');
end
