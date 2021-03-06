
%%% This function accepts as input the directory containing the encoded 
%%% sequences using the XOR codes. permcol is the permutation of the
%%% patterns. If the conventional Gray codes are XOR-ed, the permutation is
%%% that of the conventional Gray codes. 
%%% ColImageBaseIndices is a pair of column indices which are the base patterns. 
%%% These images will be used to make the base binary map, and the rest 
%%% will be generated by taking XOR with this binary map. 

%%% The output is a pair of images containing the 
%%% decoded decimal integers corresponding to the projector column
%%% that illuminated each camera pixel. A value of zero indicates a given 
%%% pixel cannot be assigned a correspondence, and the projector columns 
%%% and rows are indexed from one. IDiff1 is a measure of reliability. A 
%%% low value for a pixel in IDiff1 means that pixel can not be decoded reliably. 


function [IC, IDiff1] = bindecodePermXOR(dirname, permcol, nr, nc, ColImageIndices, ColImageBaseIndices, imSuffix)

numColImages    = numel(ColImageIndices);

%%%% Decoding Column Indices

%%% First make the base binary map
I1          = double(imread([dirname, '\', sprintf(['%02d'],  ColImageBaseIndices(1)), imSuffix]));
I2          = double(imread([dirname, '\', sprintf(['%02d'],  ColImageBaseIndices(2)), imSuffix]));
I1          = mean(I1, 3);
I2          = mean(I2, 3);
IBase       = I1>I2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IC          = zeros(nr, nc);                    % This will store the column index per pixel
IDiff1      = zeros(nr, nc);                    % Measuring the difference for detecting shadows

for i=1:numel(ColImageIndices)
    
    I1          = double(imread([dirname, '\', sprintf(['%02d'],  ColImageIndices(i)), imSuffix]));
    I2          = double(imread([dirname, '\', sprintf(['%02d'],  ColImageIndices(i)+1), imSuffix]));        %%% Assuming the inverse image is the next one
    I1          = mean(I1, 3);
    I2          = mean(I2, 3);
    
    Itmp        = I1 > I2;                      % Find out if the pixel is on
    
    if(ColImageIndices(i) < ColImageBaseIndices(1))
        Itmp    = xor(Itmp, IBase);             % Make the actual binary pattern by xor-ing
    end
        
    IC          = IC + Itmp * 2^(numColImages-i);
    
    IDiff1      = IDiff1 + abs(I1 - I2) ./ (I1 + I2 + eps);
    
    ItmpL       = 255*uint8(Itmp);
    imwrite(ItmpL, [dirname, '\BitPlane', sprintf(['%02d'],  i), '.bmp']);      %%%% Saving the bitplanes

    clear I1 I2 Itmp 
    
end

IC          = IC + 1;                           % Indices start from 1
[~, IC]     = ismember(IC, permcol);            % Using the permutation to get the indices
IC          = IC - 1/2;                         % Get the pixel coordinate in the center

IDiff1      = IDiff1 ./ numColImages;