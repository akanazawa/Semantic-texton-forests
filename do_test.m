function do_test(config_file)
%%%%%%%%%%%%%%%%%%%%
% Testing STF just for pixel level output
% 1. preprocess test data (make patches)
% 2. let it go down the tree, get class distribution P(C|X) and the
% bag of semantic texton histogram BOST, a non-normalized histogram
% that concatenates the occurrences of tree nodes across all trees
%
% May 30 '12 Angjoo Kanzawa
%%%%%%%%%%%%%%%%%%%%
DISPLAY = 1;
eval(config_file); % load settings

%% load the forest
load(PATH.forestFilled);

fid = fopen(PATH.testNames, 'r');
imageNames = textscan(fid, '%s');
imageNames = imageNames{1};
fclose(fid);
numTest = numel(imageNames);
wait = waitbar(0, 'testing');

for i = 1:numTest
    [data] = getPatches(imageNames{i}, DIR, [], BOX, []);
    pred = zeros(numel(data), 1);
    for j = 1:numel(data)        
        dist = zeros(numClass, 1);
        for t = 1:FOREST.numTree
            dist = dist + forest(t).classify(data(j));
        end
        dist = dist./FOREST.numTree;
        % normalize
        dist = (dist + 1e-4./numClass)./(sum(dist) + 1e-4);
        pred(j) = max(dist);
    end
    I = imread(imageNames{i});
    [r, c, ~] = size(I);
    pred = reshape(pred, r, c);
    predRGB = label2rgb(pred, LABELS);
    if DISPLAY
        figure(1), imshow(I), hold on;
        himage = imshow(predRGB);
        set(himage, 'AlphaData', 0.3);
    end
    %    imwrite(fullfile(DIR.result, imageNames{i}), 'bmp');
    wait = waitbar(i/numTest, wait, sprintf(['done evaluating test ' ...
                        'image %d'], i));
end                                   
close(wait);



