function wmh_spmbatchCoregSeg (params, list, i)

switch list
    case 'paired'
        subjID = params.global.subjID.pairedT1Flair {i,1};
    case 't1only'
    case 'flairOnly'
end

clear matlabbatch;

spm('defaults', 'fmri');
spm_jobman('initcfg');

if strcmp (params.wmh.spm.segment.channels, 'T1+FLAIR')
    matlabbatch{1}.spm.spatial.coreg.estwrite.ref = cellstr (fullfile(params.global.directories.subjects, subjID, 'wmh', 'preproc', 't1.nii,1'));
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = cellstr (fullfile(params.global.directories.subjects, subjID, 'wmh', 'preproc', 'flair.nii,1'));
    matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
end

switch params.wmh.spm.segment.channels
    case 'T1+FLAIR'
        matlabbatch{2}.spm.spatial.preproc.channel(1).vols = cellstr (fullfile(params.global.directories.subjects, subjID, 'wmh', 'preproc', 't1.nii,1'));
        matlabbatch{2}.spm.spatial.preproc.channel(1).biasreg = 0.001;
        matlabbatch{2}.spm.spatial.preproc.channel(1).biasfwhm = 60;
        matlabbatch{2}.spm.spatial.preproc.channel(1).write = [0 1];

        matlabbatch{2}.spm.spatial.preproc.channel(2).vols(1) = cfg_dep('Coregister: Estimate & Reslice: Resliced Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
        matlabbatch{2}.spm.spatial.preproc.channel(2).biasreg = 0.001;
        matlabbatch{2}.spm.spatial.preproc.channel(2).biasfwhm = 60;
        matlabbatch{2}.spm.spatial.preproc.channel(2).write = [0 1];
    case 'FLAIR'
        matlabbatch{2}.spm.spatial.preproc.channel(1).vols = cellstr (fullfile(params.global.directories.subjects, subjID, 'wmh', 'preproc', 'flair.nii,1'));
        matlabbatch{2}.spm.spatial.preproc.channel(1).biasreg = 0.001;
        matlabbatch{2}.spm.spatial.preproc.channel(1).biasfwhm = 60;
        matlabbatch{2}.spm.spatial.preproc.channel(1).write = [0 1];
end

matlabbatch{2}.spm.spatial.preproc.tissue(1).tpm = {params.wmh.spm.segment.tpm.gm};
matlabbatch{2}.spm.spatial.preproc.tissue(1).ngaus = params.wmh.spm.segment.n_gaussians.gm;
matlabbatch{2}.spm.spatial.preproc.tissue(1).native = [1 1];
matlabbatch{2}.spm.spatial.preproc.tissue(1).warped = [0 0];

matlabbatch{2}.spm.spatial.preproc.tissue(2).tpm = {params.wmh.spm.segment.tpm.wm};
matlabbatch{2}.spm.spatial.preproc.tissue(2).ngaus = params.wmh.spm.segment.n_gaussians.wm;
matlabbatch{2}.spm.spatial.preproc.tissue(2).native = [1 1];
matlabbatch{2}.spm.spatial.preproc.tissue(2).warped = [0 0];

matlabbatch{2}.spm.spatial.preproc.tissue(3).tpm = {params.wmh.spm.segment.tpm.csf};
matlabbatch{2}.spm.spatial.preproc.tissue(3).ngaus = params.wmh.spm.segment.n_gaussians.csf;
matlabbatch{2}.spm.spatial.preproc.tissue(3).native = [1 1];
matlabbatch{2}.spm.spatial.preproc.tissue(3).warped = [0 0];

matlabbatch{2}.spm.spatial.preproc.tissue(4).tpm = {params.wmh.spm.segment.tpm.wmh};
matlabbatch{2}.spm.spatial.preproc.tissue(4).ngaus = params.wmh.spm.segment.n_gaussians.wmh;
matlabbatch{2}.spm.spatial.preproc.tissue(4).native = [1 1];
matlabbatch{2}.spm.spatial.preproc.tissue(4).warped = [0 0];

matlabbatch{2}.spm.spatial.preproc.tissue(5).tpm = {params.wmh.spm.segment.tpm.skull};
matlabbatch{2}.spm.spatial.preproc.tissue(5).ngaus = params.wmh.spm.segment.n_gaussians.skull;
matlabbatch{2}.spm.spatial.preproc.tissue(5).native = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(5).warped = [0 0];

matlabbatch{2}.spm.spatial.preproc.tissue(6).tpm = {params.wmh.spm.segment.tpm.scalp};
matlabbatch{2}.spm.spatial.preproc.tissue(6).ngaus = params.wmh.spm.segment.n_gaussians.scalp;
matlabbatch{2}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(6).warped = [0 0];

matlabbatch{2}.spm.spatial.preproc.tissue(7).tpm = {params.wmh.spm.segment.tpm.background};
matlabbatch{2}.spm.spatial.preproc.tissue(7).ngaus = params.wmh.spm.segment.n_gaussians.background;
matlabbatch{2}.spm.spatial.preproc.tissue(7).native = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(7).warped = [0 0];

matlabbatch{2}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{2}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{2}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{2}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{2}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{2}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{2}.spm.spatial.preproc.warp.write = [0 0];
matlabbatch{2}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{2}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];

output = spm_jobman ('run',matlabbatch);