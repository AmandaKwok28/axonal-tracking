function psth = checkSignal(S, D, targetFramePlane)
% CHECKSIGNAL Compute a PSTH from reconstructed GraFT components.
%
%   psth = CHECKSIGNAL(S, D, targetFramePlane) reconstructs a movie from
%   spatial components S and temporal traces D, then computes the
%   peri-stimulus time histogram aligned to the event frames in
%   targetFramePlane.
%
%   Inputs:
%       S                - W-by-H-by-N array of spatial components.
%       D                - N-by-T matrix of temporal traces.
%       targetFramePlane - Vector of event frame indices used for PSTH
%                          alignment.
%
%   Output:
%       psth             - Mean response trace returned by getPSTH.
    
    % reconstrcut S and D
    mov = multSD(S, D);

    % get average response
    psth = getPSTH(targetFramePlane, mov); 
    
end
