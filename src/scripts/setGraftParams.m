% graft_params
%% Set algorithm parameters
% A full set of parameters and defaults is specified in the bottom of the
% GraFT main function (subfunction checkAllParameters()). These are some
% example parameters, however we find that

fprintf('Setting up parameters...')
params.lamCont       = 0.1;                                                % parameter to control how much to weigh the previous estimate (continuity term)
params.grad_type     = 'full_ls_cor';                                      % type of dictionary update
params.lamContStp    = 0.9;                                                % Decay rate of the continuation parameter
params.plot          = true;                                               % Set whether to plot intermediary variables
params.create_memmap = false;                                              
params.verbose       = 10;                                                 % Level of verbose output
params.normalizeSpatial = true;
params.nonneg           = true;

corr_kern.w_time     = 0;                                                  % Initialize the correlation kernel struct
corr_kern.reduce_dim = true;
corr_kern.corrType   = 'embedding';                                        % Set the correlation type to "graph embedding"

params.time_compression = 0.6;
params.max_learn = 1e3;
params.learn_eps = 0.05;

fprintf('done.\n')