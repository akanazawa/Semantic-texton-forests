%%%%%%%%%%%%%%%%%%%%
% Implementation of 'Semantic Texton Forests for Image
% Categorization and Segmentation' by Jamie Shotton, Matthew
% Johnson, Roberto Cipolla CVPR 08
% based on C# code provided by Matthew Johnson
%
%%%%%%%%%%%%%%%%%%%%
config_file = 'config';
% config_file = 'configML'; % doing MSRC and labelme subset together

%% train the forest
do_train(config_file);

%% test the forest
do_test(config_file);

%% example: extract BOST
% an image of cat from MSRC
I = imread('/Users/kanazawa/Documents/projects/datasets/MSRC21/Images/15_21_s.bmp');
gt = imread(['/Users/kanazawa/Documents/projects/datasets/MSRC21/' ...
             'GroundTruth/15_21_s_GT.bmp']);
% mask cuts out the cat
mask = logical(rgb2gray(gt)); 
% load trained 'forest'
load('results/forestFilled.mat'); 
bost = extractBost(I, mask, forest, 15);
