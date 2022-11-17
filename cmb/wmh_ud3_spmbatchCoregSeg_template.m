%-----------------------------------------------------------------------
% Job saved on 09-Nov-2022 22:17:14 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.coreg.estimate.ref = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2_example_data\subjects\MAS0994\wmh\preproc\t1.nii,1'};
matlabbatch{1}.spm.spatial.coreg.estimate.source = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2_example_data\subjects\MAS0994\wmh\preproc\flair.nii,1'};
matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
matlabbatch{2}.spm.spatial.coreg.estimate.ref = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12\toolbox\DARTEL\icbm152.nii,1'};
matlabbatch{2}.spm.spatial.coreg.estimate.source = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2_example_data\subjects\MAS0994\wmh\preproc\t1.nii,1'};
matlabbatch{2}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
matlabbatch{3}.spm.spatial.coreg.write.ref = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2_example_data\subjects\MAS0994\wmh\preproc\t1.nii,1'};
matlabbatch{3}.spm.spatial.coreg.write.source(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{3}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{3}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{3}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{3}.spm.spatial.coreg.write.roptions.prefix = 'r';
matlabbatch{4}.spm.spatial.preproc.channel(1).vols(1) = cfg_dep('Coregister: Reslice: Resliced Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
matlabbatch{4}.spm.spatial.preproc.channel(1).biasreg = 0.001;
matlabbatch{4}.spm.spatial.preproc.channel(1).biasfwhm = 60;
matlabbatch{4}.spm.spatial.preproc.channel(1).write = [0 1];
matlabbatch{4}.spm.spatial.preproc.channel(2).vols(1) = cfg_dep('Coregister: Reslice: Resliced Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
matlabbatch{4}.spm.spatial.preproc.channel(2).biasreg = 0.001;
matlabbatch{4}.spm.spatial.preproc.channel(2).biasfwhm = 60;
matlabbatch{4}.spm.spatial.preproc.channel(2).write = [0 1];
matlabbatch{4}.spm.spatial.preproc.tissue(1).tpm = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12\tpm\TPM.nii,1'};
matlabbatch{4}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{4}.spm.spatial.preproc.tissue(1).native = [1 1];
matlabbatch{4}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(2).tpm = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12\tpm\TPM.nii,2'};
matlabbatch{4}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{4}.spm.spatial.preproc.tissue(2).native = [1 1];
matlabbatch{4}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(3).tpm = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12\tpm\TPM.nii,3'};
matlabbatch{4}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{4}.spm.spatial.preproc.tissue(3).native = [1 1];
matlabbatch{4}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(4).tpm = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12\tpm\TPM.nii,4'};
matlabbatch{4}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{4}.spm.spatial.preproc.tissue(4).native = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(5).tpm = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12\tpm\TPM.nii,5'};
matlabbatch{4}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{4}.spm.spatial.preproc.tissue(5).native = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(6).tpm = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12\tpm\TPM.nii,6'};
matlabbatch{4}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{4}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{4}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{4}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{4}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{4}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{4}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{4}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{4}.spm.spatial.preproc.warp.write = [0 0];
matlabbatch{4}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{4}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];
