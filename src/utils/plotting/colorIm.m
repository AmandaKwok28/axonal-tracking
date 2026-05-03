function im = colorIm(im, color)
% COLORIM  Apply RGB color to an image.
%   color = [r g b] in [0,1]

    colorVec = reshape(color, [1, 1, 3]);

    if ndims(im) == 2 %#ok<ISMAT>
        im = repmat(im, [1 1 3]);   % convert grayscale → RGB
    end

    im = im .* colorVec;
end