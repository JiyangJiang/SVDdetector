%
% DESCRIPTION:
%   creating template DARTEL run

% OUTPUT:
%   flowMap = cell array containing path to each subject's flow map
%   varargout {1:7} = Template_{0-6}.nii
%


function [flowMapCellArr,varargout] = wmh_ud2_spmbatch_runDARTELc (ud2param, ...
                                                                    rcGMcellArr_col, ...
                                                                    rcWMcellArr_col, ...
                                                                    rcCSFcellArr_col)
    
    if (size(rcGMcellArr_col,1) == size(rcWMcellArr_col,1)) && ...
        (size(rcWMcellArr_col,1) == size(rcCSFcellArr_col,1))
        N = size(rcGMcellArr_col,1);
    else
        ME = MException ('wmh_ud2_spmbatch_runDARTELc:unequalArraySizes',...
                            '%s : rcGM, rcWM, rcCSF arrays are not of the same size.\n', mfilename);
    end

    if ud2param.exe.verbose
        fprintf ('%s : Creating templates.\n', mfilename);
    end
    
    %% SPM
    clear matlabbatch;
    spm_jobman('initcfg');
    spm('defaults', 'fmri');
    matlabbatch{1}.spm.tools.dartel.warp.images = {
                                                    rcGMcellArr_col
                                                    rcWMcellArr_col
                                                    rcCSFcellArr_col
                                                  };
    matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
    matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam = 16;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam = 8;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K = 1;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam = 4;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K = 2;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam = 2;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K = 4;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam = 1;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K = 6;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its = 3;
    
    output = spm_jobman ('run',matlabbatch);

    
    %% output
    [rcGM1folder,~,~] = fileparts(rcGMcellArr_col{1,1});
    flowMapCellArr = cell(N,1);
    
    for i = 1:N
        [curr_rcGMfolder,curr_rcGMfilename,~] = fileparts(rcGMcellArr_col{i,1});
        flowMapCellArr {i,1} = fullfile (curr_rcGMfolder, ['u_' curr_rcGMfilename '_Template.nii']);
    end
    
    varargout{1} = fullfile (rcGM1folder, 'Template_0.nii');
    varargout{2} = fullfile (rcGM1folder, 'Template_1.nii');
    varargout{3} = fullfile (rcGM1folder, 'Template_2.nii');
    varargout{4} = fullfile (rcGM1folder, 'Template_3.nii');
    varargout{5} = fullfile (rcGM1folder, 'Template_4.nii');
    varargout{6} = fullfile (rcGM1folder, 'Template_5.nii');
    varargout{7} = fullfile (rcGM1folder, 'Template_6.nii');



    
    