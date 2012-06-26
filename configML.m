%%%%%%%%%%%%%%%%%%%%
% CONFIGURATION file for STF
% trains with MSRC and LabelMe subset
%%%%%%%%%%%%%%%%%%%%
% directory settings
DIR.dataset ='/Users/kanazawa/Documents/projects/datasets/bothMSRCLabelMe';
DIR.images = fullfile(DIR.dataset, 'Images');
DIR.groundTruth = fullfile(DIR.dataset, 'GroundTruth');
DIR.result = fullfile(DIR.dataset, 'results/');
PATH.trainingNames = fullfile(DIR.dataset, 'trainvalLabelMeonly.txt');
%PATH.trainingNames = fullfile(DIR.dataset, 'trainval.txt');
PATH.testNames = fullfile(DIR.dataset, 'test.txt');
PATH.trainingPatches = fullfile(DIR.result, 'trainingPatches.mat');
%PATH.trainingPointsSub = fullfile(DIR.result, 'trainingPointsSub.mat');
PATH.labelWeights = fullfile(DIR.result, 'labelWeights.mat');
PATH.forestSkeleton = fullfile(DIR.result, 'forestSkeleton.mat');
PATH.forestFilled = fullfile(DIR.result, 'forestFilled.mat');
% PATH.forestSkeletonpByImages = fullfile(DIR.result, 'forestSkeletonByImages.mat');
% PATH.forestFilledByImages = fullfile(DIR.result, 'forestFilledByImages.mat');

% patch sampling parameters
BOX.sampleFreq = 4; % space between sampled patches
BOX.size = 15; % patch size = boxSize x boxSize
BOX.cform = makecform('srgb2lab');
% Forest paramters
FOREST.dataPerTree = .25; % frequency to sample
FOREST.numFeature = 400;
FOREST.numThreshold = 5;
FOREST.maxDepth = 10;
FOREST.numTree = 5;
FOREST.factory = {'addTwo', 'subAbs', 'sub', 'unary'};
% transform parameters
TRANSFORM.numTransform = 1; % how many transformations to do on single image
TRANSFORM.maxAngle = pi/32;
TRANSFORM.maxScale = 1.2;
TRANSFORM.maxAnisotropicScale = 1.1;
TRANSFORM.maxBlur = 1.2;
TRANSFORM.maxNoise = .05;
TRANSFORM.maxAlpha = 1.4;
TRANSFORM.maxBeta = .1;
% according to labelMe classes
LABELS = [... 
%    [0, 0, 0],         %  0. void
    [128, 128, 0],   % tree = 2
    [128, 64, 128],  % road = 7
    [128, 0, 0],     % building = 4
    [0, 128, 0],     % grass = 1
    [128, 128, 128], % sky = 8
    [64, 128, 0],    % water = 6
    [192, 64, 0]     % boat = 17
    [64, 0, 0],      % mountain = 12
    [255, 255, 0],      % sand = 14 (not in MSRC21)
    [255, 130, 171],      % ground (not in MSRC21)
    [139, 90, 43],      % rock (not in MSRC21)    
    ...
    ];

% matlab doesn't let you use vector as keys so use char
k = num2str(LABELS, '%d%d%d');
CLASSES = containers.Map(strtrim(cellstr(k)),...
                         int8(1:size(k, 1)));
numClass = double(CLASSES.Count);
CLASSNAMES = containers.Map({'tree', 'road', 'building', 'grass', 'sky', ...
                    'water', 'boat', 'mountain', 'sand', 'ground', 'rock'}, ...
                            mat2cell(LABELS, ones(numClass, 1)));


%%%%%%%%%% end config %%%%%%%%%%
