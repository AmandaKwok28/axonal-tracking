# Pipelines

This folder contains higher-level MATLAB workflows that connect multiple utility functions into analysis steps for axonal tracking. These files are meant to be called after the project folders and external dependencies have been added to the MATLAB path.

## Contents

### `preprocess.m`

Runs the main preprocessing workflow for imaging movies stored in a `data` struct. The expected movie fields are named `Fsim1`, `Fsim2`, and so on, with each field containing an `H x W x T` tensor.

The pipeline:

1. Performs NoRMCorre-based motion correction, or reapplies saved shifts when a previous motion-correction path is provided.
2. Aligns trials using mean-image cross-correlation.
3. Denoises the concatenated movie with PCA-based denoising.
4. Optionally applies a variance mask to suppress low-variance pixels.
5. Zero-centers and percentile-normalizes the final `data.Fsim` movie.

Important inputs:

- `data`: struct containing imaging movies and, for fresh motion correction, a `files` field describing the source files.
- `params`: struct containing preprocessing and output settings. `params.save_path` is used to save or find motion-correction manifests and shift files.
- `opts.pth`: optional path to a folder containing saved motion-correction shifts.
- `opts.varMask`: optional logical flag controlling the low-variance mask.

Main dependencies include `motion_correct`, `apply_shifts` from NoRMCorre, `alignTrials`, and `denoiseCI`.

### `track.m`

Matches GraFT ROIs between two days using symmetric Chamfer distance and one-to-one assignment with MATLAB's `matchpairs`. It loads `S` spatial-component tensors from two `.mat` files, optionally cleans each ROI into a binary mask, computes pairwise distances, and displays matched pairs with `MovieSlider`.

The function returns:

- `topPairs`: matched ROI index pairs.
- `topCosts`: Chamfer distances for the returned pairs.
- `scores`: the full pairwise distance matrix.
- `ims`: image frames used for match visualization.

The helper functions inside this file handle ROI cleanup, Chamfer distance calculation, matching, and visualization-frame generation. Image Processing Toolbox functions such as `medfilt2`, `bwareaopen`, and `bwdist` are used.

### `suite2pMatch.m`

Compares one selected GraFT ROI against candidate Suite2p ROIs. It loads saved GraFT, Suite2p, and metadata `.mat` files from the current working directory, aligns the Suite2p mean image orientation to the GraFT orientation, computes rolling-baseline corrected traces, scores candidate ROIs by lag-limited normalized cross-correlation, and plots the top matches.

Expected files in the current working directory:

- `day1GraFT.mat`
- `suite2pROIs.mat`
- `day1Metadata.mat`

This script-style function is currently tuned for a hardcoded GraFT ROI and local sample data. It is best treated as an exploratory matching/visualization workflow rather than a general-purpose API.

## Typical Use

Start MATLAB from the repository or add `src` recursively to the path:

```matlab
addpath(genpath('src'));
```

Then load raw data, set parameters, and call the relevant pipeline. For example:

```matlab
data = load_raw(dayPath);
params.save_path = dayPath;
data = preprocess(data, params);
```

External dependencies used by these pipelines include NoRMCorre, GraFT or patchGraFT outputs, `MovieSlider`, and standard MATLAB toolboxes for image processing, statistics, optimization, parallel computing, and HDF5 I/O.
