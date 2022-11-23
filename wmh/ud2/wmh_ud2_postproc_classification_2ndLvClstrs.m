%
% 2nd level clusters are voxelx connected with 6-connectivity on 1st level cluster.
%
function lv2clstrs_struct = wmh_ud2_postproc_classification_2ndLvClstrs (ud2param, lv1clstrs_dat, vol, out_nii, varargin)

wmh_ud2_postproc_classification_2ndLvClstrs_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

if nargin == 5
	idx = varargin{1};
end

if ud2param.exe.verbose && nargin==4
	fprintf ('%s : Generating %s''s 2nd-level clusters.\n', mfilename, ud2param.lists.subjs{idx,1});
end

switch ud2param.classification.lv1clstr_method
	case 'kmeans'
		Nlv1clstrs = ud2param.classification.k4kmeans;
	case 'superpixels'
		Nlv1clstrs = ud2param.classification.n4superpixel_actual;
end

% initialise to resolve the parfor classification issue
lv2clstrs_dat = zeros ([size(lv1clstrs_dat) Nlv1clstrs]);

for k = 1 : Nlv1clstrs
	tmp = lv1clstrs_dat;
	tmp (tmp ~= k) = 0;
	tmp (tmp == k) = 1;
	lv2clstrs_struct(k) = bwconncomp (tmp, 6); % 6-connectivity
	lv2clstrs_dat (:,:,:,k) = labelmatrix (lv2clstrs_struct (k));
end
clearvars tmp;

% write out 2nd-level clusters
% not saving for superpixel because too many
if  ~ud2param.exe.save_more_dskspc && ~strcmp(ud2param.classification.lv1clstr_method,'superpixel')
	if ud2param.exe.verbose && nargin==5
		fprintf ('%s : writing %s''s 2nd-level clusters to %s.\n', mfilename, ud2param.lists.subjs{idx,1}, out_nii);
	elseif ud2param.exe.verbose && nargin==4
		fprintf ('%s : writing 2nd-level clusters to %s.\n', mfilename, out_nii);
	end
	wmh_ud2_scripts_writeNii (ud2param, ...
							   vol, ...
							   lv2clstrs_dat, ...
							   out_nii, ...
							   '4d');
end

wmh_ud2_postproc_classification_2ndLvClstrs_finishTime = toc (wmh_ud2_postproc_classification_2ndLvClstrs_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), wmh_ud2_postproc_classification_2ndLvClstrs_finishTime);
fprintf ('%s :\n', mfilename);