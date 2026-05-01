function saveDay(day, n)
% SAVEDAY Save a day movie to an HDF5 file.
% 
%   SAVEDAY(day, n) saves the W-by-H-by-T movie day to dayN.h5, where N is
%   the value of n. The dataset inside the file is named /dayN.
%
%   Inputs:
%       day - W-by-H-by-T movie array to save.
%       n   - Day number used to build the output file and dataset name.

    name = ['day' num2str(n)];
    fp = [name '.h5'];
    dataset = ['/' name];

    h5create(fp, dataset, size(day), 'Datatype', class(day));
    h5write(fp, dataset, day);
    disp('successfully saved');
end
