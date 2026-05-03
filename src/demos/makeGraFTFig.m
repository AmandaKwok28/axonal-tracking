function makeGraFTFig()
% MAKEGRAFTFIG  Generate publication-style figure from saved GraFT outputs.
%
%   MAKEGRAFTFIG()
%
%   Loads spatial (S) and temporal (D) components from 'GraFTFig.mat',
%   selects a predefined subset of ROIs, applies light denoising and
%   normalization, and generates:
%       (1) spatial ROI visualization
%       (2) corresponding temporal traces
%
%   Data Source:
%       - Expects 'GraFTFig.mat' in the current directory
%       - File must contain:
%           S : HxWxK spatial components
%           D : TxK temporal traces
%       - GraFT parameters:
%           - lambda = 2
%           - other hyperparameters were the default
%
%   Processing Steps:
%       1. Subset selection (hardcoded ROI indices)
%       2. Temporal normalization via mdff (baseline correction)
%       3. Spatial denoising and enhancement:
%           - Wiener filtering
%           - Contrast stretching (imadjust)
%           - Median filtering
%       4. Trace normalization (99th percentile scaling)
%
%   Visualization:
%       - Spatial ROIs shown with distinct colors
%       - Temporal traces vertically offset for readability
%
%   Notes:
%       - Designed for figure generation (not a general pipeline)
%       - ROI subset and preprocessing are tuned for visual clarity
%
%   Example:
%       makeGraFTFig()
%
%   See also: rollingBaselineDFF, wiener2, imadjust, plotDifferentColoredROIS2

    % load day data
    data = load('GraFTFig.mat');
    D = data.D;
    S = data.S;

    % get the relevant subset
    subset = [15,12,6,17];
    D = D(:, subset);
    S = S(:,:, subset);

    % normalize + drift correct the signal
    trace = rollingBaselineDFF(D);

    % denoise and sharpen the images to make them more clear
    masks = zeros(size(S));

    for i = 1:size(S, 3)
        filtered = wiener2(S(:,:,i), [2,2]);                        % denoise      
        tmp = imadjust(filtered, stretchlim(filtered), [], 2);      % sharpen
        masks(:,:,i) = medfilt2(tmp, [2,2]);                        % median filter 
    end

    figure;

    % display spatial profiles
    subplot(2,2,1);
    plotDifferentColoredROIS2(masks);
    title('ROIs');

    % display mean image
    subplot(2,2,2);
    imagesc(mean(S,3)); axis off; axis square;
    title('Mean of all Spatial Profiles')

    % display traces
    subplot(2,2,3:4);
    plot(bsxfun(@plus, trace/prctile(trace(:), 99), 0:(size(trace,2) - 1)));
    xlim([0 40809]);
    title('Temporal Traces');

end