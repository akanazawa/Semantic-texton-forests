function splits = sampleTrainingImages(config_file)
% creates nImages split for each tree and samples boxSize x boxSize
% patches for each image
% returns a cell of nImages x 1 each containing names of image names
eval(config_file);

fid = fopen(path.trainingNames, 'r');
imageNames = textscan(fid, '%s');
imageNames = imageNames{1};
fclose(fid);

gtNames = regexprep(imageNames, '\.bmp$', '_GT.bmp');

numTrain = numel(imageNames);

inds = randperm(numTrain);
splits = cell(numTree, 1);

% assumes all images are same size
[r, c, ~] = size(imread(imageNames{1}));
subR = numel(boxSize:sampleFreq:r-boxSize); 
subC = numel(boxSize:sampleFreq:c-boxSize); 
numPatches = subR*subC;

for i = 1:numTree
    Is = imageNames(inds((i-1)*numTrainingPerTree+1:i*numTrainingPerTree));
    data = zeros(numTrainingPerTree*4, 1);
    for j = 1:numTrainingPerTree
        I = RGB2Luv(imread(Is{j}));
        centerPixels = I(boxSize+1:sampleFreq:r-boxSize, boxSize+1:sampleFreq:c-boxSize, :);
        inds = find(rand(numPatches, 1) < dataPerTree); % only use some
        [ri, ci] = ind2sub([r,c], inds);        
        for k = 1:numel(inds)
            
        end
       
    end
    % for j = 1:numTrainingPerTree
    %     I = RGB2Luv(imread(Is{j}));
    %     inds = find(rand(numPatches, 1) < dataPerTree); % only use some
    %     [ri, ci] = ind2sub([r,c], inds);        
    %     for k = 1:numel(inds)

    %     end
    %     centerPixels = I(boxSize:sampleFreq:r-boxSize, boxSize:2:c-boxSize, :)
    % end
end

save(path.trainingSplit, 'splits');

