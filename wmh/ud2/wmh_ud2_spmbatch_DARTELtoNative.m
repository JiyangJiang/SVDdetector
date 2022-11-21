%
% DESCRIPTION:
%   inverse transfer image from DARTEL space back to native space
%
% INPUT:
%   DARTELimg = image on DARTEL space that will be mapped back to native
%   space
%   flowMap = flow map of DARTELimg
%   varargin {1} = 'NN' (nearest neighbours. By default, 4th degree B-Spline)
%
% OUTPUT:
%   NativeImg = DARTELimg on native space


 
function NativeImg = wmh_ud2_spmbatch_DARTELtoNative (ud2param, DARTELimg, flowMap, varargin)

    ud2_spmbatch_DARTELtoNative_startTime = tic;

    fprintf ('%s :\n', mfilename);
    fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

    [dartelImgFolder, dartelImgFilename, dartelImgExt] = fileparts (DARTELimg);
    [flowMapFolder, flowMapFilename, flowMapExt] = fileparts (flowMap);

    if ud2param.exe.verbose
        fprintf ('%s : Warping %s to native space with %s.\n', mfilename, DARTELimg, flowMap);
    end
    
    if nargin == 4 && strcmp (varargin{1}, 'NN')
        
        interp = 0;

        if ud2param.exe.verbose
            fprintf ('%s : Using nearest-neighbour interpolation.\n', mfilename);
        end

    else

        interp = 4;

        if ud2param.exe.verbose
            fprintf ('%s : Using 4th degree B-Spline interpolation.\n', mfilename);
        end

    end
    
    spm('defaults', 'fmri');
    spm_jobman('initcfg');
    
    matlabbatch{1}.spm.tools.dartel.crt_iwarped.flowfields = {flowMap};
    matlabbatch{1}.spm.tools.dartel.crt_iwarped.images = {DARTELimg};
    matlabbatch{1}.spm.tools.dartel.crt_iwarped.K = 6;
    matlabbatch{1}.spm.tools.dartel.crt_iwarped.interp = interp;

    output = spm_jobman ('run',matlabbatch);
    
    NativeImg = fullfile (flowMapFolder, ['w' dartelImgFilename '_' flowMapFilename '.nii']);
    movefile (NativeImg,fullfile(flowMapFolder,[dartelImgFilename '_native.nii']));
    NativeImg = fullfile (flowMapFolder, [dartelImgFilename '_native.nii']);

    if ud2param.exe.verbose
        fprintf ('%s : Finished warping. Warped image is %s.\n', mfilename, NativeImg);
    end

    ud2_spmbatch_DARTELtoNative_finishTime = toc (ud2_spmbatch_DARTELtoNative_startTime);
    fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), ud2_spmbatch_DARTELtoNative_finishTime);
    fprintf ('%s :\n', mfilename);
