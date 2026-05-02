function varargout = plotDifferentColoredROIS2(imgArray, varargin)

% varargout = plotDifferentColoredROIS(imgArray, varargin)
% 
% Plots the ROIs (a 3D array) in different colors to visualize their
% spatial locations. 
%
% 2023 - Adam Charles

p = inputParser;
p.addParameter('figNo',       1);
p.addParameter('normOpt',     'single');
p.addParameter('filterSize',  [0,Inf]);
p.addParameter('aspectRatio', []);
parse(p,varargin{:});
p = p.Results;

numPix = sum(sum(bsxfun(@gt, imgArray, 0.1*max(max(imgArray,[],1),[],2)  ),1),2);

imgArray = imgArray(:,:,(numPix>=p.filterSize(1))&(numPix<=p.filterSize(2)));

numImgs = size(imgArray,3);
% Define an array of 10 distinct RGB colors (values between 0 and 1)
allColors = [1,0.4314,0.7804;   % Red
             0, 1, 0;   % Green
              0, 1, 1;   % Cyan
             0, 0, 1;   % Blue
             1, 1, 0;   % Yellow
             1, 0, 1;   % Magenta
             1, 1, 1; % white
             0.5, 0, 0.5; % Purple
             0, 0.5, 0.5; % Teal
             0.5, 0.5, 0.5]; % Gray
% testing

imgFull = zeros(size(imgArray,1),size(imgArray,2),3);
for ll = 1:numImgs
    TMPimg = imgArray(:,:,ll).*(imgArray(:,:,ll)>0);
    switch p.normOpt
        case 'all'; TMPimg  = TMPimg./max(imgArray(:));
        otherwise;  TMPimg  = TMPimg./max(TMPimg(:));
    end
    imgFull = imgFull + bsxfun(@times, TMPimg,...
                                       reshape(allColors(ll,:),[1,1,3]));
end

if nargout >0; varargout{1} = imgFull;
else
    figure(p.figNo)
    imagesc(imgFull)
    if isempty(p.aspectRatio); axis image;
    else;                      pbaspect([p.aspectRatio,1]);
    end
    axis off
end



end
