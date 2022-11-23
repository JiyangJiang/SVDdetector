function [bias_field_corrected, bias_field] = wmh_ud2_spmbatch_corrBiasField (ud2param, in_nii)

wmh_ud2_spmbatch_corrBiasField_startTime = tic;
fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

[in_nii_dir, in_nii_fname, in_nii_ext] = fileparts (in_nii);

spm12tpm = fullfile (spm('Dir'), 'tpm', 'TPM.nii');

if ud2param.exe.verbose
	fprintf ('%s : correcting bias field for %s.\n', mfilename, [in_nii_fname in_nii_ext]);
end

clear matlabbatch;

spm('defaults', 'fmri');
spm_jobman('initcfg');

matlabbatch{1}.spm.spatial.preproc.channel.vols = {in_nii};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 40; 	% larger values for less non-uniformity, and preventing the loss of intensity 
															% variation between tissue types. SPM default is 60.
matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];

matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm ={[spm12tpm ',1']};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm ={[spm12tpm ',2']};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm ={[spm12tpm ',3']};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm ={[spm12tpm ',4']};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm ={[spm12tpm ',5']};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[spm12tpm ',6']};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];

matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];

output = spm_jobman ('run',matlabbatch);

bias_field_corrected = fullfile (in_nii_dir, ['m'          in_nii_fname in_nii_ext]);
bias_field           = fullfile (in_nii_dir, ['BiasField_' in_nii_fname in_nii_ext]);

wmh_ud2_spmbatch_corrBiasField_finishTime = toc (wmh_ud2_spmbatch_corrBiasField_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), wmh_ud2_spmbatch_corrBiasField_finishTime);
fprintf ('%s :\n', mfilename);