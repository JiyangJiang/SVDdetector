function wmh_params (spm_seg_channels)

global params

wmh_params_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

% How many subj succeeded / failed
params.wmh.success.pairedT1Flair = cell (params.global.numbers.pairedT1Flair, 2);
params.wmh.success.t1ButNotFlair = cell (params.global.numbers.t1ButNotFlair, 2);
params.wmh.success.flairButNotT1 = cell (params.global.numbers.flairButNotT1, 2);

for i = 1 : params.global.numbers.pairedT1Flair
	params.wmh.success.pairedT1Flair{i,1} = params.global.subjID.pairedT1Flair {i,1};
end
for i = 1 : params.global.numbers.t1ButNotFlair
	params.wmh.success.t1ButNotFlair{i,1} = params.global.subjID.t1ButNotFlair {i,1};
end
for i = 1 : params.global.numbers.flairButNotT1
	params.wmh.success.flairButNotT1{i,1} = params.global.subjID.flairButNotT1 {i,1};
end

% spm segment settings
params.wmh.spm.segment.n_gaussians.gm = 2; 		% 
params.wmh.spm.segment.n_gaussians.wm = 2; 		% Recommended setting in SPM  
params.wmh.spm.segment.n_gaussians.csf = 2;		% GM=2, WM=2, CSF=2, skull=3, scalp=4, background=2
params.wmh.spm.segment.n_gaussians.wmh = 3;
params.wmh.spm.segment.n_gaussians.skull = 3;
params.wmh.spm.segment.n_gaussians.scalp = 4;
params.wmh.spm.segment.n_gaussians.background = 2;
params.wmh.spm.segment.tpm.gm = fullfile (params.global.directories.spm12, 'tpm', 'TPM.nii,1');
params.wmh.spm.segment.tpm.wm = fullfile (params.global.directories.spm12, 'tpm', 'TPM.nii,2');
params.wmh.spm.segment.tpm.csf = fullfile (params.global.directories.spm12, 'tpm', 'TPM.nii,3');
params.wmh.spm.segment.tpm.wmh = fullfile (params.global.directories.svdd, 'templates', 'tpm_abnormal_0p5.nii,1');
params.wmh.spm.segment.tpm.skull = fullfile (params.global.directories.spm12, 'tpm', 'TPM.nii,4');
params.wmh.spm.segment.tpm.scalp = fullfile (params.global.directories.spm12, 'tpm', 'TPM.nii,5');
params.wmh.spm.segment.tpm.background = fullfile (params.global.directories.spm12, 'tpm', 'TPM.nii,6');
params.wmh.spm.segment.channels = spm_seg_channels; % options : 'T1+FLAIR', 'FLAIR'

wmh_params_finishTime = toc (wmh_params_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), wmh_params_finishTime);
fprintf ('%s :\n', mfilename);