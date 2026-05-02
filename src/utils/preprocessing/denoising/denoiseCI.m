function X = denoiseCI(X, dSel, dOpt)
% DENOISECI Denoise a calcium imaging movie with PCA or Gaussian filtering.
%
%   X = DENOISECI(X, dSel, dOpt) applies the denoising method specified by
%   dSel to the W-by-H-by-T movie X. The denoised movie is returned in X.
%
%   Inputs:
%       X    - W-by-H-by-T calcium imaging movie.
%       dSel - Denoising method:
%              'PCA'       low-rank reconstruction using dOpt components.
%              'timeFilt'  1-D Gaussian filter across time.
%              'spaceFilt' 2-D Gaussian filter across space.
%              'stFilt'    3-D Gaussian filter across space and time.
%       dOpt - Method option. For 'PCA', the number of singular values to
%              keep. For filter methods, the Gaussian kernel width.
%
%   Output:
%       X    - Denoised movie. Filtering uses 'valid' convolution, so the
%              output can be smaller than the input along filtered
%              dimensions.

if strcmp(dSel,'PCA')
    sizeX   = size(X);
    X       = reshape(X, [sizeX(1)*sizeX(2), sizeX(3)]);
    [U,S,V] = svds(X,dOpt);
    X       = U*S*(V.');                                                             
    X       = reshape(X, sizeX);                                                     
elseif strcmp(dSel,'timeFilt')                                                       
    G = makeGaussBump(dOpt, 1);                                                      
    G = reshape(G, [1,1,numel(G)]);                                                  
    X = convn(X,G,'valid');                                                          
elseif strcmp(dSel,'spaceFilt')                                                      
    G = makeGaussBump(dOpt, 2);                                                      
    X = convn(X,G,'valid');                                                          
elseif strcmp(dSel,'stFilt')                                                         
    G = makeGaussBump(dOpt, 3);                                                      
    X = convn(X,G,'valid');                                                          
else;  warning('Bad option, skipping denoising...\n')                                
end                                                                                  
                                                                                     
end                                                                                  
                                                                                          
% Make a Gaussian bump                                                              
function G = makeGaussBump(width, nDims)                                             
% MAKEGAUSSBUMP Create a normalized Gaussian kernel.
%
%   G = MAKEGAUSSBUMP(width, nDims) returns a Gaussian kernel with standard
%   deviation width and dimensionality nDims. nDims must be 1, 2, or 3.

    nPix    = 3*width;                                                               
    pixLocs = -nPix:nPix;                                                            
    pixSqr  = pixLocs.^2;                                                            
    if nDims == 1                                                                    
        G = exp(-pixSqr/(2*(width^2)));                                              
    elseif nDims == 2                                                                
                                                                                     
        G = exp(-bsxfun(@plus, pixSqr, pixSqr.') /(2*(width^2)));
    elseif nDims == 3
        G = exp(-bsxfun(@plus, bsxfun(@plus, pixSqr, pixSqr.'),...                   
                          reshape(pixSqr,[1,1,2*nPix+1]))/(2*(width^2)));            
    else; error('really bad number of dims.')                                        
    end                                                                              
    G = G/sum(G(:));                                                                 
end 
