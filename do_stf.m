%%%%%%%%%%%%%%%%%%%%
% Implementation of 'Semantic Texton Forests for Image
% Categorization and Segmentation' by Jamie Shotton, Matthew
% Johnson, Roberto Cipolla CVPR 08
% based on C# code provided by Matthew Johnson
%
%%%%%%%%%%%%%%%%%%%%
config_file = 'config';

%% train the forest
do_train(config_file);

%% test the forest
do_test(config_file);

%% example: extract BOST
I = imread('/Users/kanazawa/Documents/projects/datasets/MSRC21/Images/15_21_s.bmp');
gt = imread(['/Users/kanazawa/Documents/projects/datasets/MSRC21/' ...
             'GroundTruth/15_21_s_GT.bmp']);
mask = logical(rgb2gray(gt));
load('results/forestFilled.mat'); % load 'forest'
bost = extractBost(I, mask, forest, 15);
