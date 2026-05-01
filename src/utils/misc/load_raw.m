function data = load_raw(fp)
% this function loads raw data from a given filepath
% expecting file path like: '/cis/home/akwok1/my_documents/day3' with .h5 files

    arguments
        fp (1,:) char
    end

    % enter the folder with all the .h5 files
    fprintf('Loading raw data from %s ...\n', fp);

    data.dirname = fp;
    data.files   = dir(fullfile(data.dirname,'*.h5'));   
    n = numel(data.files); 

    if n == 0
        error('No .h5 files found in the specified directory.');
    end
    
    % preallocate data
    tmp = cell(1, n);
    files = data.files;

    % get dims first
    dims_all = cell(1, n);
    fnames = cell(1, n);
    for i = 1:n
        fnames{i} = fullfile(fp, files(i).name);
        hinfo = h5info(fnames{i}, '/data');
        dims_all{i} = hinfo.Dataspace.Size;
    end


    % parallel read
    parfor i = 1:n
        dims = dims_all{i};
        fname = fnames{i};
        
        % h5read(filename, datasetname, start, count, stride)
        % for each dim, the start is the first frame = [1, 1, 1]
        % there are n number of values in each dim = [dims(1) dims(2) dims(3)]
        % we want every 4th frame = [1 1 4]
        tmp{i} = h5read(fname, '/data', ...
                        [1, 1, 1], ...
                        [dims(1) dims(2) ceil(dims(3)/4)], ...
                        [1 1 4]);
    end

    for i = 1:n
        data.(['Fsim' num2str(i)]) = tmp{i};
    end
                                                           
    fprintf('...done\n')

end