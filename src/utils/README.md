# Utilities

This folder contains reusable MATLAB helpers used by the pipelines, demos, and workspace scripts. The utilities cover data loading and reconstruction, preprocessing, denoising, PSTH calculation, and visualization of GraFT components.

## Folder Layout

```text
utils/
  misc/                  Loading, saving, and S/D reconstruction helpers
  plotting/              ROI coloring and reconstruction visualization tools
  preprocessing/         Baseline correction, motion correction, and denoising
  psth/                  Peri-stimulus response checks
```

## `misc`

### `load_raw.m`

Loads raw `.h5` files from a day directory into a `data` struct. It expects each file to contain a `/data` dataset, reads every fourth frame, and stores each file as `data.Fsim1`, `data.Fsim2`, and so on. It also stores the source directory and file listing in `data.dirname` and `data.files`.

This function uses HDF5 I/O and a `parfor` loop, so Parallel Computing Toolbox is expected for the parallel read.

### `saveDay.m`

Writes a movie tensor to an HDF5 file named `dayN.h5`, with the dataset stored at `/dayN`.

### `multSD.m`

Reconstructs a movie from GraFT spatial and temporal components. `S` is expected to be `W x H x N`, and `D` is expected to be `N x T`. The output is a `W x H x T` reconstructed movie.

## `preprocessing`

### `rollingBaselineDFF.m`

Computes a rolling baseline-normalized fluorescence trace. The baseline is estimated as the 10th percentile in a centered 150-sample window, then subtracted and normalized by a stabilized square-root baseline term.

### `preprocessing/denoising/denoiseCI.m`

Provides several denoising modes for calcium-imaging movies:

- `PCA`: low-rank reconstruction with a selected number of components.
- `timeFilt`: 1-D Gaussian filtering over time.
- `spaceFilt`: 2-D Gaussian filtering over space.
- `stFilt`: 3-D Gaussian filtering over space and time.

The filtering modes use valid convolution, so outputs can shrink along filtered dimensions.

### `preprocessing/denoising/denoisePCA.m`

Wraps PCA denoising for full movies or patch-based processing. The `patchPCA` mode processes non-overlapping `100 x 100` spatial patches and `10000`-frame time chunks.

### `preprocessing/motion-correction/motion_correct.m`

Runs NoRMCorre motion correction on each `FsimN` field in a `data` struct. For fresh motion correction, it saves a manifest and one shift file per input movie when `params.save_path` is provided. It can also reapply saved shifts from a previous run.

This function depends on NoRMCorre functions such as `NoRMCorreSetParms`, `normcorre`, and `apply_shifts`.

### `preprocessing/motion-correction/apply_motion_correction.m`

Applies previously saved NoRMCorre shifts from a motion-correction manifest to the `FsimN` fields in a `data` struct. This is a smaller helper for the shift-reuse path.

### `preprocessing/motion-correction/alignTrials.m`

Aligns multiple trials after within-movie motion correction. It uses the mean image of `Fsim1` as the reference, aligns later `FsimN` trials by normalized cross-correlation, translates them without wraparound, crops all aligned trials consistently, and concatenates them into `data.Fsim`.

### `preprocessing/motion-correction/alignTrialsOld.m`

Older trial-alignment implementation retained for reference. It chains pairwise alignments and uses circular shifts before cropping. The newer `alignTrials.m` is the active version.

## `psth`

### `getPSTH.m`

Computes a peri-stimulus time histogram from a movie by extracting a 40-frame window around each event frame, averaging across events, and then averaging across pixels. The returned trace spans 10 frames before through 29 frames after each event.

### `checkSignal.m`

Reconstructs a movie from GraFT `S` and `D` components using `multSD`, then calls `getPSTH` to summarize event-aligned activity.

## `plotting`

### `plotDifferentColoredROIS.m`

Renders a stack of ROI spatial components as a single RGB image with perceptually distinct colors. It supports per-ROI or global normalization, ROI size filtering, and custom aspect ratios.

### `plotDifferentColoredROIS2.m`

Variant of `plotDifferentColoredROIS.m` with a fixed hand-picked color palette. This is useful for controlled figure styling when the ROI count is small.

### `makeColorReconVid.m`

Builds a color reconstruction movie from raw movie data `X`, spatial components `S`, and temporal components `D`, then displays the raw and reconstructed movies side-by-side with `MovieSlider`.

### `distinguishable_colors.m`

Third-party color utility by Timothy E. Holy for selecting perceptually distinct RGB colors. It is used by ROI plotting functions and Suite2p/GraFT visualizations.

## Common Dependencies

Several utilities assume these external tools or MATLAB products are available:

- NoRMCorre for motion correction.
- GraFT or patchGraFT outputs for component analysis.
- `MovieSlider` for interactive movie viewing.
- Image Processing Toolbox for functions such as `normxcorr2`, `imtranslate`, `medfilt2`, `bwareaopen`, `bwdist`, `wiener2`, and `imadjust`.
- Parallel Computing Toolbox for `parfor`, `parpool`, and related functions.
- HDF5 support through MATLAB's `h5read`, `h5info`, `h5create`, and `h5write`.
