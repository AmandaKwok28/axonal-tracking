# Scripts

This folder contains workspace-oriented MATLAB scripts for configuring and running GraFT analyses. Unlike functions, these scripts intentionally create or consume variables in the current MATLAB workspace, so they are most useful during interactive analysis sessions or as templates for batch scripts.

## Contents

### `setPaths.m`

Adds the project source tree to the MATLAB path. It locates itself with `mfilename('fullpath')`, moves up to the `src` folder, and calls `addpath(genpath(root))`.

Run this first when starting from a clean MATLAB session:

```matlab
setPaths
```

### `setCores.m`

Configures parallel execution for long-running analysis. It adds the current directory recursively to the path, starts a parallel pool if none exists, sets the random stream, and prints the number of cores being used.

Workspace variables created or used:

- `ncores`: configured core count.
- `core_percent`: fraction of cores to use.

This script uses Parallel Computing Toolbox functions such as `gcp` and `parpool`.

### `setParams.m`

Defines baseline GraFT and preprocessing parameters. It creates `saveDir`, `usePatch`, `params`, `Xsel`, and `Ysel` in the workspace.

The parameters include:

- GraFT sparsity and regularization values: `lambda`, `lamForb`, and `lamCorr`.
- Dictionary and patch settings: `n_dict` and `patchSize`.
- Optional field-of-view subsets: `Xsel` and `Ysel`.
- `params.motion_correct`, which controls whether preprocessing should run motion correction.

Adjust this file before running a new dataset if the save directory, patch mode, ROI count, or regularization values should change.

### `setGraFTParams.m`

Adds more detailed GraFT hyperparameters to the existing `params` struct and creates the `corr_kern` struct used by GraFT or patchGraFT.

Configured options include:

- Continuation and dictionary update settings.
- Plotting, verbosity, memory-map, nonnegativity, and spatial normalization flags.
- Correlation kernel settings for graph embedding.
- Time compression and learning limits.

Run this after `setParams.m`, because it assumes `params` already exists.

### `runGraFTTimed.m`

Runs either `GraFT` or `patchGraFT` on `data.Fsim`, prints selected hyperparameters, and reports elapsed runtime. The learned components are left in the workspace as `S` and `D`.

Required workspace variables:

- `data.Fsim`: preprocessed movie.
- `params`: GraFT parameter struct.
- `corr_kern`: correlation-kernel struct.
- `usePatch`: logical flag selecting `patchGraFT` or full `GraFT`.

Created workspace variables:

- `S`: learned spatial components.
- `D`: learned temporal components.
- `testMem`: created by the full `GraFT` branch.

## Usage Pattern

A typical interactive session looks like:

```matlab
setPaths
run('setParams.m')
run('setCores.m')
run('setGraFTParams.m')

data = load_raw(dayPath);
params.save_path = dayPath;
data = preprocess(data, params);

run('runGraFTTimed.m')
```

These scripts depend on functions elsewhere in `src`, plus external GraFT, patchGraFT, and MATLAB parallel-computing functionality.
