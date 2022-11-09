%-----------------------------------------------------------------------
% Job saved on 09-Nov-2022 22:11:29 by cfg_util (rev $Rev: 7345 $)
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
matlabbatch{2}.spm.spatial.coreg.estimate.ref = {'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12\canonical\avg152T1.nii,1'};
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
