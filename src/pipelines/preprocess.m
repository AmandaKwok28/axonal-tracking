function data = preprocess(data, params, opts)
% PREPROCESS  Run full preprocessing pipeline for imaging data.
%
%   data = PREPROCESS(data, params)
%   data = PREPROCESS(data, params, opts)
%
%   Applies motion correction, trial alignment, denoising, optional variance
%   masking, and normalization to imaging data stored in a struct. Designed
%   for Fsim-style tensors (HxWxT).
%
%   Inputs:
%       data   - Struct containing imaging data fields (e.g., Fsim, Fsim1, ...)
%
%       params - Struct of parameters used by preprocessing steps
%                (e.g., motion correction settings, save_path)
%
%       opts   - (optional struct with fields)
%           pth     : (char, default = '')
%                     Path to directory containing precomputed motion
%                     correction shifts. If provided, skips recomputing
%                     motion correction and applies saved shifts.
%
%           varMask : (logical, default = true)
%                     If true, suppresses low-variance pixels using a global
%                     threshold on per-pixel standard deviation.
%
%   Output:
%       data   - Struct with processed imaging data (same structure as input)
%
%   Pipeline:
%       1. Motion correction
%           - Load and apply precomputed shifts if opts.pth is provided
%           - Otherwise compute shifts via motion_correct()
%
%       2. Trial alignment
%           - Aligns trials temporally (alignTrials)
%
%       3. Denoising
%           - PCA-based denoising (denoiseCI)
%
%       4. Variance masking (optional)
%           - Removes low-variance pixels (std < 3 * mean std)
%
%       5. Normalization
%           - Zero-centers over time
%           - Scales by 90th percentile of absolute values
%
%   Notes:
%       - Assumes imaging data is stored in fields named Fsim, Fsim1, Fsim2, etc.
%       - Normalization is robust to outliers via percentile scaling
%       - Variance masking helps suppress background noise but may remove
%         weak signals if threshold is too aggressive
%
%   Example:
%       % First run (compute and save motion correction)
%       params.save_path = dayPath;
%       data = preprocess(data, params);
%
%       % Reuse saved motion correction
%       data = preprocess(data, params, pth=dayPath);
%
%   See also: motion_correct, apply_shifts (in NormCorre documentation), alignTrials, denoiseCI

    % error handling
    arguments
        data (1,1) struct
        params (1,1) struct
        opts.pth (1, :) char = ''   % default value for optional input
        opts.varMask (1, :) logical = true
    end

    % if a path is provided, load pre-computed motion correction shifts
    if ~isempty(opts.pth)
        % get working directory and apply the corresponding shifts to files
        fprintf('Applying pre-computed shifts from %s\n', opts.pth);
        
        % time to get a sense of speedup
        t = tic;

        mc = load(fullfile(opts.pth, 'motion_correction_manifest.mat'));
        manifest = mc.manifest;
        n = numel(manifest.files);
        for i = 1:n
            shiftFile = fullfile(opts.pth, manifest.shift_files{i});
            S = load(shiftFile);   % loads shifts, options
            F = data.(sprintf('Fsim%d', i));
            Fcorr = apply_shifts(F, S.shifts, S.options, S.col_shifts);
            data.(sprintf('Fsim%d', i)) = Fcorr;
        end

        % output timing info
        elapsed = toc(t);
        d = seconds(elapsed);
        h = floor(hours(d));
        m = floor(minutes(d) - 60*h);
        msg = 'Motion correction took %d hour(s), %d minute(s).\n';
        fprintf(msg, h, m);

    else 
        % motion correct
        params.motion_correct = true;
        data = motion_correct(data, params);
    end

    % debug: save the meanIm to see what's going on with the trial alignment
    % meanIm = mean(data.Fsim, 3);
    % save(fullfile(params.save_path, 'meanIm.mat'), 'meanIm');
    
    % align trials
    fprintf('aligning trials...\n')
    data = alignTrials(data);

    % denoise
    fprintf('denoising...\n');
    data.Fsim = denoiseCI(double(data.Fsim), 'PCA', 50);
    fprintf('denoising done.\n');

    % standardize
    if opts.varMask
        fprintf('variance masking...\n');
        stds = std(data.Fsim , 0, 3);
        stdev = stds(:);
        mstd = mean(stdev);
        mask = stds < 3*mstd;
        data.Fsim = bsxfun(@times, data.Fsim, mask);
        fprintf('variance masking done.\n');
    end
    
    % normalize based on dynamic range threshold
    fprintf('normalizing...\n');
    data.Fsim = data.Fsim - mean(data.Fsim, 3);
    p90 = prctile(abs(data.Fsim(:)), 90);
	data.Fsim = data.Fsim / p90;
    fprintf('normalizing done.\n');

end

