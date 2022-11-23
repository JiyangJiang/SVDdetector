%
% 1st level clusters are regions segmented by methods such as kmeans, superpixels, etc.
%
% varargin{1} = index
function [lv1clstrs_dat, ud2param] = wmh_ud2_postproc_classification_1stLvClstrs (ud2param, in_nii, out_nii, varargin)

wmh_ud2_postproc_classification_1stLvClstrs_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

if nargin == 4
	idx = varargin{1};
	if ud2param.exe.verbose
		fprintf ('%s : Generating %s''s 1st-level clusters.\n', mfilename, ud2param.lists.subjs{idx,1});
	end
end

vol = spm_vol (in_nii);
dat = spm_read_vols (vol);

% zero nan
dat(isnan(dat)) = 0;


% volume segmentation using k-means (1st-level clusters)
switch ud2param.classification.lv1clstr_method

	case 'kmeans'

		lv1clstrs_dat = wmh_ud2_postproc_classification_1stLvClstrs_kmeans (ud2param, dat);

	case 'superpixels'

		[ud2param, lv1clstrs_dat] = wmh_ud2_postproc_classification_1stLvClstrs_superpixels (ud2param, dat);
end

% write out 1st-level clusters
if  ~ud2param.exe.save_dskspc

	if ud2param.exe.verbose && nargin==4
		fprintf ('%s : Writing out %s''s 1st-level clusters to %s.\n', mfilename, ud2param.lists.subjs{idx,1}, out_nii);
	elseif ud2param.exe.verbose && nargin==3
		fprintf ('%s : Writing out 1st-level clusters to %s.\n', mfilename, out_nii);
	end

	wmh_ud2_scripts_writeNii (ud2param, ...
							   vol, ...
							   lv1clstrs_dat, ...
							   out_nii);
end

wmh_ud2_postproc_classification_1stLvClstrs_finishTime = toc (wmh_ud2_postproc_classification_1stLvClstrs_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), wmh_ud2_postproc_classification_1stLvClstrs_finishTime);
fprintf ('%s :\n', mfilename);