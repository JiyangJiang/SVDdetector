function f_tbl = wmh_ud2_postproc_classification_extFeatures (ud2param,flair,t1,lv2clstrs_struct,varargin)

etime_extFeatures = tic;

if nargin == 5
	subjid = ud2param.lists.subjs{varargin{1},1};
end

if ud2param.exe.verbose && nargin==5
	fprintf ('%s : Extracting features for %s.\n', mfilename, subjid);
end

% load essential images
if ud2param.exe.verbose
	fprintf ('%s : Loading T1w and FLAIR images (subject ID = %s).\n', mfilename, subjid);
end
t1_dat    = spm_read_vols (spm_vol (t1));
flair_dat = spm_read_vols (spm_vol (flair));
t1_dat    (isnan(t1_dat))    =0;
flair_dat (isnan(flair_dat)) =0;

if ud2param.exe.verbose
	fprintf ('%s : Loading GM and WM masks (subject ID = %s).\n', mfilename, subjid);
end
gmmsk_dat = spm_read_vols (spm_vol (ud2param.templates.gmmsk));
wmmsk_dat = spm_read_vols (spm_vol (ud2param.templates.wmmsk));

if ud2param.exe.verbose
	fprintf ('%s : Loading GM, WM, and CSF probability maps, and ventricular distance map (subject ID = %s).\n', mfilename, subjid);
end
gmprob_dat  = spm_read_vols (spm_vol (ud2param.templates.gmprob));
wmprob_dat  = spm_read_vols (spm_vol (ud2param.templates.wmprob));
csfprob_dat = spm_read_vols (spm_vol (ud2param.templates.csfprob));

ventdst_dat = spm_read_vols (spm_vol (ud2param.templates.ventdst));

% mean intensities
if ud2param.exe.verbose
	fprintf ('%s : Calculating mean intensity of GM and WM on T1w and FLAIR (subject ID = %s).\n', mfilename, subjid);
end
meanInt_GMonT1    = mean(nonzeros(t1_dat    .* gmmsk_dat));
meanInt_WMonT1    = mean(nonzeros(t1_dat    .* wmmsk_dat));
meanInt_GMonFLAIR = mean(nonzeros(flair_dat .* gmmsk_dat));
meanInt_WMonFLAIR = mean(nonzeros(flair_dat .* wmmsk_dat));

% initialise feature table
if ud2param.exe.verbose
	fprintf ('%s : Initialising feature table (subject ID = %s).\n', mfilename, subjid);
end
Nclstrs = sum([lv2clstrs_struct(:).NumObjects]);

f_names = {'1stLvClstrIdx'; '2ndLvClstrIdx'
		   'clstrOverGmOnT1'; 'clstrOverGmOnFLAIR'; 'clstrOverWmOnT1'; 'clstrOverWmOnFLAIR'
		   'logSize'
		   'avgGmProb'; 'avgWmProb'; 'avgCsfProb'
		   'avgVentDst'
		   'cent_x'; 'cent_y'; 'cent_z'};

f_varType = cell(14,1);
f_varType(:) = {'uint8'
				'uint32'
				'double'
				'double'
				'double'
				'double'
				'double'
				'double'
				'double'
				'double'
				'double'
				'double'
				'double'
				'double'}; 	% to match data class in built-in kNN model which has all features in double.
							% 1st and 2nd columns are for lv1 and lv2 index.

f_tbl = table ('Size', [Nclstrs 14], ...
			   'VariableTypes', f_varType, ...
			   'VariableNames', f_names);

if nargin==5
	f_tbl.Properties.Description = ['Feature table for ' subjid];
else
	f_tbl.Properties.Description = 'Feature table';
end

f_tbl.Properties.VariableDescriptions = {'index in 1st-level clusters'
										 'index in 2nd-level clusters'
										 'ratio of intensities between cluster and GM on T1'
										 'ratio of intensities between cluster and GM on FLAIR'
										 'ratio of intensities between cluster and WM on T1'
										 'ratio of intensities between cluster and WM on FLAIR'
										 'log-transformed cluster size'
										 'average GM probabilities of the cluster'
										 'average WM probabilities of the cluster'
										 'average CSF probabilities of the cluster'
										 'average distance of the cluster from lateral ventricles'
										 'centroid''s x coordinate'
										 'centroid''s y coordinate'
										 'centroid''s z coordinate'};

f_tbl_rname = cell(Nclstrs, 1);

switch ud2param.classification.lv1clstr_method
case 'kmeans'
	Nlv1clstrs = ud2param.classification.k4kmeans;
case 'superpixels'
	Nlv1clstrs = ud2param.classification.n4superpixel_actual;
end

% extract features
if ud2param.exe.verbose
	fprintf ('%s : Start calculating features (subject ID = %s).\n', mfilename, subjid);
end

for i = 1 : Nlv1clstrs

	lv2clstrs = labelmatrix (lv2clstrs_struct(i));
	lv2clstrs_props = regionprops3(lv2clstrs_struct(i),flair_dat,'WeightedCentroid');

	switch ud2param.classification.lv1clstr_method
	case 'kmeans'
		Nlv2clstrs = lv2clstrs_struct(i).NumObjects;
	case 'superpixels'
		Nlv2clstrs = 1;
	end

	for j = 1 : Nlv2clstrs

		lin_idx = j + sum([lv2clstrs_struct(1:(i-1)).NumObjects]);

		if ud2param.exe.verbose
			fprintf ('%s : %s/%s 1st-level clusters, %s/%s 2nd-level clusters, linear_idx=%s/%s', mfilename, ...
																								  num2str(i), ...
																								  num2str(Nlv1clstrs), ...
																								  num2str(j), ...
																								  num2str(lv2clstrs_struct(i).NumObjects), ...
																								  num2str(lin_idx), ...
																								  num2str(Nclstrs));
			if nargin==5
				fprintf (' (subject ID = %s).\n', subjid);
			else
				fprintf ('.\n');
			end
		end

		clstr = lv2clstrs;
		clstr (clstr ~= j) = 0;
		clstr (clstr == j) = 1;
		clstr = double (clstr);

		clstr_sz = nnz(clstr);

		f_tbl.(f_names{1})(lin_idx)  = uint8(i);
		f_tbl.(f_names{2})(lin_idx)  = uint32(j);
		f_tbl.(f_names{3})(lin_idx)  = mean(nonzeros(clstr .* t1_dat))    / meanInt_GMonT1;
		f_tbl.(f_names{4})(lin_idx)  = mean(nonzeros(clstr .* flair_dat)) / meanInt_GMonFLAIR;
		f_tbl.(f_names{5})(lin_idx)  = mean(nonzeros(clstr .* t1_dat))    / meanInt_WMonT1;
		f_tbl.(f_names{6})(lin_idx)  = mean(nonzeros(clstr .* flair_dat)) / meanInt_WMonFLAIR;
		f_tbl.(f_names{7})(lin_idx)  = log10(clstr_sz);
		f_tbl.(f_names{8})(lin_idx)  = sum(nonzeros(clstr .* gmprob_dat))  / clstr_sz;
		f_tbl.(f_names{9})(lin_idx)  = sum(nonzeros(clstr .* wmprob_dat))  / clstr_sz;
		f_tbl.(f_names{10})(lin_idx) = sum(nonzeros(clstr .* csfprob_dat)) / clstr_sz;
		f_tbl.(f_names{11})(lin_idx) = sum(nonzeros(clstr .* ventdst_dat)) / clstr_sz;
		f_tbl.(f_names{12})(lin_idx) = lv2clstrs_props.WeightedCentroid(j,2); % x- and y-coordinate need to be flipped
		f_tbl.(f_names{13})(lin_idx) = lv2clstrs_props.WeightedCentroid(j,1); % according to visual inspection.
		f_tbl.(f_names{14})(lin_idx) = lv2clstrs_props.WeightedCentroid(j,3);



		f_tbl_rname{lin_idx,1} = [num2str(i) '_' num2str(j)];
	end
end

if ud2param.exe.verbose
	fprintf ('%s : Finished calculating features (subject ID = %s).\n', mfilename, subjid);
end

f_tbl.Properties.RowNames = f_tbl_rname;

elapsedTimeExtFeatures = toc (etime_extFeatures);

% save f_tbl
if ~ud2param.exe.save_dskspc && nargin==5
	fprintf ('%s : Saving feature table for %s.\n', mfilename, subjid);
	save (fullfile (ud2param.dirs.subjs, subjid, 'wmh', 'ud2', 'postproc', 'f_tbl.mat'), 'f_tbl');
elseif ~ud2param.exe.save_dskspc && nargin==4
	[flair_dir,~,~] = fileparts (flair);
	fprintf ('%s : Since no index is passed as argument, feature table is saved to the dir containing flair: \n', mfilename);
	fprintf ('%s : %s.\n', mfilename, flair_dir);
	save (fullfile (flair_dir,'f_tbl.mat'), 'f_tbl');
end

if ud2param.exe.verbose
	fprintf ('%s : Finished (%s; %s minutes elapsed', mfilename, string(datetime), num2str(elapsedTimeExtFeatures/60));
	if nargin==5
		fprintf ('; subject ID = %s).\n', subjid);
	else
		fprintf (').\n');
	end
end