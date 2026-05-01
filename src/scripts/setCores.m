% Set up paths & misc startups
addpath(genpath('.'))               % Add all the files in the repo
ncores       = 10;                  % feature('numcores'); sets the number of cores
core_percent = 1;                   % Sets the percent of cores to use
if isempty(gcp('nocreate'))
    parpool(ceil(core_percent*ncores),'IdleTimeout',5000);      % If no parpool, make one
end

warning(sprintf('Using %d cores for parpool. Change var core_percent above if necessary',ceil(core_percent*ncores)));
RandStream.setGlobalStream(RandStream('mt19937ar'));
