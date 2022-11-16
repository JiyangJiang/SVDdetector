%-----------------
% CNSP_mapToDARTEL
%-----------------
%
% DESCRIPTION:
%   To map image to DARTEL space
%
% INPUT:
%   srcImg = path to the image (*.nii) that will be mapped to DARTEL space
%   flowMap = flow map of srcImg
%   varargin{1} = 'Trilinear' or 'NN'
%
% OUTPUT:
%   srcImgOnDARTEL = srcImg mapped to DARTEL space
%
% USAGE:
%   srcImgOnDARTEL = cns2_spmbatch_nativeToDARTEL (srcImg, flowMap)
%
% NOTE:
%   need to run CNSP_runDARTELe or CNSP_runDARTELc to generate flow map
%

function srcImgOnDARTEL = cns2_spmbatch_nativeToDARTEL (cns2param, srcImg, flowMap, varargin)

    cns2_spmbatch_nativeToDARTEL_startTime = tic;

    fprintf ('%s :\n', mfilename);
    fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

    [flowMapFolder,flowMapFilename,flowMapExt] = fileparts (flowMap);
    [srcImgFolder,srcImgFilename,srcImgExt] = fileparts (srcImg);

    if cns2param.exe.verbose
        fprintf ('%s : Warping %s to DARTEL space with %s.\n', mfilename, srcImgFilename, flowMapFilename);
    end
    
    if nargin == 4
        switch varargin{1}
            case 'Trilinear'
                interpCode = 1;
                if cns2param.exe.verbose
                    fprintf ('%s : Using trilinear interpolation.\n', mfilename);
                end
            case 'NN'
                interpCode = 0;
                if cns2param.exe.verbose
                    fprintf ('%s : Using nearest-neighbour interpolation.\n', mfilename);
                end
        end
    elseif nargin == 3
        interpCode = 1;
        if cns2param.exe.verbose
            fprintf ('%s : Using trilinear interpolation.\n', mfilename);
        end
    end
    
    clear matlabbatch;

    spm('defaults', 'fmri');
    spm_jobman('initcfg');

    matlabbatch{1}.spm.tools.dartel.crt_warped.flowfields = {flowMap};
    matlabbatch{1}.spm.tools.dartel.crt_warped.images = {
                                                         {srcImg}
                                                         }';
    matlabbatch{1}.spm.tools.dartel.crt_warped.jactransf = 0;
    matlabbatch{1}.spm.tools.dartel.crt_warped.K = 6;
    matlabbatch{1}.spm.tools.dartel.crt_warped.interp = interpCode;

    output = spm_jobman ('run',matlabbatch);
    
    srcImgOnDARTEL = fullfile (flowMapFolder, ['w' srcImgFilename srcImgExt]);

    if cns2param.exe.verbose
        fprintf ('%s : Finished warping. Warped image is %s.\n', mfilename, srcImgOnDARTEL);
    end

    cns2_spmbatch_nativeToDARTEL_finishTime = toc (cns2_spmbatch_nativeToDARTEL_startTime);
    fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), cns2_spmbatch_nativeToDARTEL_finishTime);
    fprintf ('%s :\n', mfilename);