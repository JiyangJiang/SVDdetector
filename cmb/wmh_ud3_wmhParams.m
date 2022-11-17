function wmh_ud3_wmhParams (spm_seg_channels)

global ud3param

wmh_ud3param_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

% How many subj failed
ud3param.wmh.failure.pairedT1Flair = cell (ud3param.global.numbers.pairedT1Flair, 2);
ud3param.wmh.failure.t1ButNotFlair = cell (ud3param.global.numbers.t1ButNotFlair, 2);
ud3param.wmh.failure.flairButNotT1 = cell (ud3param.global.numbers.flairButNotT1, 2);

for i = 1 : ud3param.global.numbers.pairedT1Flair
	ud3param.wmh.failure.pairedT1Flair{i,1} = ud3param.global.subjID.pairedT1Flair {i,1};
end
for i = 1 : ud3param.global.numbers.t1ButNotFlair
	ud3param.wmh.failure.t1ButNotFlair{i,1} = ud3param.global.subjID.t1ButNotFlair {i,1};
end
for i = 1 : ud3param.global.numbers.flairButNotT1
	ud3param.wmh.failure.flairButNotT1{i,1} = ud3param.global.subjID.flairButNotT1 {i,1};
end

% How many subj processed for wmh
ud3param.wmh.processed.pairedT1Flair = cell (ud3param.global.numbers.pairedT1Flair, 2);
ud3param.wmh.processed.t1ButNotFlair = cell (ud3param.global.numbers.t1ButNotFlair, 2);
ud3param.wmh.processed.flairButNotT1 = cell (ud3param.global.numbers.flairButNotT1, 2);

for i = 1 : ud3param.global.numbers.pairedT1Flair
	ud3param.wmh.processed.pairedT1Flair{i,1} = ud3param.global.subjID.pairedT1Flair {i,1};
end
for i = 1 : ud3param.global.numbers.t1ButNotFlair
	ud3param.wmh.processed.t1ButNotFlair{i,1} = ud3param.global.subjID.t1ButNotFlair {i,1};
end
for i = 1 : ud3param.global.numbers.flairButNotT1
	ud3param.wmh.processed.flairButNotT1{i,1} = ud3param.global.subjID.flairButNotT1 {i,1};
end

% spm segment settings
ud3param.wmh.spm.segment.n_gaussians.gm = 2; 		% 
ud3param.wmh.spm.segment.n_gaussians.wm = 2; 		% Recommended setting in SPM  
ud3param.wmh.spm.segment.n_gaussians.csf = 2;		% GM=2, WM=2, CSF=2, skull=3, scalp=4, background=2
ud3param.wmh.spm.segment.n_gaussians.wmh = 3;
ud3param.wmh.spm.segment.n_gaussians.skull = 3;
ud3param.wmh.spm.segment.n_gaussians.scalp = 4;
ud3param.wmh.spm.segment.n_gaussians.background = 2;
ud3param.wmh.spm.segment.tpm.gm = fullfile (ud3param.global.directories.spm12, 'tpm', 'TPM.nii,1');
ud3param.wmh.spm.segment.tpm.wm = fullfile (ud3param.global.directories.spm12, 'tpm', 'TPM.nii,2');
ud3param.wmh.spm.segment.tpm.csf = fullfile (ud3param.global.directories.spm12, 'tpm', 'TPM.nii,3');
ud3param.wmh.spm.segment.tpm.wmh = fullfile (ud3param.global.directories.svdd, 'wmh', 'ud3', 'templates', 'tpm_abnormal_0p5.nii,1');
ud3param.wmh.spm.segment.tpm.skull = fullfile (ud3param.global.directories.spm12, 'tpm', 'TPM.nii,4');
ud3param.wmh.spm.segment.tpm.scalp = fullfile (ud3param.global.directories.spm12, 'tpm', 'TPM.nii,5');
ud3param.wmh.spm.segment.tpm.background = fullfile (ud3param.global.directories.spm12, 'tpm', 'TPM.nii,6');
ud3param.wmh.spm.segment.channels = spm_seg_channels; 

wmh_ud3param_finishTime = toc (wmh_ud3param_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), wmh_ud3param_finishTime);
fprintf ('%s :\n', mfilename);