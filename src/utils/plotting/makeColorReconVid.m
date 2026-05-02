function makeColorReconVid(X, S, D, varargin)

% X is NxMxT
% S is NxMxK
% D is TxK

p = inputParser;
p.addParameter('maxThresh',   0);
p.addParameter('normOpt',     'single');
p.addParameter('filterSize',  [0,Inf]);
p.addParameter('aspectRatio', []);
p.addParameter('colors',      []);
parse(p,varargin{:});
p = p.Results;

Nx = size(S,1);
Ny = size(S,2);
Nt = size(D,1);

numPix  = sum(sum(bsxfun(@gt, S, p.maxThresh*max(max(S,[],1),[],2)  ),1),2);
S       = S(:,:,(numPix>=p.filterSize(1))&(numPix<=p.filterSize(2)));
numImgs = size(S,3);

if ~isempty(p.colors);   allColors = p.colors;
else;                    allColors = distinguishable_colors(numImgs,'k');
end

reconVid = zeros([Nx,Ny,Nt,3] ,'single');
for ll = 1:numImgs
    reconVid = reconVid + single(bsxfun(@times, ...
            bsxfun(@times, (S(:,:,ll)), ...
            reshape((D(:,ll)),[1,1,Nt])),...
            reshape((allColors(ll,:)),[1,1,1,3])));
end

X = single(X);
X = X/max(X(:));
X = cat(4,X,X,X);

MovieSlider(permute(cat(2,X,0*X(:,1:30,:,:),reconVid),[1,2,4,3]));

end
