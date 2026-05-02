function dff = rollingBaselineDFF(d)
%ROLLINGBASELINEDFF Compute a baseline-normalized fluorescence trace.
%
%   dff = ROLLINGBASELINEDFF(d) estimates a rolling fluorescence baseline
%   for the input trace d, subtracts that baseline, and normalizes by a
%   stabilized square-root baseline term.
%
%   The baseline at each time point is the 10th percentile of a centered
%   150-sample window. Near the beginning and end of the trace, the window
%   is clipped to the available samples.
%
%   Input:
%       d   - Fluorescence trace.
%
%   Output:
%       dff - Baseline-subtracted, normalized fluorescence trace.

    w = 150;
    baseline = zeros(size(d));

    for i = 1:length(d)

        % get a window of 150 centered at time point i
        startIdx = max(1, i - floor(w/2));
        endIdx   = min(length(d), i + floor(w/2));

        % get the 10th percentile of that window to get the baseline flourescence of this window
        baseline(i) = prctile(d(startIdx: endIdx), 10);
    end

    % subtract the baseline from the trace
    % this removes slow changes in brightness, motion artifacts / bleaching trends
    % the division is to stabilize the trace. Raw flourescence noise typically scales with signal
    % so we divide by a value proportional to the standard deviation of the baseline to model
    % poisson like noise. The 0.4 is an empirical value used for numerical stability
    dff = (d - baseline) ./ (sqrt(baseline) + 0.4);

end
