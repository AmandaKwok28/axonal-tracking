function X = denoisePCA(X, dSel, dOpt)
%  DENOISEPCA Denoise a calcium imaging movie with PCA in full or patches over time.
%
%   X = DENOISEPCA(X, dSel, dOpt) applies PCA-based denoising to the
%   W-by-H-by-T movie X. The denoised movie is returned in X.
%
%   Inputs:
%       X    - W-by-H-by-T calcium imaging movie.
%       dSel - Denoising method:
%              'PCA'      low-rank reconstruction of the whole movie.
%              'patchPCA' low-rank reconstruction in non-overlapping
%                         100-by-100 spatial patches and 10000-frame time
%                         chunks.
%       dOpt - Number of singular values/components to keep.
%
%   Output:
%       X    - Denoised movie with the same size as the input movie.

    if strcmp(dSel, 'PCA')
        X = denoiseCI(X, 'PCA', dOpt);
    elseif strcmp(dSel, 'patchPCA')
        sizeX = size(X);
        patchSize = 100;
        timeSize = 10000;
        denoisedX = zeros(size(X), 'like', X);

        for i = 1:patchSize:sizeX(1)
            for j = 1:patchSize:sizeX(2)
                for k = 1:timeSize:sizeX(3)
                    iEnd = min(i + patchSize - 1, sizeX(1));
                    jEnd = min(j + patchSize - 1, sizeX(2));
                    kEnd = min(k + timeSize - 1, sizeX(3));

                    patch = X(i:iEnd, j:jEnd, k:kEnd);
                    nComponents = min(dOpt, min([numel(patch(:,:,1)), size(patch, 3)]));
                    denoisedX(i:iEnd, j:jEnd, k:kEnd) = denoiseCI(patch, 'PCA', nComponents);
                end
            end
        end

        X = denoisedX;
    else
        warning('Bad option, skipping denoising...\n')
    end
end
