function [wmhprob_dat,wmhmask_dat] = wmh_ud2_postproc_classification_predict (ud2param,lv2clstrs_struct,f_tbl,mdl,vol,idx)

subjid = ud2param.lists.subjs{idx,1};

if ud2param.exe.verbose
	fprintf ('%s : Predicting WMH (subject ID = %s).\n', mfilename, subjid);
end

% only use 3:11 columns as 1:2 columns are 1st-level and 2nd-level
% cluster index, and 12:14 columns are centroid coordinates
[~,score,~] = predict (mdl, f_tbl(:,3:11));

% add the probability to the last column of feature table
if ud2param.exe.verbose
	fprintf ('%s : Adding the predicted WMH probability to the last column in the feature table (subject ID = %s).\n', mfilename, subjid);
end

wmhprob = score (:,2);
fd_tbl = [f_tbl table(wmhprob)];

if ~ud2param.exe.save_more_dskspc

	if ud2param.exe.verbose
		fprintf ('%s : Saving feature table to %s (subject ID = %s).\n', mfilename, fullfile (ud2param.dirs.subjs, subjid, 'wmh', 'ud2', 'wmh', 'fd_tbl.mat'), subjid);
	end

	save (fullfile (ud2param.dirs.subjs, subjid, 'wmh', 'ud2', 'wmh', 'fd_tbl.mat'), 'fd_tbl');

	if ud2param.exe.verbose
		fprintf ('%s : Saving feature table to %s (subject ID = %s).\n', mfilename, fullfile (ud2param.dirs.subjs, subjid, 'wmh', 'ud2', 'wmh', 'fd_tbl.mat'), subjid);
	end

end

% assign label to 2nd-level clusters
if ud2param.exe.verbose
	fprintf ('%s : Generating data matrix with WMH probability (subject ID = %s).\n', mfilename, subjid);
end
switch ud2param.classification.lv1clstr_method
case 'kmeans'
	Nlv1clstrs = ud2param.classification.k4kmeans;
case 'superpixel'
	Nlv1clstrs = ud2param.classification.n4superpixel_actual;
end

wmhprob_dat=zeros(size(labelmatrix(lv2clstrs_struct(1)))); % initialise

for i = 1 : Nlv1clstrs

	lv2clstrs = single(labelmatrix(lv2clstrs_struct(i)));
	
	switch ud2param.classification.lv1clstr_method
	case 'kmeans'
		Nlv2clstrs = lv2clstrs_struct(i).NumObjects;
	case 'superpixel'
		Nlv2clstrs = 1;
	end

	for j = 1 : Nlv2clstrs
		lin_idx = j + sum([lv2clstrs_struct(1:(i-1)).NumObjects]);
		lv2clstrs(lv2clstrs==j)=wmhprob(lin_idx);
	end

	wmhprob_dat=wmhprob_dat+lv2clstrs;
end

% write to wmhprob nifti
if ud2param.exe.verbose
	fprintf ('%s : Writng out WMH probability map to %s (subject ID = %s).\n', mfilename, fullfile (ud2param.dirs.subjs, subjid, 'wmh', 'ud2', 'wmh', 'wmhprob.nii'), subjid);
end
wmh_ud2_scripts_writeNii (ud2param, ...
					   vol, ...
					   wmhprob_dat, ...
					   fullfile (ud2param.dirs.subjs, subjid, 'wmh', 'ud2', 'wmh', 'wmhprob.nii'));
if ud2param.exe.verbose
	fprintf ('%s : WMH probability map has been written (subject ID = %s).\n', mfilename, subjid);
end

% write wmhmask nifti
if ud2param.exe.verbose
	fprintf ('%s : Writing out WMH binary mask by applying a probability threshold of %.2f to the WMH probability map (subject ID = %s).\n', mfilename, ...
				ud2param.classification.probthr, subjid);
end
wmhmask_dat = wmhprob_dat > ud2param.classification.probthr;
wmh_ud2_scripts_writeNii (ud2param, ...
					   vol, ...
					   wmhmask_dat, ...
					   fullfile (ud2param.dirs.subjs, subjid, 'wmh', 'ud2', 'wmh', 'wmhmask.nii'));
if ud2param.exe.verbose
	fprintf ('%s : WMH binary mask has been written (subject ID = %s).\n', mfilename, subjid);
end