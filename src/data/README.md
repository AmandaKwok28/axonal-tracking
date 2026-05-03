# Data

This folder contains saved example data used by the demos and exploratory matching workflows. These files are committed so that figures and small analyses can be regenerated without requiring access to the full raw imaging archive.

## Contents

### `day1GraFT.mat`

Saved GraFT output for day 1. It is used by `../pipelines/suite2pMatch.m` and is expected to contain GraFT spatial and temporal components, including variables such as `S` and `D`.

### `day1Metadata.mat`

Metadata for the day 1 example data. `suite2pMatch.m` uses this file for display context, including the GraFT-oriented mean image.

### `suite2pROIs.mat`

Suite2p ROI output for the same example data. `suite2pMatch.m` expects Suite2p-style variables such as `ops.meanImg`, `stat`, `iscell`, and `spks` so it can orient the Suite2p image, extract ROI coordinates, and compare Suite2p traces with a selected GraFT trace.

### `GraFTFigCropped.mat`

Cropped GraFT figure data used for figure generation or display examples. The figure-generation code expects saved GraFT spatial components and temporal traces. `../demos/makeGraFTFig.m` currently loads `GraFTFig.mat`, so point that demo at this file if using the committed cropped sample.

## Usage

Most MATLAB code in this repository loads data relative to the current working directory. If a script expects one of these files, either run it from `src/data` or update the script to use an explicit path.

For example:

```matlab
cd src/data
addpath(genpath('..'))
suite2pMatch
```

## Notes

Large raw `.h5` imaging files and generated analysis outputs should generally stay outside the repository. Keep only small, stable examples here when they are needed to reproduce demos or document expected file formats.
