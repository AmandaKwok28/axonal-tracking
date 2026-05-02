# Axonal Tracking Analysis

This repository collects the analysis code I have developed and used over the last several years for axonal tracking work in the lab. The goal is to keep the project organized, documented, and easy to hand off to future lab members.

It is not meant to be a sealed software package. It is a working research codebase: scripts, utilities, preprocessing steps, plotting tools, and notes that document how the analyses were run and how figures can be regenerated.

## Repository Layout

```text
src/
  data/          Notes about sample or local data used by demos and figures
  demos/         Short scripts for reproducing figures or example analyses
  pipelines/     Higher-level workflows that connect multiple processing steps
  scripts/       Workspace-based scripts for common analysis runs
  utils/         Reusable MATLAB functions grouped by analysis task
todo.md          Current cleanup and handoff tasks
```

The `src/utils` folder is split by purpose:

```text
utils/
  misc/                  Loading, saving, and small reconstruction helpers
  plotting/              Visualization and ROI coloring utilities
  preprocessing/         Motion correction, denoising, baseline correction
  psth/                  PSTH and signal-checking functions
```

## Typical Workflow

The main analysis flow is roughly:

1. Load calcium imaging data, usually from HDF5 files.
2. Apply or reuse motion correction.
3. Align trials.
4. Denoise the movie, often with PCA-based methods.
5. Normalize and optionally mask low-variance regions.
6. Run GraFT or patchGraFT to estimate spatial and temporal components.
7. Reconstruct signals, compute PSTHs, and generate figures.

The current preprocessing entry point is:

```matlab
data = preprocess(data, params);
```

Some scripts, especially in `src/scripts`, assume that required variables already exist in the MATLAB workspace. This is intentional for long-running analysis sessions where data, parameters, and intermediate results are loaded once and reused. Those scripts should document their required workspace variables at the top of the file.

## Important Files

- `src/pipelines/preprocess.m` runs the main preprocessing sequence: motion correction, trial alignment, denoising, variance masking, and normalization.
- `src/scripts/setParams.m` and `src/scripts/setGraftParams.m` define commonly used parameter settings.
- `src/scripts/runGraftTimed.m` runs GraFT or patchGraFT from workspace variables and reports runtime.
- `src/utils/preprocessing/denoising/denoiseCI.m` contains PCA and Gaussian filtering denoising utilities.
- `src/utils/preprocessing/motion-correction/` contains motion correction and trial alignment code.
- `src/utils/psth/` contains helpers for reconstructing signals and computing PSTHs.
- `src/utils/plotting/` contains plotting utilities used for ROI and reconstruction figures.

## Data

Large raw and processed imaging files should not be committed to this repository. Keep data in the lab storage location or another agreed-upon external location, and document where it lives. Small sample data or metadata needed to reproduce demos can be described in `src/data/README.md`.

When adding a new analysis script, include enough information to identify:

- Which dataset or day it was run on.
- Which parameters were used.
- Which intermediate files are expected.
- Which output files or figures it creates.

## MATLAB Path

Before running analyses, add the relevant source folders to the MATLAB path. From the repository root:

```matlab
addpath(genpath('src'));
```

Some functions depend on external lab code, including GraFT, patchGraFT, and motion correction helpers. If those are not already on the MATLAB path, add them before running the scripts in this repository.

## Conventions

- Functions in `src/utils` should be reusable and should include a MATLAB help block directly under the function signature.
- Scripts in `src/scripts` may rely on workspace variables, but they should state those assumptions clearly at the top.
- Pipelines in `src/pipelines` should connect documented steps and avoid hiding important parameters.
- Demos should be short and reproducible, with enough comments to explain what figure or result they regenerate.
- Avoid committing large `.h5`, `.mat`, video, or generated result files unless there is a specific reason to keep a small example in version control.

## Handoff Notes

This repository is intended to be readable by someone who did not write the original analysis. When updating it, prefer clear file names, short comments where the reasoning matters, and docstrings that explain inputs, outputs, and workspace assumptions. The most useful future version of this repo is not the cleverest one; it is the one where the next person can tell what was run, why it was run, and how to run it again.
