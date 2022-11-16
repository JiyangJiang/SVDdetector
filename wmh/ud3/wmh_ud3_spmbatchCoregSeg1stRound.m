function wmh_ud3_spmbatchCoregSeg1stRound (list, i)

global ud3param

switch list
    case 'paired'
        subjID = ud3param.global.subjID.pairedT1Flair {i,1};
    case 't1only'
    case 'flairOnly'
end

clear matlabbatch;

addpath (ud3param.global.directories.spm12);

spm('defaults', 'fmri');
spm_jobman('initcfg');

if (ud3param.wmh.spm.segment.channels{1} == 2) && ...
        (strcmp (ud3param.wmh.spm.segment.channels{2}, 'T1<-FLAIR') || ...
            strcmp (ud3param.wmh.spm.segment.channels{2}, 'T1->FLAIR')) % 2 channels, either T1->FLAIR or T1<-FLAIR

    switch ud3param.wmh.spm.segment.channels{2}

        case 'T1<-FLAIR'

            ref = cellstr (fullfile(ud3param.global.directories.subjects, subjID, 'wmh', 'preproc', 't1.nii,1'));
            src = cellstr (fullfile(ud3param.global.directories.subjects, subjID, 'wmh', 'preproc', 'flair.nii,1'));

            if ud3param.global.exe.verbose
                fprintf ('%s : FLAIR will be registered to T1 (subject ID = %s).\n', mfilename, subjID);
            end
            
        case 'T1->FLAIR'

            ref = cellstr (fullfile(ud3param.global.directories.subjects, subjID, 'wmh', 'preproc', 'flair.nii,1'));
            src = cellstr (fullfile(ud3param.global.directories.subjects, subjID, 'wmh', 'preproc', 't1.nii,1'));

            if ud3param.global.exe.verbose
                fprintf ('%s : T1 will be registered to FLAIR (subject ID = %s).\n', mfilename, subjID);
            end

    end

    % coreg between T1w and FLAIR
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = ref;
    matlabbatch{1}.spm.spatial.coreg.estimate.source = src;
    matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

    % T1w coreg to MNI, to avoid origin too far from AC.
    matlabbatch{2}.spm.spatial.coreg.estimate.ref = cellstr (fullfile (ud3param.global.directories.spm12, 'toolbox', 'DARTEL', 'icbm152.nii,1'));
    switch ud3param.wmh.spm.segment.channels{2}
        case 'T1<-FLAIR'
            matlabbatch{2}.spm.spatial.coreg.estimate.source = ref;
            matlabbatch{2}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{1}, '.',...
                                                                        'val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
        case 'T1->FLAIR'
            matlabbatch{2}.spm.spatial.coreg.estimate.source = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{1}, '.',...
                                                                        'val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
            matlabbatch{2}.spm.spatial.coreg.estimate.other(1) = ref;
    end
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

    % reslice and write out for the following segmentation
    matlabbatch{3}.spm.spatial.coreg.write.ref = ref;
    matlabbatch{3}.spm.spatial.coreg.write.source(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{2}, '.',...
                                                                'val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
    matlabbatch{3}.spm.spatial.coreg.write.roptions.interp = 4;
    matlabbatch{3}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
    matlabbatch{3}.spm.spatial.coreg.write.roptions.mask = 0;
    matlabbatch{3}.spm.spatial.coreg.write.roptions.prefix = 'r';

    matlabbatch{4}.spm.spatial.preproc.channel(1).vols(1) = cellstr (fullfile(ud3param.global.directories.subjects, subjID, 'wmh', 'preproc', 'rt1.nii,1'));
    matlabbatch{4}.spm.spatial.preproc.channel(1).biasreg = 0.001;
    matlabbatch{4}.spm.spatial.preproc.channel(1).biasfwhm = 60;
    matlabbatch{4}.spm.spatial.preproc.channel(1).write = [0 1];
    matlabbatch{4}.spm.spatial.preproc.channel(2).vols(1) = cellstr (fullfile(ud3param.global.directories.subjects, subjID, 'wmh', 'preproc', 'rflair.nii,1'));
    matlabbatch{4}.spm.spatial.preproc.channel(2).biasreg = 0.001;
    matlabbatch{4}.spm.spatial.preproc.channel(2).biasfwhm = 60;
    matlabbatch{4}.spm.spatial.preproc.channel(2).write = [0 1];

    matlabbatch{4}.spm.spatial.preproc.tissue(1).tpm = {ud3param.wmh.spm.segment.tpm.gm};
    matlabbatch{4}.spm.spatial.preproc.tissue(1).ngaus = ud3param.wmh.spm.segment.n_gaussians.gm;
    matlabbatch{4}.spm.spatial.preproc.tissue(1).native = [1 1];
    matlabbatch{4}.spm.spatial.preproc.tissue(1).warped = [0 0];

    matlabbatch{4}.spm.spatial.preproc.tissue(2).tpm = {ud3param.wmh.spm.segment.tpm.wm};
    matlabbatch{4}.spm.spatial.preproc.tissue(2).ngaus = ud3param.wmh.spm.segment.n_gaussians.wm;
    matlabbatch{4}.spm.spatial.preproc.tissue(2).native = [1 1];
    matlabbatch{4}.spm.spatial.preproc.tissue(2).warped = [0 0];

    matlabbatch{4}.spm.spatial.preproc.tissue(3).tpm = {ud3param.wmh.spm.segment.tpm.csf};
    matlabbatch{4}.spm.spatial.preproc.tissue(3).ngaus = ud3param.wmh.spm.segment.n_gaussians.csf;
    matlabbatch{4}.spm.spatial.preproc.tissue(3).native = [1 1];
    matlabbatch{4}.spm.spatial.preproc.tissue(3).warped = [0 0];

    matlabbatch{4}.spm.spatial.preproc.tissue(4).tpm = {ud3param.wmh.spm.segment.tpm.wmh};
    matlabbatch{4}.spm.spatial.preproc.tissue(4).ngaus = ud3param.wmh.spm.segment.n_gaussians.wmh;
    matlabbatch{4}.spm.spatial.preproc.tissue(4).native = [1 1];
    matlabbatch{4}.spm.spatial.preproc.tissue(4).warped = [0 0];

    matlabbatch{4}.spm.spatial.preproc.tissue(5).tpm = {ud3param.wmh.spm.segment.tpm.skull};
    matlabbatch{4}.spm.spatial.preproc.tissue(5).ngaus = ud3param.wmh.spm.segment.n_gaussians.skull;
    matlabbatch{4}.spm.spatial.preproc.tissue(5).native = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(5).warped = [0 0];

    matlabbatch{4}.spm.spatial.preproc.tissue(6).tpm = {ud3param.wmh.spm.segment.tpm.scalp};
    matlabbatch{4}.spm.spatial.preproc.tissue(6).ngaus = ud3param.wmh.spm.segment.n_gaussians.scalp;
    matlabbatch{4}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(6).warped = [0 0];

    matlabbatch{4}.spm.spatial.preproc.tissue(7).tpm = {ud3param.wmh.spm.segment.tpm.background};
    matlabbatch{4}.spm.spatial.preproc.tissue(7).ngaus = ud3param.wmh.spm.segment.n_gaussians.background;
    matlabbatch{4}.spm.spatial.preproc.tissue(7).native = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(7).warped = [0 0];

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

elseif (ud3param.wmh.spm.segment.channels{1} == 1) && ...
        (strcmp (ud3param.wmh.spm.segment.channels{2}, 'FLAIRonly') || ...
            strcmp (ud3param.wmh.spm.segment.channels{2}, 'T1only')) % 1 channel, either T1only or FLAIRonly

    switch ud3param.wmh.spm.segment.channels{2}

        case 'FLAIRonly'

            % matlabbatch{2}.spm.spatial.preproc.channel(1).vols = cellstr (fullfile(ud3param.global.directories.subjects, subjID, 'wmh', 'preproc', 'flair.nii,1'));
            % matlabbatch{2}.spm.spatial.preproc.channel(1).biasreg = 0.001;
            % matlabbatch{2}.spm.spatial.preproc.channel(1).biasfwhm = 60;
            % matlabbatch{2}.spm.spatial.preproc.channel(1).write = [0 1];

            % TO DO

        case 'T1only'

            % TO DO

    end

elseif (ud3param.wmh.spm.segment.channels{1} > 2) && ...
        (strcmp (ud3param.wmh.spm.segment.channels{2}, 'all->FLAIR') || ...
            strcmp (ud3param.wmh.spm.segment.channels{2}, 'all->T1')) % multiple channels, already reg to T1 or FLAIR

    switch ud3param.wmh.spm.segment.channels{2}

        case 'all->FLAIR'

            % TO DO

        case 'all->T1'

            % TO DO

    end

end


output = spm_jobman ('run',matlabbatch);