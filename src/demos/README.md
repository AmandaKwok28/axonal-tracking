# Demos

This folder contains short MATLAB examples for running the analysis workflow and regenerating figure-style outputs. These files are intended as runnable references, but local paths and expected data files may need to be adjusted before use.

## Contents

### `demo.m`

Example end-to-end workflow for a GraFT run. It shows the intended order for setting parameters, configuring compute resources, preprocessing a day of imaging data, and launching the timed GraFT script.

The script runs:

1. `setParams`
2. `setCores.m`
3. `setGraFTParams.m`
4. `preprocess`
5. `runGraFTTimed.m`

Current assumptions:

- The `day` variable is set to a local CIS path and should be changed for another machine or dataset.
- `params.save_path` points to the same day folder for motion-correction outputs.
- The preprocessing call expects a loaded data struct, but the current example passes the day path directly. Treat this as a workflow sketch unless updated to call `load_raw(day)` first.
- External GraFT, patchGraFT, NoRMCorre, and project utilities must be on the MATLAB path.

### `makeGraFTFig.m`

Generates a figure from saved GraFT outputs. It loads spatial components `S` and temporal traces `D` from `GraFTFig.mat` in the current working directory, selects a hardcoded subset of ROIs, baseline-corrects the traces, denoises and enhances the spatial masks, then plots:

- colored ROI spatial profiles,
- the mean spatial image,
- vertically offset temporal traces.

The function uses `rollingBaselineDFF`, `plotDifferentColoredROIS2`, and Image Processing Toolbox functions such as `wiener2`, `imadjust`, and `medfilt2`. The current code loads `GraFTFig.mat`; the committed sample file in `src/data` is named `GraFTFigCropped.mat`, so update the load path or filename before running this demo with the included data.

## Data Expectations

The demos rely on small saved example outputs rather than raw acquisition files. Data used by the demos is documented in `../data/README.md`. When running a demo, either start MATLAB in the folder containing the expected `.mat` files or change the load paths inside the demo.

## Running

From the repository root, add the source tree to the MATLAB path:

```matlab
addpath(genpath('src'));
```

Then run a demo directly:

```matlab
makeGraFTFig
```

or open `demo.m` and update the dataset path before stepping through the workflow.
