% DESCRIPTION:
% 	mask with voxels with intensity larger than 0
%
% USAGE:
% 	in = path to in nii
% 	mask = path to mask nii
% 	out = path to out nii

function cns2_spmscripts_mask (cns2param, in, mask, out)

cns2_spmscripts_mask_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

if cns2param.exe.verbose
	fprintf ('%s : Masking %s with %s, and outputing as %s\n', mfilename, in, mask, out);
end

in_dat   = spm_read_vols (spm_vol (in));
mask_dat = spm_read_vols (spm_vol (mask));

% whether in and mask are of the same dimension
if ~(size(in_dat,1)==size(mask_dat,1) && ...
	 size(in_dat,2)==size(mask_dat,2) && ...
	 size(in_dat,3)==size(mask_dat,3))
	error ('%s and %s are not of the same dimension.\n', in, mask);
end

out_dat = in_dat;
out_dat (mask_dat <= 0) = 0;

if cns2param.exe.verbose
	fprintf ('%s : Writing masked image (%s) to nifti.\n', mfilename, out);
end

cns2_scripts_writeNii (cns2param, spm_vol(in), out_dat, out);

cns2_spmscripts_mask_finishTime = toc (cns2_spmscripts_mask_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), cns2_spmscripts_mask_finishTime);
fprintf ('%s :\n', mfilename);