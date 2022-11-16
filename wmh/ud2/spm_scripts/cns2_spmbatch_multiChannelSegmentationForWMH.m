clear matlabbatch;

spm('defaults', 'fmri');
spm_jobman('initcfg');

matlabbatch{1}.spm.spatial.preproc.channel(1).vols = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2_example_data\flair\0022_tp2_flair.nii,1'};
matlabbatch{1}.spm.spatial.preproc.channel(1).biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel(1).biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel(1).write = [1 1];
% matlabbatch{1}.spm.spatial.preproc.channel(2).vols = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2_example_data\subjects\MAS0994\ud\preproc\rflair.nii,1'};
% matlabbatch{1}.spm.spatial.preproc.channel(2).biasreg = 0.001;
% matlabbatch{1}.spm.spatial.preproc.channel(2).biasfwhm = 60;
% matlabbatch{1}.spm.spatial.preproc.channel(2).write = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2\templates\DARTEL_TPM\tpm_gwm.nii,1'};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12\tpm\TPM.nii,3'};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2\templates\DARTEL_TPM\tpm_abnormal_0p5.nii,1'};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12\tpm\TPM.nii,4'};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12\tpm\TPM.nii,5'};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12\tpm\TPM.nii,6'};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 0;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];
matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];

output = spm_jobman ('run',matlabbatch);
