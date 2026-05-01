function data = preprocess(data, params, opts)
% this file runs the entire pre-processing pipeline once through

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