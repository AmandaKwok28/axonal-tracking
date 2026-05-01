% RUNGRAFTTIMED Run GraFT or patchGraFT using workspace variables.
%
%   RUNGRAFTTIMED is a script for timing a GraFT run after the required
%   inputs have already been loaded into the MATLAB workspace. It prints the
%   start time, selected regularization parameters, finish time, and elapsed
%   duration, then leaves the learned components in S and D.
%
%   Required workspace variables:
%       data.Fsim - Movie to pass into GraFT or patchGraFT.
%       params    - GraFT parameter struct. This script prints
%                   params.lambda, params.lamForb, params.lamCont, and
%                   params.lamCorr, and passes the full struct into GraFT
%                   or patchGraFT.
%       corr_kern - Correlation kernel passed into GraFT or patchGraFT.
%       usePatch  - Logical flag. If true, run patchGraFT; otherwise, run
%                   GraFT on the full movie.
%
%   Created workspace variables:
%       S - Learned spatial components.
%       D - Learned temporal components.

% get the current time
startTime = datetime('now');

% extract the hour and minute
startHour = hour(startTime);
startMinute = minute(startTime);

fprintf('Function started at %02d:%02d\n', startHour, startMinute);

% start timer
tic;

% run graft
fprintf(...
    'Running with parameters lambda = %f, lamforb = %f, lamcont = %f, lamCorr = %f.\n', ...                                
    params.lambda, params.lamForb, params.lamCont, params.lamCorr);

if usePatch   
    % Learn the dictionary using patch-based code                                                         
    [S, D] = patchGraFT(data.Fsim,params.n_dict,[],corr_kern,params);      
else
    % Learn the dictionary (no patching - will be much more memory intensive and slower)                                                                                    
    [D, S, testMem] = GraFT(data.Fsim, [], corr_kern, params);               
end                                                             
        
fprintf('Finished running GraFT.\n')                            
datetime('now')                                                 
                                                                                                                                                                                            
% Get the end time                                              
endTime = datetime('now');                                      
endHour = hour(endTime);                                        
endMinute = minute(endTime);  

% Calculate the elapsed duration                                
elapsedDuration = endTime - startTime;                          
elapsedHours = hours(elapsedDuration);                          
elapsedMinutes = minutes(elapsedDuration) - 60 * floor(elapsedHours);                                                          
elapsedSeconds = seconds(elapsedDuration) - 3600 * floor(elapsedHours) - 60 * floor(elapsedMinutes);                           
                                                                
fprintf('Function ended at %02d:%02d\n', endHour, endMinute);   
fprintf('Elapsed time: %d hours, %d minutes, and %.2f seconds\n', floor(elapsedHours), floor(elapsedMinutes), elapsedSeconds);
