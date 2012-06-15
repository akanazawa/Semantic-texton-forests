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
DEBUG = 0;
eval(config_file); % load settings

%% preprocess test images
if ~exist(path.testPatches, 'file')
    data = sampleTestPatches(config_file);
else
    load(path.testPatches); % load data
end
% sanity check.. luv2rgb takes a while
if DEBUG
    %    patches = cell(numel(data), 1);
    %    [patches{:}] = deal(data.patch);
    cform = makecform('lab2srgb');
    start = randi(numel(data)-500);
    range = start:start+500;
    debug = uint8(zeros(boxSize, boxSize, 3, numel(range)));
    for i = 1:numel(range)
        debug(:, :, :, i) = data(range(i)).patch;%applycform(data(range(i)).patch, cform);
    end
    sfigure; montage(debug); 
end

%% load the forest
load(path.forestFilled);

numTest = numel(data);
wait = waitbar(0, 'testing');
for i = 1:numTest
    for t = 1:numTree
        dist = forest(t).classify(data(i));
    end
    wait = waitbar(i/numTest, wait, sprintf(['done evaluating test ' ...
                        'image %d'], i));
end                                   
close(wait);



