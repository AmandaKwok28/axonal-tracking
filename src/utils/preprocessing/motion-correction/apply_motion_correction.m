function data = apply_motion_correction(data, pth) 
% function to apply the pre-computed shifts from motion correction
% this assumes you ran motion_correct.m located at /src/piplines/motion_correct.m
% because it relies on the outputed shifts

    if ~isempty(pth) 
        fprintf('Applying pre-computed shifts from %s\n', pth);

        t = tic;

        mc = load(fullfile(pth, 'motion_correction_manifest.mat'));
        manifest = mc.manifest;
        n = numel(manifest.files);
        for i = 1:n
            shiftFile = fullfile(pth, manifest.shift_files{i});
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
    end

end