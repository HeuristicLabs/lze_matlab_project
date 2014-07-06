
%%% This code takes structured light captured images and gives the decoded 
%%% column/row indices.

%%% This is the script file (with the parameters) for the function
%%% CombinedDecode.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; pack; clc; 





%%%%%%%%%%%%%%%% Input data directory and file naming %%%%%%%%%%%%%%%%%%%%%

% Input Data directory. For directory structure, see README.doc
% The data should be in 4 sub-directories, one for each set of codes. An
% example is included in '..\..\Experiments\data\Bowl'.
dataDirname     = ['..\..\Experiments\data\Bowl'];

% Directory which contains the projected images. These directories contain
% the information about projected patterns required for decoding. This
% directory has the same sub-directory structure as the captured data. 
permDirname     = ['..\..\Patterns'];

% Length of the filenames. For example, if the names are 01.pgm,
% 02.pgm,..., the indexlength is 2. 
indexLength     = 2;
imSuffix        = ['.pgm'];         % Image suffix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%% Defining parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Camera and projector parameters
projDim         = [768 1024];               % Number of projector rows and columns
camDim          = [2000 2400];              % Number of camera rows and columns



%%% Reconstruction parameters.
ShadowThresh    = 0.0;                      % Threshold for culling shadow pixels. The larger the value, the more aggressive is the culling. Typical values between [0,0.1]. If it is set to zero - so no pixels will be culled. 

medfiltParam    = [3 3];                    % Size of filter for pre-filtering the correspondence maps before applying the consistency check. Typical values: [3x3] -- [5x5]. If too many holes left in the final image, use 5x5. 
DiffThresh      = 3;                        % Difference threshold (in pixels) - below which the decoded column values for different codes are considered the same. See paper for details. 

HoleFillFlag    = 1;                        % If (software) hole-filling is performed in post-processing for error-pixels. Make this zero if no holes are being formed in the correspondence map. 
medfiltHoleFill = [17 17];                  % Size of the neighborhood for Hole Filling. Typical values: [9x9] -- [25x25]. Use larger values if too many holes are left in the final correspondence map. Holefilling affects only the error pixels. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%%%%%%%%%%%%%%%%%%%%% Recovering the correspondences %%%%%%%%%%%%%%%%%%%%%%

% IC is the correspondence map
[IC]                = CombinedDecode(dataDirname, permDirname, indexLength, camDim(1), camDim(2), imSuffix, ShadowThresh, medfiltParam, DiffThresh, HoleFillFlag, medfiltHoleFill);


%%% Saving the correspondence map
save([dataDirname, '\DecodedIndices.mat'], 'IC');
%%% Show the result
figure;imagesc(IC);colormap(jet(256));colorbar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%