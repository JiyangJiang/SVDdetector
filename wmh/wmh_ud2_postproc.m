function quant_tbl_subj = wmh_ud2_postproc (ud2param,i)

wmh_ud2_postproc_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

if  ud2param.exe.verbose
	fprintf ('%s : Start postprocessing for %s.\n', mfilename, ud2param.lists.subjs{i,1});
end

% which flair/t1 to use for wmh segmentation
switch ud2param.classification.ext_space

	case 'dartel'

		if ud2param.exe.verbose
			fprintf ('%s : WMH will be extracted in DARTEL space.\n', mfilename);
		end
		flair  = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'ud2', 'preproc', 'wrflair_brn.nii');
		t1     = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'ud2', 'preproc', 'wt1_brn.nii');
		% apply WM mask if necessary in the future

	case 'native'

		% if extracting WMH in native space
		% refer to example above 'dartel'
		error ('%s : ''native'' space not implemented yet (line 24, wmh_ud2_postproc.m).\n', mfilename);

end

% preproc failure may result in error in finding flair/t1 for wmh segmentation
if ~ isfile (flair)
	ME = MException ('CNS2:postproc:preprocFlairNotFound', ...
					 '%s : %s''s preprocessed FLAIR is not found. This may be because preprocessing finished with ERROR.', ...
					 mfilename, ...
					 ud2param.lists.subjs{i,1});
	throw (ME);
end
if ~ isfile (t1)
	ME = MException ('CNS2:postproc:preprocT1NotFound', ...
					 '%s : %s''s preprocessed T1 is not found. This may be because preprocessing finished with ERROR.', ...
					 mfilename, ...
					 ud2param.lists.subjs{i,1});
	throw (ME);
end


% 1. classification
% +++++++++++++++++++++
if ud2param.exe.verbose
	fprintf ('%s : Calling wmh_ud2_postproc_classification for classifying WMH vs. non-WMH.\n', mfilename);
end

[~,wmhmask_dat] = wmh_ud2_postproc_classification (ud2param,flair,t1,i);


if ud2param.exe.verbose
	fprintf ('%s : Finished classifying WMH vs. non-WMH.\n', mfilename);
end

% 2. quantification
% +++++++++++++++++++++
if ud2param.exe.verbose
	fprintf ('%s : Calling wmh_ud2_postproc_quantification for quantifying WMH measures.\n', mfilename);
end

quant_tbl_subj = wmh_ud2_postproc_quantification (wmhmask_dat,flair,ud2param,i);

if ud2param.exe.verbose
	fprintf ('%s : Finished quantifying WMH measures.\n', mfilename);
end

wmh_ud2_postproc_finishTime = toc (wmh_ud2_postproc_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed.\n', mfilename, string(datetime), wmh_ud2_postproc_finishTime);
fprintf ('%s :\n', mfilename);

