%%%%%%%%%%%%%%%%%%%%
% Implementation of 'Semantic Texton Forests for Image
% Categorization and Segmentation' by Jamie Shotton, Matthew
% Johnson, Roberto Cipolla CVPR 08
% based on C# code provided by Matthew Johnson
%
%%%%%%%%%%%%%%%%%%%%

DIR.dataset ='/Users/kanazawa/Documents/projects/datasets/MSRC21/';
DIR.images = fullfile(DIR.dataset, 'Images');
DIR.groundTruth = fullfile(DIR.dataset, 'GrountTruth');
DIR.results = 'results/';

% ignoring cow, sheep, book. 18 classes
CLASSES = { ... 
    [0, 0, 0],         %  0. void
    [128, 0, 0],     %  1. building
    [0, 128, 0],     %  2. grass
    [128, 128, 0],   %  3. tree
                     % [0, 0, 128],     %  4. cow
                     % [0, 128, 128],   %  5. sheep
    [128, 128, 128], %  6. sky
    [192, 0, 0],     %  7. aeroplane
    [64, 128, 0],    %  8. water
    [192, 128, 0],   %  9. face
    [64, 0, 128],    % 10. car
    [192, 0, 128],   % 11. bicycle
    [64, 128, 128],  % 12. flower
    [192, 128, 128], % 13. sign
    [0, 64, 0],      % 14. bird
                     % [128, 64, 0],    % 15. book
    [0, 192, 0],     % 16. chair
    [128, 64, 128],  % 17. road
    [0, 192, 128],   % 18. cat
    [128, 192, 128], % 19. dog
    [64, 64, 0],     % 20. body
    [192, 64, 0]     % 21. boat
                     %Color.FromArgb[128, 0, 128],   % horse
                     %Color.FromArgb[64, 0, 0],      % mountain
          };
