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
% labelNames = strcat([DIR.groundTruth, '/'], ...
%                     regexprep(imageNames, '\.bmp$', '_GT.bmp'));
imageNamesFull = strcat([DIR.images, '/'], imageNames);

numTest = numel(imageNames);
wait = waitbar(0, 'testing');
fprintf('start testing\n');
totalTime = 0;
for i = 1:numTest
    tic;
    patches = getPatches(imageNames{i}, DIR, [], BOX, []);   
    dist = zeros(numClass, size(patches, 3), FOREST.numTree);
    for t = 1:FOREST.numTree            
        [dist(:, :, t), ~] = forest(t).classify(patches);
        % sfigure; bar(test(:, 550)); title(sprintf('dist of tree %d', t));
    end
    distAll = sum(dist, 3)./FOREST.numTree;
    % normalize
    distAll = bsxfun(@rdivide, distAll+(1e-4./numClass), sum(distAll)+1e-4);
    [~, pred] = max(distAll, [], 1);
    totalTime = totalTime + toc;
    I = imread(imageNamesFull{i});
    % L = imread(labelNames{i});
    [r, c, ~] = size(I);
    pred = reshape(pred, r, c);
    predRGB = label2rgb(pred, LABELS./255);
    % h=figure(1); subplot(131); imagesc(I); hold on;
    % himage = imagesc(predRGB);
    % set(himage, 'AlphaData', 0.4); 
    % axis off image; title('overlay');
    % subplot(132); imagesc(predRGB);    axis off image; 
    % title('prediction');
    % subplot(133); imagesc(L);    axis off image; 
    % title('ground truth');
    %%
    h=figure(1); clf;subplot(121); imagesc(I); hold on;
    himage = imagesc(predRGB);
    set(himage, 'AlphaData', 0.3); 
    axis off image; title('overlay');
    subplot(122); imagesc(predRGB);    axis off image; 
    title('prediction');
    print(h, '-dpng', fullfile(DIR.result, regexprep(imageNames{i}, '\.jpg$', '.png')))
    %%

    % imwrite(predRGB, fullfile(DIR.result, imageNames{i}), 'bmp');
    wait = waitbar(i/numTest, wait, sprintf(['done evaluating test ' ...
                        'image %d'], i));
end                                   
close(wait);

fprintf('average time for labeling: %g\n', totalTime/numTest);

