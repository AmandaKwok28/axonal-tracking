function psth = getPSTH(targetFramePlane, mov)
    % GETPSTH Compute the peri-stimulus time histogram for a movie.
    %
    %   psth = GETPSTH(targetFramePlane, mov) extracts frames around each
    %   target event frame in targetFramePlane, averages the event-aligned
    %   movie across events, then averages across pixels to return a
    %   frame-by-frame response trace.
    %
    %   Inputs:
    %       targetFramePlane - vector of event frame indices to align to.
    %       mov              - W-by-H-by-T movie array, where T is time.
    %
    %   Output:
    %       psth             - 1-by-40 vector containing the mean response
    %                          from 10 frames before each event through
    %                          29 frames after each event.

    [w,h,T] = size(mov);
    avg_mov = zeros(w,h,40);

    for t = -10:29
        idx = targetFramePlane + t;

        % only keep valid indices
        idx = idx(idx >= 1 & idx <= T);

        % idx is a vector of indices. we're taking an average over all events
        % at time event + t
        avg_mov(:,:,t+11) = mean(mov(:,:,idx), 3);
    end

    psth = mean(mean(avg_mov, 1), 2);
    psth = squeeze(psth)';

end
