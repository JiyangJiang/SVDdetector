%--------------------
% CNSP_DARTELtoNative
%--------------------
%
% DESCRIPTION:
%   inverse transfer image from DARTEL space back to native space
%
% INPUT:
%   DARTELimg = image on DARTEL space that will be mapped back to native
%   space
%   flowMap = flow map of DARTELimg
%   varargin {1} = 'NN' (nearest neighbours. By default, trilinear)
%
% OUTPUT:
%   NativeImg = DARTELimg on native space
%
% USAGE:
%   NativeImg = CNSP_DARTELtoNative (DARTELimg, flowMap)
%

 
function NativeImg = cns2_spmbatch_DARTELtoNative (cns2param, DARTELimg, flowMap, varargin)

    cns2_spmbatch_DARTELtoNative_startTime = tic;

    fprintf ('%s :\n', mfilename);
    fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

    [dartelImgFolder, dartelImgFilename, dartelImgExt] = fileparts (DARTELimg);
    [flowMapFolder, flowMapFilename, flowMapExt] = fileparts (flowMap);

    if cns2param.exe.verbose
        fprintf ('%s : Warping %s to native space with %s.\n', mfilename, DARTELimg, flowMap);
    end
    
    if nargin == 4 && strcmp (varargin{1}, 'NN')
        
        interp = 0;

        if cns2param.exe.verbose
            fprintf ('%s : Using nearest-neighbour interpolation.\n', mfilename);
        end

    else

        interp = 1;

        if cns2param.exe.verbose
            fprintf ('%s : Using trilinear interpolation.\n', mfilename);
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

    if cns2param.exe.verbose
        fprintf ('%s : Finished warping. Warped image is %s.\n', mfilename, NativeImg);
    end

    cns2_spmbatch_DARTELtoNative_finishTime = toc (cns2_spmbatch_DARTELtoNative_startTime);
    fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), cns2_spmbatch_DARTELtoNative_finishTime);
    fprintf ('%s :\n', mfilename);
