% DESCRIPTION:
%
% This script save information regarding the nifti images
% to 'params'.
%
% USAGE:
%
% flairDistinctIntensityBtwGmWm = Whether GM and WM have
%								  distinguishable intensity
%								  on FLAIR (true/false).

function nii_params (flairDistinctIntensityBtwGmWm)

global params

nii_params_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

params.nii.flair.distinctIntensityBtwGmWm = flairDistinctIntensityBtwGmWm;

if flairDistinctIntensityBtwGmWm

	params.nii.flair.spm.segment.n_gaussians.combineGmWm = false;   % if FLAIR has distinguishable GM and WM intensiteis,
																	% not combine GM and WM as a single tissue class.
	params.nii.flair.spm.segment.n_gaussians.gwm = NaN;		% There is no GWM tissue class in this case.
	params.nii.flair.spm.segment.n_gaussians.gm = 2; 		% 
	params.nii.flair.spm.segment.n_gaussians.wm = 2; 		% Recommended setting in SPM  
	params.nii.flair.spm.segment.n_gaussians.csf = 2;		% GM=2, WM=2, CSF=2, skull=3, scalp=4, background=2
	params.nii.flair.spm.segment.n_gaussians.wmh = 3;
	params.nii.flair.spm.segment.n_gaussians.skull = 3;
	params.nii.flair.spm.segment.n_gaussians.scalp = 4;
	params.nii.flair.spm.segment.n_gaussians.background = 2;

else

	params.nii.flair.spm.segment.n_gaussians.combineGmWm = true; 	% if FLAIR does not have distinguishable GM
																	% and WM intensities, combine them to a single
																	% tissue class (GWM).
	params.nii.flair.spm.segment.n_gaussians.gwm = 3;
	params.nii.flair.spm.segment.n_gaussians.gm = NaN; % GM and WM are combined as a single tissue class.
	params.nii.flair.spm.segment.n_gaussians.wm = NaN;
	params.nii.flair.spm.segment.n_gaussians.csf = 2;
	params.nii.flair.spm.segment.n_gaussians.wmh = 3;
	params.nii.flair.spm.segment.n_gaussians.skull = 3;
	params.nii.flair.spm.segment.n_gaussians.scalp = 4;
	params.nii.flair.spm.segment.n_gaussians.background = 2;

end

nii_params_finishTime = toc (nii_params_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), nii_params_finishTime);
fprintf ('%s :\n', mfilename);