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

