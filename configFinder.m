%%%%%%%%%%%%%%%%%%%%
% CONFIGURATION file for STF
%%%%%%%%%%%%%%%%%%%%
% directory settings
DIR.dataset ='/Users/kanazawa/Documents/projects/datasets/finder/Queries';
DIR.images = fullfile(DIR.dataset);
%DIR.groundTruth = fullfile(DIR.dataset, 'GroundTruth');
DIR.result = 'finder/';
DIR.exec = 'results/';
PATH.trainingNames = fullfile(DIR.dataset, 'trainval.txt');
PATH.testNames = fullfile(DIR.dataset, 'test.txt');
PATH.trainingPatches = fullfile(DIR.result, 'trainingPatches.mat');
%PATH.trainingPointsSub = fullfile(DIR.result, 'trainingPointsSub.mat');
PATH.labelWeights = fullfile(DIR.exec, 'labelWeights.mat');
PATH.forestSkeleton = fullfile(DIR.result, 'forestSkeleton.mat');
PATH.forestFilled = fullfile(DIR.exec, 'forestFilled.mat');
% PATH.forestSkeletonByImages = fullfile(DIR.result, 'forestSkeletonByImages.mat');
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

LABELS = [... 
%    [0, 0, 0],         %  0. void
    [128, 0, 0],     %  1. building
    [0, 128, 0],     %  2. grass
    [128, 128, 0],   %  3. tree
                     %    [0, 0, 128],     %  4. cow COMMENT OUT LATER
                     %    [0, 128, 128],   %  5. sheep COMMENT OUT LATER
    [128, 128, 128], %  4. sky
    [192, 0, 0],     %  5. aeroplane
    [64, 128, 0],    %  6. water
    [192, 128, 0],   %  7. face
    [64, 0, 128],    %  8. car
                     %    [192, 0, 128],   %  9. bicycle
    [64, 128, 128],  % 9. flower
                     %    [192, 128, 128], % 10. sign
    [0, 64, 0],      % 11. bird
                     %    [128, 64, 0],    % 15. book COMMENT OUT LATER
                     %[0, 192, 0],     % 12. chair
    [128, 64, 128],  % 13. road
    [0, 192, 128],   % 14. cat
    [128, 192, 128], % 15. dog
    [64, 64, 0],     % 16. body
    [192, 64, 0]     % 17. boat
                     %Color.FromArgb[128, 0, 128],   % horse
    [64, 0, 0],      % mountain
    ...
    ];
% matlab doesn't let you use vector as keys so use char
k = num2str(LABELS, '%d%d%d');
% ignoring cow, sheep, book 19 classes
CLASSES = containers.Map(strtrim(cellstr(k)),...
                         int8(1:size(k, 1)));
clear k, LABELS;
numClass = double(CLASSES.Count);

%%%%%%%%%% end config %%%%%%%%%%
