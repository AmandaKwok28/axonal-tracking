function data = alignTrialsOld(data)
% old function that isn't used
% function aligns the trials usign the first image as the reference 
% aligns based on mean images

    % check for number of trials
    fields = fieldnames(data);
    nFsim = sum(startsWith(fields, 'Fsim'));

    % make sure we're not counting data.Fsim
    if isfield(data, 'Fsim')
        nFsim = nFsim - 1;
    end

    % error handling
    if nFsim <= 1
        return
    end

    % preallocate the shifts
    shifts = zeros(nFsim * 2,1);

    [~, img, y_s, x_s] = cross_corr(data.Fsim1,data.Fsim2);
    shifts(1) = y_s;
    shifts(2) = x_s;
    j = 3;
    for i=3:nFsim
        name = ['Fsim' num2str(i)];
        [~, img, y_s, x_s] = cross_corr(img, data.(name));
        shifts(j) = y_s;
        shifts(j+1) = x_s;
        j = j+2;
    end

    y_shifts = [shifts(1:2:end)];
    x_shifts = [shifts(2:2:end)];

    % accounts for negative shifts
    top    = max(0, ceil(max(y_shifts)));
    bottom = max(0, ceil(-min(y_shifts)));
    left   = max(0, ceil(max(x_shifts)));
    right  = max(0, ceil(-min(x_shifts)));

    img_cropped = img( ...
    1+top   : end-bottom, ...
    1+left  : end-right, ...
    :);


    data.Fsim = img_cropped;

end



function [m, im, yshift, xshift] = cross_corr(im1, im2) 
    % for this function, im1 is the template (the aggregate mean image)

    % obtain the mean images for comparison
    m1 = mean(im1, 3);
    m2 = mean(im2, 3);

    % perform corss correlation using C = normxcorr2(template, A)
    % C contains the correlation coefficients
    % also note, [M, I] = max() where M = value, I = index 
    % find the maximum point of correlation and align the two images to that point
    C = normxcorr2(m1, m2);
    [~, maxIdx] = max(C(:));

    % [row, col] = ind2sub(sz, ind)
    [y, x] = ind2sub(size(C), maxIdx);
    
    % we assume the images are the same size
    yshift = y - size(m1, 1);
    xshift = x - size(m1, 2);

    % doesn't matter if the shift is circular, we crop it anyway
    im = circshift(im2, [-yshift, -xshift, 0]);
    im = cat(3, im1, im);
    m = mean(im, 3);

end