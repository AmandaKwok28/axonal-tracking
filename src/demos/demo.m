% set up parameters
run('setParams');           % creates the params struct
run('setCores.m');          % sets number of cores
run('setGraFTParams.m');    % adds fields to params that are specific to graft hyperparameters

% load day
day = '/cis/home/akwok1/my_documents/day1';     % my example path from CIS
params.save_path = day;
day = preprocess(day, params);                  % run preprocessing on the data

% if you want to re-use shifts from previous preprocessing run
% day = preprocess(day, params, pth=day);    

% run graft
run('runGraFTTimed.m');


