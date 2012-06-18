function [I2, L2] = transformImage(I, L, transform)
%%%%%%%%%%%%%%%%%%%%
% Transforms image randomly
%%%%%%%%%%%%%%%%%%%%
DEBUG = 0;
% set settings randomly 
r = rand(10,1);
angle = (2*transform.maxAngle*r(1)-transform.maxAngle)*180./pi;
scale = [r(2)*(transform.maxScale - 1/transform.maxScale) + 1/transform.maxScale, ...
         r(3)*(transform.maxAnisotropicScale - 1/transform.maxScale) + 1/transform.maxAnisotropicScale];
scale(2) = scale(2)*scale(1);
if r(4) < 0.5 % no bias to x or y
    scale = scale([2 1]); % swap x y
end
flip = [r(5)<0.5, r(6)<0.5];
blur = r(7)*transform.maxBlur;
noise = r(8)*transform.maxNoise;
alpha = r(9)*(transform.maxAlpha - 1/transform.maxAlpha) + 1/transform.maxAlpha;
beta = 2*transform.maxBeta*r(10) - transform.maxBeta;

I2 = I;
L2 = L;
% 1.  filter the image with gaussian
sze = ceil(6*blur);

if ~mod(sze, 2), sze = sze + 1; end; %always odd
h = fspecial('gaussian', sze, blur);
I2 = imfilter(I2, h);

if DEBUG, sfigure; subplot(3,3,1); imagesc(I2); title('after blur');end;

% 2. add noise
I2 = imnoise(I, 'gaussian', 0, noise);
if DEBUG, subplot(3,3,2); imagesc(I2); title('after noise');end;
% 3. flip
if flip(1)
    I2(:, :, 1) = fliplr(I2(:, :, 1));
    I2(:, :, 2) = fliplr(I2(:, :, 2));
    I2(:, :, 3) = fliplr(I2(:, :, 3));
    L2(:, :, 1) = fliplr(L2(:, :, 1));
    L2(:, :, 2) = fliplr(L2(:, :, 2));
    L2(:, :, 3) = fliplr(L2(:, :, 3));
end
if flip(2)
    I2(:, :, 1) = flipud(I2(:, :, 1));
    I2(:, :, 2) = flipud(I2(:, :, 2));
    I2(:, :, 3) = flipud(I2(:, :, 3));
    L2(:, :, 1) = flipud(L2(:, :, 1));
    L2(:, :, 2) = flipud(L2(:, :, 2));
    L2(:, :, 3) = flipud(L2(:, :, 3));    
end
if DEBUG, subplot(3,3,3); imagesc(I2); title('after flip');end;
% 4. rotate
I2 = imrotate(I2, angle, 'bilinear', 'crop');
L2 = imrotate(L2, angle, 'nearest', 'crop');
if DEBUG, subplot(3,3,4); imagesc(I2); title('after rotate');end;
% 5. scale
[r, c, ~] = size(I2);
newSize = round([r, c].*scale);
I2 = imresize(I2, newSize, 'bilinear');
L2 = imresize(L2, newSize, 'nearest');
if DEBUG, subplot(3,3,5); imagesc(I2); title('after scale');end;
% 6. affine transform I = AI + b..?
Idb = im2double(I2);
I2 = bsxfun(@times, Idb, reshape(ones(3,1)*alpha, [1 1 3]));
I2 = bsxfun(@plus, I2, reshape(ones(3,1)*beta, [1 1 3]));
I2 = im2uint8(I2);
if DEBUG, subplot(3,3,6); imagesc(I2); title('after color affine');end;
% if DEBUG, subplot(3,3,7); imagesc(I2); title('after lab');end;
% if DEBUG, subplot(3,3,8); imagesc(I); title('original'); end;
% if DEBUG, subplot(3,3,9); imagesc(L2); title('final label'); end;
assert(all(size(I2) == size(L2)))


