function  evert(varargin)
%EVERT Convert a bitmap image to one which uses 32 colors.
%   evert('inputImageFile') 
%   evert('inputImageFile', 'Output', 'outputImageFile')
%   evert('inputImageFile', 'Output', 'outputImageFile', 'Width', wpix, 'Height', wheight, 'Colors', ncolors, 'FlattenGray', doflatten)
%
% The first form reformats the image and displays it (no output written).
%
% The second form reformats the input image and writes the result to
% 'outputImageFile'. The output file is a bitmap suitable for
% loading/displaying on the Visage. The image is modified to use just 32
% colors, and the color indices are rearranged to use 0-31, leaving the
% rest of the color palette unused. We can display this image and use the
% remaining color levels 32-255 for LUT animation (gratings). 
% 
% The last form reformats and rescales to widthxheight pixels.
%
% The parameters 'Output', 'Width', 'Height', Colors, and 'FlattenGray' are 
% optional and can be used in any combination.  If ANY value is entered for
% 'FlattenGray', the program will (not particularly intelligently) flatten
% any colors that are "almost" gray to [0.5 0.5 0.5] in an attempt to
% prevent grayscale backgrounds from pixellating.

% Not all formats can be converted. I've had success with jpg, bmp, png
% files. 
%
% I make no attempt to produce a quality image, just one that satisfies the
% 32 color requirement. You will get the best results from a file with few
% colors (solids, not gradients), because compression of the colors (and
% changing some colors to reduce the number of colors used) can be avoided.
% 
% Feel free to modify the image handling here. I think the call to
% 'rgb2ind' at the end must be preserved because it rearranges the color
% indices in a way that the VSG library will correctly load the image. 


parser = inputParser;
parser.addRequired('Input', @ischar);
parser.addParamValue('Output', 'NONE', @ischar);
parser.addParamValue('Width', NaN, @(x) isscalar(x)); 
parser.addParamValue('Height', NaN, @(x) isscalar(x)); 
parser.addParamValue('Colors', 32, @(x) isscalar(x) && x>0 && x<256); 
parser.addParamValue('FlattenGray', NaN, @(x) isscalar(x));   %If any value is entered for FlattenGray, will force any pixels that have no values greater than 0.07 away from 0.5 to be [0.5 0.5 0.5] so gray bgs are flat
parser.parse(varargin{:});


% Get info on the image format
info = imfinfo(parser.Results.Input);

y = [];
newmap = [];
imageOK = 1;
rgb = [];

if strcmp(info.ColorType, 'indexed') == 1
    
    % color indexed file, read image and palette
    [x, map] = imread(parser.Results.Input);
    
    % Convert to rgb image
    rgb = ind2rgb(x, map);
    
elseif strcmp(info.ColorType, 'truecolor') == 1

    rgb = imread(parser.Results.Input);
    
else
    
    imageOK = 0;
    error('Cannot convert image type %s', info.ColorType);

end


if imageOK == 1

    % scale if requested
    doScale = 0;
    h = NaN;
    w = NaN;
    if isempty(find(strcmp(parser.UsingDefaults, 'Height')))
        h = parser.Results.Height;
        doScale = 1;
    end
    if isempty(find(strcmp(parser.UsingDefaults, 'Width')))
        w = parser.Results.Width;
        doScale = 1;
    end

    if doScale > 0
        rgb = imresize(rgb, [h w]);
    end
    
    % convert back to indexed file, with N colors
    [y, newmap] = rgb2ind(rgb, parser.Results.Colors);
    
    %Flatten gray levels (so a gray background is not speckled,
    %particularly on resizing images)
    if isempty(find(strcmp(parser.UsingDefaults, 'FlattenGray')))
        for i = 1:size(newmap,1)
            if ~any(abs(newmap(i,:)-0.5)>0.07)
                newmap(i,:) = [0.5 0.5 0.5];
            end
        end
    end

    % write image file
    if strcmp(parser.Results.Output, 'NONE')
        % display image
        figure;
        imshow(y, newmap);
        %[trash xx] = sort(newmap(:,1));
        %newmap(xx,:)
    else
        imwrite(y, newmap, parser.Results.Output, 'bmp');
    end
end
