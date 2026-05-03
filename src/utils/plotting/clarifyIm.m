function im = clarifyIm(im, color)
% a function I used to make GraFT spatial profiles easier to display for figures

    tmp = im;
    filtered = wiener2(tmp, [2,2]);                                 % denoise      
    bolded = imadjust(filtered, stretchlim(filtered), [], 2);       % sharpen
    cleanIm = medfilt2(bolded, [2,2]);                              % filter noise
    im = colorIm(cleanIm, color);                                   % color the resulting clarified image
end