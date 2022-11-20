%
% INPUT:
%   calType = 'sum', 'avg',
%   outputDir = output directory
%   outputFilename = output filename without .nii suffix
%   N = number of images that will be calculated
%   inputCellArr_col = a column cell array containing paths to each image
%
% OUTPUT:
%   outputImg = path to output image
%
% NOTE:
% 	Do not include extension in outputFilename
%

function outputImg = wmh_ud2_spmbatch_imgCal (ud2param, calType, outputDir, outputFilename, N, inputCellArr_col)

wmh_ud2_spmbatch_imgCal_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

if ud2param.exe.verbose
    fprintf ('%s : %s images.\n', mfilename, calType);
end

[row,col] = size (inputCellArr_col);

if (row ~= N) || (col ~= 1)
	error ('Incorrect cell array size.');
end

switch calType
    case 'avg'  % average input images
        for i = 1:N
            if i == 1
                expr = 'i1';
            else
                expr = strcat(expr,['+i' num2str(i)]);
            end
        end

        expr = ['(' expr ')/' num2str(N)];
        
    case 'sum'  % sum input images
        for i = 1:N
            if i == 1
                expr = 'i1';
            else
                expr = strcat(expr,['+i' num2str(i)]);
            end
        end
        
    otherwise
        error (['No calculation type ' calType ' defined in wmh_ud2_spmbatch_imgCal.']);
end

spm('defaults', 'fmri');
spm_jobman('initcfg');
clear matlabbatch;

matlabbatch{1}.spm.util.imcalc.input = inputCellArr_col;
matlabbatch{1}.spm.util.imcalc.output = outputFilename;
matlabbatch{1}.spm.util.imcalc.outdir = {outputDir};
matlabbatch{1}.spm.util.imcalc.expression = expr;
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 64;

output = spm_jobman ('run',matlabbatch);

outputImg = fullfile(outputDir, [outputFilename '.nii']);

if ud2param.exe.verbose
    fprintf ('%s : Output image is %s.\n', mfilename, outputImg);
end

wmh_ud2_spmbatch_imgCal_finishTime = toc (wmh_ud2_spmbatch_imgCal_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), wmh_ud2_spmbatch_imgCal_finishTime);
fprintf ('%s :\n', mfilename);