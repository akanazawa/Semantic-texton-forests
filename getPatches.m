function [data] = getPatches(fname, DIR, LABELS, BOX, TRANSFORM)
% No subsampling, collect patches from all pixels. Edge cases are
% treated by replication
if ~isempty(TRANSFORM)
    DEBUG = 0;
    k = 1;
    data = struct([]);
    rad = (BOX.size-1)/2; % of patch
    I = imread(fullfile(DIR.images, fname));
    L = imread(fullfile(DIR.groundTruth, regexprep(fname, '\.bmp$', '_GT.bmp')));
    Ipad = padarray(I, [rad, rad], 'symmetric');
    [r, c, ~] = size(Ipad);
    Ilab = applycform(Ipad, BOX.cform);    
    indices = reshape(1:r*c, r, c);
    indices = indices(rad+1:r-rad, rad+1:c-rad);
    [ri, ci] = ind2sub([r,c], indices(:)); % subsampled center pixels of patches
    %% collect patches without transformation
    for j = 1:numel(indices)
        % need -rad because L wasn't padded
        gt = find(L(ri(j)-rad, ci(j)-rad, 1) == LABELS(:, 1) & ...
                      L(ri(j)-rad, ci(j)-rad, 2) == LABELS(:, 2) & ...
                      L(ri(j)-rad, ci(j)-rad, 3) == LABELS(:, 3) );            
        if ~isempty(gt)
            data(k).label = gt;
            data(k).patch = Ilab(ri(j)-rad:ri(j)+rad, ci(j)-rad:ci(j)+rad, :);
            k = k + 1;
        end        
    end
    % if no appropriate label is found no need to do transformation
    if isempty(data), return; end 
    %% collect patches after transformation
    for t = 1:TRANSFORM.numTransform    
        [I2, L2] = transformImage(I, L, TRANSFORM);
        % turn it to lab
        Ilab2 = applycform(I2, BOX.cform);    
        Ilab2 = padarray(Ilab2, [rad, rad], 'symmetric');
        [r, c, ~] = size(Ilab2);
        indices = reshape(1:r*c, r, c);
        indices = indices(rad+1:r-rad, rad+1:c-rad);
        [ri, ci] = ind2sub([r,c], indices(:)); % subsampled center pixels of patches
        for j=1:numel(indices)           
            gt = find(L2(ri(j)-rad, ci(j)-rad, 1) == LABELS(:, 1) & ...
                      L2(ri(j)-rad, ci(j)-rad, 2) == LABELS(:, 2) & ...
                      L2(ri(j)-rad, ci(j)-rad, 3) == LABELS(:, 3) );            
            if ~isempty(gt)
                data(k).label = gt;
                data(k).patch = Ilab2(ri(j)-rad:ri(j)+rad, ...
                                      ci(j)-rad:ci(j)+rad, :);
                k = k + 1;
            end                
        end
    end

    % sanity check.. luv2rgb takes a while
    if DEBUG
        start = max([0, randi(numel(data)-5000)]);
        range = start:5:start+5000;
        debug = uint8(zeros(BOX.size, BOX.size, 3, numel(range)));
        for i = 1:numel(range)
            debug(:, :, :, i) = data(range(i)).patch;%applycform(data(range(i)).patch, cform);
        end
        sfigure; montage(debug); 
    end
else %% get patches for testing
    rad = (BOX.size-1)/2; % of patch
    I = imread(fullfile(DIR.images, fname));
    Ipad = padarray(I, [rad, rad], 'symmetric');
    [r, c, ~] = size(I);
    Ilab = applycform(Ipad, BOX.cform);    
    [ri2, ci2] = ndgrid(1:r, 1:c);
    ri2 = ri2(rad+1:r-rad,rad+1:c-rad); 
    ci2 = ci2(rad+1:r-rad,rad+1:c-rad);
    data = struct([]);
    for i = 1:numel(ri2)
        data(i).patch = Ilab(ri2(i)-rad:ri2(i)+rad, ci2(i)-rad:ci2(i)+rad,:);
    end
    data = reshape([data.patch], [BOX.size, BOX.size, numel(ri2), 3]);
end

