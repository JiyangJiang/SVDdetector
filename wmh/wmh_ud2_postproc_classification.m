
function [wmhprob_dat,wmhmask_dat] = wmh_ud2_postproc_classification (ud2param,flair,t1,i)

wmh_ud2_postproc_classification_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s; subject ID = %s).\n', mfilename, string(datetime), ud2param.lists.subjs{i,1});

if ud2param.exe.verbose
	fprintf ('%s : Start WMH vs. non-WMH classification (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end


% 1st-level clusters
% ++++++++++++++++++
if ud2param.exe.verbose
	fprintf ('%s : Calling wmh_ud2_postproc_classification_1stLvClstrs for 1st-level clustering (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
	fprintf ('%s : ''%s'' will be used for 1st-level clustering (subject ID = %s).\n', mfilename, ud2param.classification.lv1clstr_method, ud2param.lists.subjs{i,1});
end

[lv1clstrs_dat,ud2param] = wmh_ud2_postproc_classification_1stLvClstrs (ud2param, ...
																		 flair, ...
																		 fullfile (ud2param.dirs.subjs, ...
																		 		   ud2param.lists.subjs{i,1}, ...
																		 		   'ud2', ...
																		 		   'postproc', ...
																		 		   'lv1clstrs.nii'), ...
																		 i);

if ud2param.exe.verbose
	fprintf ('%s : 1st-level clustering using ''%s'' completed (subject ID = %s).\n', mfilename, ud2param.classification.lv1clstr_method, ud2param.lists.subjs{i,1});
end


% 2nd-level clusters
% ++++++++++++++++++
if ud2param.exe.verbose
	fprintf ('%s : Calling wmh_ud2_postproc_classification_2ndLvClstrs for 2nd-level clustering (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end

lv2clstrs_struct = wmh_ud2_postproc_classification_2ndLvClstrs (ud2param, ...
																    lv1clstrs_dat, ...
																    spm_vol(flair), ...
																    fullfile (ud2param.dirs.subjs, ...
																    		  ud2param.lists.subjs{i,1}, ...
																    		  'ud2', ...
																    		  'postproc', ...
																    		  'lv2clstrs.nii'), ...
																    i);
if ud2param.exe.verbose
	fprintf ('%s : 2nd-level clustering completed (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end


% extract features
% ++++++++++++++++
if ud2param.exe.verbose
	fprintf ('%s : Extracting features for the following kNN prediction (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end
f_tbl = wmh_ud2_postproc_classification_extFeatures (ud2param, ...
														 flair, ...
														 t1, ...
														 lv2clstrs_struct, ...
														 i);
if ud2param.exe.verbose
	fprintf ('%s : Feature extraction completed (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end

% % predict
% % +++++++++++++++
if ud2param.exe.verbose
	fprintf ('%s : Start predicting WMH using kNN classifier (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
	fprintf ('%s : Loading embedded default kNN classification model (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end

mdl = loadLearnerForCoder(fullfile (ud2param.dirs.ud2, ...
									'wmh_ud2_postproc_classification_knnMdl.mat'));

if ud2param.exe.verbose
	fprintf ('%s : Default kNN model loaded (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
	fprintf ('%s : Predicting WMH for new observation (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end

[wmhprob_dat, wmhmask_dat] = wmh_ud2_postproc_classification_predict   (ud2param,...
																			lv2clstrs_struct,...
																			f_tbl,...
																			mdl,...
																			spm_vol(flair),...
																			i);
if ud2param.exe.verbose
	fprintf ('%s : WMH prediction completed (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end

wmh_ud2_postproc_classification_finishTime = toc (wmh_ud2_postproc_classification_startTime);
fprintf ('%s : Finished (%s; %.4f minutes elapsed.\n', mfilename, string(datetime), wmh_ud2_postproc_classification_finishTime/60);
fprintf ('%s :\n', mfilename);

