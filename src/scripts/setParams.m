% sets up basic params needed to run graft

saveDir  = '.';             % Set the path where the output should be saved to
usePatch = false;           % Select if patchGraFT or regular GraFT should be used. For bigger field-of-views (>150 pix X 150 pix), patchGraFT is recommended

params.lambda    = 30;      % Sparsity parameter
params.lamForb   = 30;      % parameter to control how much to weigh extra time-traces
params.lamCorr   = 0.1;     % Parameter to prevent overly correlated dictionary elements

params.n_dict    = 40;      % Choose how many components (per patch) will be initialized. Note: the final number of coefficients may be less than this due to lack of data variance and merging of components.
params.patchSize = 100;     % Choose the size of the patches to break up the image into (squares with patchSize pixels on each side)

Xsel = 151:350;             % Can sub-select a portion of the full FOV to test on a small section before running on the full dataset
Ysel = 101:300;                                    
params.motion_correct = true;

