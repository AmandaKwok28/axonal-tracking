function data = alignTrials(data)
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

    % data.Fsim1 is the ref
    ref = data.Fsim1;

    % store aligned images
    aligned = cell(nFsim, 1);
    aligned{1} = ref;

    % store shifts
    y_shifts = zeros(nFsim, 1);
    x_shifts = zeros(nFsim, 1);

    for i = 2:nFsim
        name = ['Fsim' num2str(i)];
        [shifted, yshift, xshift] = cross_corr(ref, data.(name));
        aligned{i} = shifted;
        y_shifts(i) = yshift;
        x_shifts(i) = xshift;

    end

    % accounts for negative shifts
    top    = max(0, ceil(-min(y_shifts)));  % crop top when min y_shift is negative
    bottom = max(0, ceil(max(y_shifts)));   % crop bottom when max y_shift is positive
    left   = max(0, ceil(-min(x_shifts)));  % crop left when min x_shift is negative
    right  = max(0, ceil(max(x_shifts)));   % crop right when max x_shift is positive

    % crop all aligned images consistantly
    for i = 1:nFsim
        aligned{i} = aligned{i}( ...
            1+top: end-bottom, ...
            1+left: end-right, ...
            :);
    end

    % stack and return
    data.Fsim = cat(3, aligned{:});

end



function [im, yshift, xshift] = cross_corr(im1, im2) 
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
    
    % if 0 shift, then y = size(m1, 1) and x = size(m1, 2)
    % if yshift > 0 then the template needs to be placed lower
    % if yshift < 0 then it needs to be higher, same logic for x
    yshift = y - size(m1, 1);
    xshift = x - size(m1, 2);

    fprintf('xshift: %d, yshift: %d\n', xshift, yshift);

    % shift im2 without wraparound, fill empty space with 0
    im = imtranslate(im2, [-xshift, -yshift], 'FillValues', 0);

end

