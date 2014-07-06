
%%% This function accepts as input the directory containing the encoded 
%%% sequences using the permutated binary code. permcol is the code 
%%% permutation. 

%%% The output is an image containing the decoded 
%%% decimal integers corresponding to the projector column that 
%%% illuminated each camera pixel. A value of zero indicates a given pixel 
%%% cannot be assigned a correspondence. The projector columns are indexed 
%%% from one. IDiff1 is a measure of reliability. A low value for a
%%% pixel in IDiff1 means that pixel can not be decoded reliably. 


function [IC, IDiff1] = bindecodePerm(dirname, indexLength, permcol, nr, nc, ColImageIndices, imSuffix)

numColImages    = numel(ColImageIndices);

%%%% Decoding Column Indices

IC          = zeros(nr, nc);                % This will store the column index per pixel
IDiff1      = zeros(nr, nc);                % Measuring the difference for detecting reliability/shadows

for i=1:numel(ColImageIndices)
    
    I1          = double(imread([dirname, '\', sprintf(['%0', num2str(indexLength), 'd'],  ColImageIndices(i)), imSuffix]));
    I2          = double(imread([dirname, '\', sprintf(['%0', num2str(indexLength), 'd'],  ColImageIndices(i)+1), imSuffix]));        %%% Assuming the inverse image is the next one
    I1          = mean(I1,3);
    I2          = mean(I2,3);
    
    Itmp        = I1 > I2;                  % Find out if the pixel is on

    IC          = IC + Itmp * 2^(numColImages-i);
    
    IDiff1      = IDiff1 + abs(I1 - I2) ./ (I1 + I2 + eps);
    
        
    ItmpL       = 255*uint8(Itmp);
    imwrite(ItmpL, [dirname, '\BitPlane', sprintf(['%02d'],  i), '.bmp']);              %%%% Saving the bitplanes
    
    clear I1 I2 Itmp 
    
end

IC          = IC + 1;                       % Indices start from 1
[~, IC]     = ismember(IC, permcol);        % Using the permutation to get the indices
IC          = IC - 1/2;                     % Get the pixel coordinate in the center

IDiff1      = IDiff1 ./ numColImages;