function [data, Is] = getPatchesByImages(fname, DIR, LABELS, BOX, TRANSFORM)
% No subsampling, collect patches from all pixels. Edge cases are
% treated by replication
if ~isempty(TRANSFORM)
    Is = cell(TRANSFORM.numTransform+1, 1);
    DEBUG = 0;
    k = 1;
    data = struct([]);
    rad = (BOX.size-1)/2; % of patch
    I = imread(fullfile(DIR.images, fname));
    L = imread(fullfile(DIR.groundTruth, regexprep(fname, '\.bmp$', '_GT.bmp')));
    Ipad = padarray(I, [rad, rad], 'symmetric');
    [r, c, ~] = size(Ipad);
    Ilab = applycform(Ipad, BOX.cform);    
    Is{1} = Ilab;
    [ri, ci] = ndgrid(1:r, 1:c);
    ri = ri(rad+1:r-rad,rad+1:c-rad); 
    ci = ci(rad+1:r-rad,rad+1:c-rad);
    %% collect patches without transformation
    for j = 1:numel(ri)
        % need -rad because L wasn't padded
        gt = find(L(ri(j)-rad, ci(j)-rad, 1) == LABELS(:, 1) & ...
                      L(ri(j)-rad, ci(j)-rad, 2) == LABELS(:, 2) & ...
                      L(ri(j)-rad, ci(j)-rad, 3) == LABELS(:, 3) );            
        if ~isempty(gt)
            data(k).label = gt;
            data(k).imageId = 1;
            data(k).row = ri(j);
            data(k).col = ci(j);
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
        Is{t+1} = Ilab2
        [r, c, ~] = size(Ilab2);
        [ri, ci] = ndgrid(1:r, 1:c);
        ri = ri(rad+1:r-rad,rad+1:c-rad); 
        ci = ci(rad+1:r-rad,rad+1:c-rad);
        for j=1:numel(ri)           
            gt = find(L2(ri(j)-rad, ci(j)-rad, 1) == LABELS(:, 1) & ...
                      L2(ri(j)-rad, ci(j)-rad, 2) == LABELS(:, 2) & ...
                      L2(ri(j)-rad, ci(j)-rad, 3) == LABELS(:, 3) );            
            if ~isempty(gt)
                data(k).label = gt;
                data(k).imageId = t+1;
                data(k).row = ri(j);
                data(k).col = ci(j);
                k = k + 1;
            end                
        end
    end
else %% get patches for testing
    rad = (BOX.size-1)/2; % of patch
    I = imread(fullfile(DIR.images, fname));
    Ipad = padarray(I, [rad, rad], 'symmetric');
    [r, c, ~] = size(Ipad);
    Ilab = applycform(Ipad, BOX.cform);    
    Is = {Ilab};
    [ri, ci] = ndgrid(1:r, 1:c);
    ri = ri(rad+1:r-rad,rad+1:c-rad); 
    ci = ci(rad+1:r-rad,rad+1:c-rad);
    data = struct([]);
    for i = 1:numel(ri)
        data(i).imageId = 1;
        data(i).row = ri(j);
        data(i).col = ci(j);
    end
end

