function data = motion_correct(data, params, pth)
    arguments
        data (1,1) struct
        params (1,1) struct   % optionally can contain a save_path field
        pth (1,:) char = '';
    end

    if isempty(pth)
        assert(isfield(params, 'motion_correct'), ...
            'params.motion_correct field is required');

        % check params
        if ~params.motion_correct
            return
        end

        fprintf('Performing motion correction...\n');

        % keep track of timing for my information
        t = tic;

        % extract data
        n = numel(data.files);
        tmp = cell(1, n);

        % keep track of the file mapping for reconstruction later
        manifest = struct();
        manifest.files = data.files;
        manifest.shift_files = cell(1, n);
        for i = 1:n
            tmp{i} = data.(['Fsim' num2str(i)]);
            fname = sprintf('motion_correction_shifts_%02d.mat', i);
            manifest.shift_files{i} = fname;
        end

        % run motion correction in parallel
        all_shifts = cell(1, n);
        all_options = cell(1, n);
        all_colshifts = cell(1, n);
        if n == 1
            [Fsim, shifts, options, col_shift] = motion_correct_single( tmp{1});
            tmp{1} = Fsim;
            all_shifts{1} = shifts;
            all_options{1} = options;
            all_colshifts{1} = col_shift;
        else
            parfor i = 1:n
                [Fsim, shifts, options, col_shift] = motion_correct_single(tmp{i});
                tmp{i} = Fsim;
                all_shifts{i} = shifts;
                all_options{i} = options;
                all_colshifts{i} = col_shift;
            end
        end

        % reassign data
        for i = 1:n
            data.(['Fsim' num2str(i)]) = tmp{i};
        end

        if isfield(params, 'save_path') && ~isempty(params.save_path)
            % save the mapping of fz017 files to the motion correction shift files
            file = fullfile(params.save_path, 'motion_correction_manifest.mat');
            save(file, 'manifest');

            % save the shift files
            for i = 1:n
                fname = fullfile(params.save_path, manifest.shift_files{i});
                shifts = all_shifts{i};
                options = all_options{i};
                col_shifts = all_colshifts{i};
                save(fname, 'shifts', 'options', 'col_shifts');
            end
        end

        fprintf('Motion correction complete.\n');
        elapsed = toc(t);
        d = seconds(elapsed);
        h = floor(hours(d));
        m = floor(minutes(d) - 60*h);
        msg = 'Motion correction took %d hour(s), %d minute(s).\n';
        fprintf(msg, h, m);
    
    else

        % use precomputed shifts
        fprintf('Applying pre-computed shifts from %s\n', pth);
        
        % time to get a sense of speedup
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


function [Fsim, shifts, options, col_shift] = motion_correct_single(Fsim)
    if ndims(Fsim) ~= 3
        error('Input data must be 3D (height x width x time)');
    end

    try 
        options_rigid = NoRMCorreSetParms(...
            'd1', size(Fsim, 1), ...
            'd2', size(Fsim, 2), ...
            'bin_width', 50, ...
            'max_shift', 10, ...            
            'us_fac', 2, ...                % subpixel interpolation, doesn't work with us_fac = 1
            'iter', 5, ...
            'init_batch', 200);             % trying 500 to see if that makes a better template...

        [Fsim, shifts, ~, options, col_shift] = normcorre(Fsim, options_rigid);

    catch ME
        error(['Motion correction failed. ' ...
        'Ensure NoRMCorre is installed from https://github.com/flatironinstitute/NoRMCorre and on path. \n%s'],...
        ME.message);
    end
end
