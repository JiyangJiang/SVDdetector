% -----------------------------
% cns2_spmbatch_coregistration
% -----------------------------
%
% DESCRIPTION:
%   To register source image to reference image.
%
% INPUT:
%   srcImg = path to source image
%   refImg = path to reference image
%   outputFolder = path to the folder of the registered image, or 'same_dir' if same as srcImg dir.
%   varargin{2} = other image
%   varargin{3} = interpolation ('NN' or 'Tri')
% 
% USAGE:
%   rFLAIR = cns2_spmbatch_coregistration (FLAIR,T1,'/home/ABC');
%

function rSrcImg = cns2_spmbatch_coregistration (cns2param, srcImg, refImg, outputFolder, varargin)

    cns2_spmbatch_coregistration_startTime = tic;
    fprintf ('%s :\n', mfilename);
    fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

    [srcImgParentFolder, srcImgFilename, srcImgExt] = fileparts (srcImg);
    [refImgParentFolder, refImgFilename, refImgExt] = fileparts (refImg);

    interp = 4; % 4th degree B-spline (SPM default)

    if (nargin == 6) && strcmp(varargin{2}, 'NN')
        interp = 0;
        otherImg = varargin{1};
        if cns2param.exe.verbose
            fprintf ('%s : %s will be registered to %s, and the same transformation will be applied to %s to bring it to %s space using nearest-neighbour interpolation.\n', mfilename, ...
                                                                                                                                                                            srcImg, ...
                                                                                                                                                                            refImg, ...
                                                                                                                                                                            otherImg, ...
                                                                                                                                                                            refImg);
        end
    elseif (nargin == 6) && strcmp(varargin{2}, 'Tri')
        interp = 1;
        otherImg = varargin{1};
        if cns2param.exe.verbose
            fprintf ('%s : %s will be registered to %s, and the same transformation will be applied to %s to bring it to %s space using trilinear interpolation.\n', mfilename, ...
                                                                                                                                                                    srcImg, ...
                                                                                                                                                                    refImg, ...
                                                                                                                                                                    otherImg, ...
                                                                                                                                                                    refImg);
        end
    elseif nargin == 5
        otherImg = varargin{1};
        if cns2param.exe.verbose
            fprintf ('%s : %s will be registered to %s, and the same transformation will be applied to %s to bring it to %s space using 4th degree B-spline interpolation.\n', mfilename, ...
                                                                                                                                                                                srcImg, ...
                                                                                                                                                                                refImg, ...
                                                                                                                                                                                otherImg, ...
                                                                                                                                                                                refImg);
        end
    elseif nargin == 4
        otherImg = '';
         if cns2param.exe.verbose
            fprintf ('%s : %s will be registered to %s, using 4th degree B-spline.\n', mfilename, srcImg, refImg);
        end
    end

    clear matlabbatch;   % preallocate to enable parfor

    spm('defaults', 'fmri');
    spm_jobman('initcfg');
    
    matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[refImg ',1']};
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[srcImg ',1']};
    matlabbatch{1}.spm.spatial.coreg.estwrite.other = {otherImg};
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = interp;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

    output = spm_jobman ('run',matlabbatch);

    % move coregistered source image to outputFolder
    if ~strcmp (outputFolder, 'same_dir')
        if cns2param.exe.verbose
            fprintf ('%s : Moving coregisered image to %s.\n', mfilename, outputFolder);
        end
        movefile (fullfile (srcImgParentFolder, ['r' srcImgFilename srcImgExt]), outputFolder);
        rSrcImg = fullfile (outputFolder, ['r' srcImgFilename srcImgExt]);
    else
        rSrcImg = fullfile (srcImgParentFolder, ['r' srcImgFilename srcImgExt]);
    end
    if cns2param.exe.verbose
        fprintf ('%s : Registered image is %s.\n', mfilename, rSrcImg);
    end

    cns2_spmbatch_coregistration_finishTime = toc (cns2_spmbatch_coregistration_startTime);
    fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), cns2_spmbatch_coregistration_finishTime);
    fprintf ('%s :\n', mfilename);
