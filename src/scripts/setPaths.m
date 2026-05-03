function setPaths()
% SETPATHS  Add project root and all subfolders to MATLAB path.
%
%   SETPATHS()
%
%   Locates this file, infers the project root by moving up the directory
%   tree, and recursively adds all folders under the root to the MATLAB path.
%   Enables calling project functions from any working directory.
%
%   Note:
%       Assumes the project root is two levels above this file.

    thisFile = mfilename('fullpath');
    root = fileparts(fileparts(thisFile));
    addpath(genpath(root));
end