function [topPairs, topCosts, scores, ims] = track(day1, day2, clean, subset1, subset2)
% TRACK  Match ROIs between two days using Chamfer distance.
%
%   [topPairs, topCosts, scores, ims] = TRACK(day1, day2, clean, subset1, subset2)
%
%   Loads spatial components (S) from two GraFT runs and computes pairwise
%   similarity between ROIs using symmetric Chamfer distance. Optionally
%   preprocesses ROIs to emphasize structure, then performs one-to-one
%   matching via the Hungarian algorithm and returns the best matches.
%
%   Inputs:
%       day1, day2  - File paths to .mat files containing variable S
%                     (HxWxN tensor of ROI spatial maps)
%
%       clean       - (optional, default = false)
%                     If true, applies thresholding + filtering to binarize
%                     ROIs before matching (shape-based comparison)
%
%       subset1     - (optional, default = all ROIs)
%                     Indices of ROIs from day1 to include
%
%       subset2     - (optional, default = all ROIs)
%                     Indices of ROIs from day2 to include
%
%   Outputs:
%       topPairs    - Kx2 array of matched ROI indices [i, j]
%                     (i from day1, j from day2), sorted best → worst
%
%       topCosts    - Kx1 vector of Chamfer distances for topPairs
%                     (lower = more similar)
%
%       scores      - Full N1 x N2 matrix of pairwise distances
%
%       ims         - Visualization tensor of matched ROI pairs
%                     (used with MovieSlider)
%
%   Notes:
%       - Matching is one-to-one (Hungarian algorithm via matchpairs)
%       - Distance is shape-based if clean=true (binary masks)
%       - Lower Chamfer distance indicates better alignment
%       - Empty ROIs are assigned a large penalty
%
%   Example:
%       [pairs, costs] = track("day1.mat", "day2.mat", true, 1:10, [1,2,5,6]);
%
%   See also: cleanROI, chamferDistance, matchpairs
    
    % load graft values
    g1 = load(day1);
    g2 = load(day2);
    d1 = g1.S;
    d2 = g2.S;

    % defaults
    if nargin < 3 || isempty(clean), clean = false; end
    if nargin < 4 || isempty(subset1), subset1 = 1:size(d1,3); end
    if nargin < 5 || isempty(subset2), subset2 = 1:size(d2,3); end
    
    % if subsets were provided for ROIs, only consider those for matching
    cleanDay1 = d1(:,:,subset1);
    cleanDay2 = d2(:,:,subset2);

    % clean rois (make landmarks more apparent) before passing to the matching algorithms
    if clean
        for i = 1:size(cleanDay1, 3)
            cleanDay1(:,:,i) = cleanROI(cleanDay1(:,:,i));
        end

        for i = 1:size(cleanDay2, 3)
            cleanDay2(:,:,i) = cleanROI(cleanDay2(:,:,i));
        end
    end

    % find good matches
    [topPairs, topCosts, scores] = matchROIs(cleanDay1, cleanDay2, 10);

    % visualize matches
    ims = pairsToTensor(cleanDay1, cleanDay2, topPairs, topCosts);
    MovieSlider(ims);                                       % assume user has MovieSlider dependency and it's added to path

end


% --------- HELPERS ---------------------------------------------------------------------------
function roi = cleanROI(roi, p, k, c)
% CLEANROI  Binarize and denoise an ROI for shape-based comparison.
%
%   roi = CLEANROI(roi, p, k, c)
%
%   Converts a grayscale ROI into a clean binary mask by thresholding at a
%   chosen percentile, smoothing with a median filter, and removing small
%   connected components. This emphasizes the dominant structure of the ROI
%   for downstream shape-based matching (e.g., Chamfer distance).
%
%   Inputs:
%       roi - HxW array (grayscale or logical ROI image)
%
%       p   - (optional, default = 93)
%             Percentile used to threshold intensity values. Higher values
%             keep only the brightest pixels.
%
%       k   - (optional, default = 2)
%             Window size for median filtering (k x k). Reduces noise and
%             small artifacts in the binary mask.
%
%       c   - (optional, default = 20)
%             Minimum connected component size (in pixels). Smaller regions
%             are removed.
%
%   Output:
%       roi - HxW logical array (cleaned binary mask)
%
%   Notes:
%       - Thresholding is relative (percentile-based), making it robust to
%         intensity scaling across images.
%       - Output is binary, so intensity information is discarded.
%       - Useful for emphasizing shape/structure before matching ROIs.
%
%   Example:
%       mask = cleanROI(roi, 95, 3, 50);
%
%   See also: prctile, medfilt2, bwareaopen

    % defaults
    if nargin < 2 || isempty(p), p = 93; end    % percentile of image brightness to threshold
    if nargin < 3 || isempty(k), k = 2; end     % filter size for median filtering
    if nargin < 4 || isempty(c), c = 20; end    % number of connected components to threshold 
    
    roi = double(roi);
    thresh = prctile(roi(:), p);
    tmp = medfilt2(roi > thresh, [k,k]);
    roi = bwareaopen(tmp, c);
end

function [topPairs, topCosts, scores] = matchROIs(x,y,k)
% MATCHROIS  Compute one-to-one ROI matches using Chamfer distance.
%
%   [topPairs, topCosts, scores] = MATCHROIS(x, y, k)
%
%   Computes pairwise distances between ROIs from two sets and finds an
%   optimal one-to-one matching using the Hungarian algorithm. ROIs are
%   compared using symmetric Chamfer distance (shape-based similarity).
%
%   Inputs:
%       x - HxWxN1 tensor of ROI masks (day 1)
%       y - HxWxN2 tensor of ROI masks (day 2)
%
%       k - (optional, default = 5)
%           Number of top matches to return
%
%   Outputs:
%       topPairs - Kx2 array of matched ROI indices [i, j]
%                  (i from x, j from y), sorted best → worst
%
%       topCosts - Kx1 vector of Chamfer distances for topPairs
%                  (lower = more similar)
%
%       scores   - N1 x N2 matrix of pairwise distances between all ROIs
%
%   Notes:
%       - Matching is one-to-one via matchpairs (Hungarian algorithm)
%       - Chamfer distance measures average nearest-neighbor distance
%         between ROI shapes
%       - Empty ROIs (all zeros) are assigned a large penalty (1e9)
%       - Lower scores indicate better matches
%
%   Example:
%       [pairs, costs] = matchROIs(x, y, 10);
%
%   See also: chamferDistance, matchpairs

    % assign a default value to the number of matches wanted
    if nargin < 3
        k = 5;
    end

    N1 = size(x, 3);
    N2 = size(y, 3);

    % compute pairwise similarity metrics
    scores = zeros(N1, N2);
    for i = 1:N1
        for j = 1:N2
            if nnz(x(:,:,i)) == 0 || nnz(y(:,:,j)) == 0
                scores(i,j) = 1e9;  % treat empty ROIs as maximally dissimilar
            else
                scores(i,j) = chamferDistance(x(:,:,i), y(:,:,j));
            end
        end
    end

    % compute the hungarian matching
    pairs = matchpairs(scores, 1e9);

    % get the costs
    pairCosts = zeros(size(pairs, 1), 1);   % fix: column vector, not [M,2]
    for n = 1:size(pairs, 1)
        pairCosts(n) = scores(pairs(n, 1), pairs(n, 2));
    end

    % sort best to worst
    [sortedCosts, order] = sort(pairCosts, 'ascend');
    sortedPairs = pairs(order, :);

    % get the top matches and return
    topK = min(k, size(sortedPairs, 1));
    topPairs = sortedPairs(1:topK, :);
    topCosts = sortedCosts(1:topK);

end

function d = chamferDistance(maskA, maskB)
% CHAMFERDISTANCE
% Computes symmetric Chamfer distance between two binary masks.
% Intuition: for every point in A, how far is the nearest point in B (and vice versa)?

    % pad both masks to same size so distances are comparable
    h = max(size(maskA,1), size(maskB,1));
    w = max(size(maskA,2), size(maskB,2));
    
    A = false(h, w);
    B = false(h, w);
    
    A(1:size(maskA,1), 1:size(maskA,2)) = maskA;
    B(1:size(maskB,1), 1:size(maskB,2)) = maskB;

    % ensure binary masks (logical) 
    A = A > 0;
    B = B > 0;

    % distance transforms
    % distB(p) = distance from pixel p to the nearest 'true' pixel in B
    % distA(p) = distance from pixel p to the nearest 'true' pixel in A
    distB = bwdist(B);
    distA = bwdist(A);

    % for every point in A, look up how far it is from B
    d1 = mean(distB(A));

    % for every point in B, look up how far it is from A
    d2 = mean(distA(B));

    % average both directions so it's not biased
    d = (d1 + d2) / 2;
end


function tensor = pairsToTensor(x, y, topPairs, topCosts)
% PAIRSTOTENSOR  Create a visualization tensor of matched ROI pairs.
%
%   tensor = PAIRSTOTENSOR(x, y, topPairs, topCosts)
%
%   Generates side-by-side visualizations of matched ROIs from two sets and
%   stacks them into a 3D tensor for playback (e.g., with MovieSlider).
%   Each frame shows one matched pair with its associated cost.
%
%   Inputs:
%       x, y      - HxWxN tensors of ROI images (e.g., from two days)
%
%       topPairs  - Kx2 array of matched ROI indices [i, j]
%                   (i from x, j from y)
%
%       topCosts  - Kx1 vector of matching costs corresponding to topPairs
%
%   Output:
%       tensor    - HxWxK uint8 tensor of grayscale frames
%                   Each slice tensor(:,:,n) visualizes one ROI pair
%
%   Notes:
%       - Each frame is rendered as a figure with two subplots:
%           left = ROI from x, right = ROI from y
%       - Matching cost is displayed in the title of the second subplot
%       - Frames are padded to a common size for consistent stacking
%       - Output is grayscale (uint8), suitable for fast visualization
%
%   Example:
%       ims = pairsToTensor(x, y, pairs, costs);
%       MovieSlider(ims);
%
%   See also: imagesc, getframe, MovieSlider

    k = size(topPairs, 1);
    frames = cell(k, 1);

    for n = 1:k
        imgX = x(:,:, topPairs(n,1));
        imgY = y(:,:, topPairs(n,2));

        fig = figure('Visible', 'off', 'Units', 'pixels', ...
             'Position', [0 0 800 400], 'Color', 'w');

        subplot(1,2,1);
        imagesc(imgX); axis image off; colormap gray;
        set(gca, 'Color', 'w');
        title(sprintf('x ROI %d', topPairs(n,1)));
        
        subplot(1,2,2);
        imagesc(imgY); axis image off; colormap gray;
        set(gca, 'Color', 'w');
        title(sprintf('y ROI %d  |  cost = %.4f', topPairs(n,2), topCosts(n)));

        % capture figure as image
        frame = getframe(fig);
        frames{n} = rgb2gray(frame.cdata);
        close(fig);
    end

    % pad all frames to the same size
    maxH = max(cellfun(@(f) size(f,1), frames));
    maxW = max(cellfun(@(f) size(f,2), frames));
    tensor = zeros(maxH, maxW, k, 'uint8');
    for n = 1:k
        f = frames{n};
        tensor(1:size(f,1), 1:size(f,2), n) = f;
    end
end