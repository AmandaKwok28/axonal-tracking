function psth = check_signal(S, D, targetFramePlane)
    % data has to have data.Fsim field
    % this function computes the psth from the reconstructed movie
    
    % reconstrcut S and D
    mov = multSD(S, D);

    % get average response
    psth = getPSTH(targetFramePlane, mov); 
    
end