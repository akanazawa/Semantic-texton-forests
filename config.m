%%%%%%%%%%%%%%%%%%%%
% CONFIGURATION file for STF
%%%%%%%%%%%%%%%%%%%%

% directory settings
DIR.dataset ='/Users/kanazawa/Documents/projects/datasets/MSRC21/';
DIR.images = fullfile(DIR.dataset, 'Images');
DIR.groundTruth = fullfile(DIR.dataset, 'GroundTruth');
DIR.result = 'results/';

path.trainingNames = fullfile(DIR.dataset, 'train.txt');
path.testingNames = fullfile(DIR.dataset, 'test.txt');
path.trainingSplit = fullfile(DIR.result, 'trainingSplit.mat');
path.trainingPatches = fullfile(DIR.result, 'trainingPatches.mat');
path.labelWeights = fullfile(DIR.result, 'labelWeights.mat');
% algorithm parameters
sampleFreq = 4; % space between sampled patches
boxSize = 15; % patch size = boxSize x boxSize
dataPerTree = .25; % frequency to sample
numFeature = 400;
numThreshold = 5;
maxDepth = 10;
numTree = 5;
factory = {@addTwo, @subAbs, @sub, @unary};

% ignoring cow, sheep, book. 18 classes
CLASSES = containers.Map({... 
%   000,        %  0. void
    '12800',    %  1. building
    '01280',    %  2. grass
    '1281280',  %  3. tree
              %    00128',    %  4. cow COMMENT OUT LATER
              %    0128128',  %  5. sheep COMMENT OUT LATER
    '128128128',%  6. sky
    '19200',    %  7. aeroplane
    '641280',   %  8. water
    '1921280',  %  9. face
    '640128',   % 10. car
    '1920128',  % 11. bicycle
    '64128128', % 12. flower
    '192128128',% 13. sign
    '0640',     % 14. bird
              %    128640',   % 15. book COMMENT OUT LATER
    '01920',    % 16. chair
    '12864128', % 17. road
    '0192128',  % 18. cat
    '128192128',% 19. dog
    '64640',    % 20. body
    '192640',     % 21. boat
    ...
    }, {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18});

numClass = CLASSES.Count;

%%%%%%%%%% end config %%%%%%%%%%

% CLASSES = [... 
%     [0, 0, 0],         %  0. void
%     [128, 0, 0],     %  1. building
%     [0, 128, 0],     %  2. grass
%     [128, 128, 0],   %  3. tree
%     [0, 0, 128],     %  4. cow COMMENT OUT LATER
%     [0, 128, 128],   %  5. sheep COMMENT OUT LATER
%     [128, 128, 128], %  6. sky
%     [192, 0, 0],     %  7. aeroplane
%     [64, 128, 0],    %  8. water
%     [192, 128, 0],   %  9. face
%     [64, 0, 128],    % 10. car
%     [192, 0, 128],   % 11. bicycle
%     [64, 128, 128],  % 12. flower
%     [192, 128, 128], % 13. sign
%     [0, 64, 0],      % 14. bird
%     [128, 64, 0],    % 15. book COMMENT OUT LATER
%     [0, 192, 0],     % 16. chair
%     [128, 64, 128],  % 17. road
%     [0, 192, 128],   % 18. cat
%     [128, 192, 128], % 19. dog
%     [64, 64, 0],     % 20. body
%     [192, 64, 0]     % 21. boat
%                      %Color.FromArgb[128, 0, 128],   % horse
%                      %Color.FromArgb[64, 0, 0],      % mountain
%     ...
%     ];
