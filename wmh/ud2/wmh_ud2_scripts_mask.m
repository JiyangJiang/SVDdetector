% DESCRIPTION:
% 	mask with voxels with intensity larger than 0
%
% USAGE:
% 	in = path to in nii
% 	mask = path to mask nii
% 	out = path to out nii

function wmh_ud2_spmscripts_mask (ud2param, in, mask, out)

ud2_spmscripts_mask_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

if ud2param.exe.verbose
	fprintf ('%s : Masking %s with %s, and outputing as %s\n', mfilename, in, mask, out);
end

in_dat   = spm_read_vols (spm_vol (in));
mask_dat = spm_read_vols (spm_vol (mask));

% NaN -> 0
in_dat(isnan(in_dat)) = 0;
mask_dat(isnan(mask_dat)) = 0;

% whether in and mask are of the same dimension
if ~(size(in_dat,1)==size(mask_dat,1) && ...
	 size(in_dat,2)==size(mask_dat,2) && ...
	 size(in_dat,3)==size(mask_dat,3))
	error ('%s and %s are not of the same dimension.\n', in, mask);
end

out_dat = in_dat;
out_dat (mask_dat <= 0) = 0;

if ud2param.exe.verbose
	fprintf ('%s : Writing masked image (%s) to nifti.\n', mfilename, out);
end

wmh_ud2_scripts_writeNii (ud2param, spm_vol(in), out_dat, out);

ud2_spmscripts_mask_finishTime = toc (ud2_spmscripts_mask_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), ud2_spmscripts_mask_finishTime);
fprintf ('%s :\n', mfilename);