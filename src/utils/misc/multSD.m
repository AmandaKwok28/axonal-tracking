function mov = multSD(S, D)
% MULTSD Reconstruct a movie from spatial profiles and temporal traces.
%
%   mov = MULTSD(S, D) multiplies ROI spatial profiles by their temporal
%   activity traces to reconstruct a W-by-H-by-T movie.
%
%   Inputs:
%       S - W-by-H-by-N array of spatial profiles, where N is the number of
%           ROIs/components.
%       D - N-by-T matrix of temporal traces, where T is the number of
%           frames.
%
%   Output:
%       mov - W-by-H-by-T reconstructed movie.

    [w,h,n] = size(S);
    if size(D, 1) ~= n
        error('multSD:DimensionMismatch', ...
              'D must have one row for each spatial profile in S.');
    end

    tmp = reshape(S, [w * h, n]);
    mov = reshape(tmp * D, [w, h, size(D, 2)]);
    
end
