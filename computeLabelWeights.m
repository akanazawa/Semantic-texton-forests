function weights = computeLabelWeights(config_file)
%%%%%%%%%%%%%%%%%%%%
% Compute inverse-label frequency where weight for class i is the
% total number of labels / # of valid pixels labeled i
%%%%%%%%%%%%%%%%%%%%

eval(config_file);

fid = fopen(PATH.trainingNames, 'r');
imageNames = textscan(fid, '%s');
labelNames = strcat([DIR.groundTruth, '/'], regexprep(imageNames{1}, '\.(bmp|jpg)$', '_GT.bmp'));
numTrain = numel(labelNames);
fclose(fid);

weights = zeros(numClass, 1);
wait = waitbar(0, 'preprocessing data');
for i = 1:numTrain
    L = imread(labelNames{i});
    [r, c, d] = size(L);
    L2 = num2str(reshape(L, r*c, d), '%d%d%d');
    rgb = strtrim(cellstr(L2));
    ok = isKey(CLASSES, rgb);
    found = double(cell2mat(values(CLASSES, rgb(ok))));
    weights = weights + hist(found, 1:numClass)';
    wait = waitbar(i/numTrain, wait, sprintf(['computing labels ' ...
                        'image: %d'], i));
end
close(wait);
weights = sum(weights)./weights;

save(PATH.labelWeights, 'weights');
