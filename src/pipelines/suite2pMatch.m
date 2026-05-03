function [] = suite2pMatch(k)

    % defaults
    if nargin < 1 || isempty(k), k = 15; end

    % load GraFT and Suite2p ROIs
    g = load('day1GraFT.mat');
    data = load('suite2pROIs.mat');
    m = load('day1Metadata.mat');

    % align the suite2p mean image to the orientation of the GraFT one
    im = data.ops.meanImg;
    im = flipud(rot90(im, 1));

    % extract the coordinates of the suite2p ROIs
    stat = data.stat;
    ycoord = cellfun(@(x) x.ypix, stat(data.iscell == 0), 'UniformOutput', 0);
    xcoord = cellfun(@(x) x.xpix, stat(data.iscell == 0), 'UniformOutput', 0);

    % apply the transformations applied to im, to the coordinates of the ROIs
    R = [0 1; -1 0];

    n = numel(xcoord);
    X = cell(1, n);
    Y = cell(1, n);

    for i = 1:n
        coords = double([xcoord{i}; ycoord{i}]);
        rotCoords = R * coords;
        rotCoords(2,:) = -rotCoords(2,:);
        X{i} = rotCoords(1,:);
        Y{i} = rotCoords(2,:);
    end

    % get suite2p ROI time traces
    spks = data.spks;
    tracesSuite2p = spks(data.iscell == 0, :);

    % clean suite2p traces
    traces = rollingBaselineDFF(tracesSuite2p);

    % select a candidate ROI for matching along with it's trace
    roi = 14; 
    trace = rollingBaselineDFF(g.D(:, roi));

    % calculate similarity through z-scored, normalized, cross-correlation with a lag window
    trace = zscore(trace);
    maxLag = 5;
    N = size(traces, 1);
    scores = zeros(N, 1);
    for i = 1:N
        tmp = zscore(traces(i, :));
        c = xcorr(tmp, trace, maxLag, 'coeff');     % only the times should matter, magnitude is biased
        scores(i) = max(c);                         % get the best alignment
    end

    % get the topK matched ROIs
    [~, idx] = sort(scores, 'descend');
    topIdx = idx(1:k);
    xTop = X(topIdx);
    yTop = Y(topIdx);

    % create the final figure
    figure;

    % top row: original mean image, mean image with suite2p rois overlaid
    subplot(2, 2, 1); imagesc(m.meanIm); axis off; axis square;
    subplot(2, 2, 2); imagesc(im); clim([0 500]); axis off; axis square; plotSuite2p(X, Y, im);
    
    % bottom row: selected ROI, matched suite2p overlaid with topK, suite2p overlaid with topK + N
    subplot(2, 2, 3); imagesc(g.S(:,:, roi)); axis off; axis square;
    subplot(2, 2, 4); imagesc(im); clim([0 500]); axis off; axis square; plotSuite2p(xTop, yTop, im); axis off; axis square;

end


function plotSuite2p(xcoord, ycoord, meanImg, varargin)
    % Parse optional parameters
    p = inputParser;
    p.addParameter('figNo', 1);
    p.addParameter('markerSize', 5);  % Adjust marker size
    p.addParameter('alpha', 1);  % Transparency for scatter points
    parse(p, varargin{:});
    p = p.Results;

    numROIs = length(xcoord);  % Number of ROIs (cells)

    % Generate distinguishable colors for each ROI
    colors = distinguishable_colors(numROIs);

    % Normalize meanImg to [0, 1]
    normImg = double(meanImg) / max(meanImg(:));
    mask = normImg > 0.051;
    % mask = normImg > 180;
    hold on;
    % Loop over each ROI and plot the corresponding coordinates
    for j = 1:numROIs
        x_values = round(xcoord{j});  % Get x-coordinates for the j-th ROI
        y_values = round(ycoord{j});  % Get y-coordinates for the j-th ROI

        % Filter valid indices
        validIdx = (x_values > 0 & x_values <= size(meanImg, 2)) & ...
                   (y_values > 0 & y_values <= size(meanImg, 1));
        
        x_values = x_values(validIdx);
        y_values = y_values(validIdx);

        if isempty(x_values) || isempty(y_values)
            continue;  % Skip if no valid coordinates
        end

        % Get intensity weights from the normalized image
        % weights = normImg(sub2ind(size(meanImg), y_values, x_values));
        weights = mask(sub2ind(size(mask), y_values, x_values));
        allColors = repmat(colors(j,:), length(x_values), 1);

        % Compute weighted color for each point
        weightedColor = allColors' .* weights;

        % avoid having black dots        
        tmp = weights > 0;
        weightedColor = weightedColor(:, tmp);
        x_values = x_values(tmp);
        y_values = y_values(tmp);
        % weightedColor = allColors';

        % Plot points with weighted colors
        scatter( ...
            x_values, ...
            y_values, ...
            p.markerSize, ...
            weightedColor', ...
            'filled', ...
            'MarkerFaceAlpha', p.alpha);
        hold on;
    end

    % Set axis labels and title
    axis off;
end

