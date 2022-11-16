function lv2clstrs_struct = wmh_ud2_postproc_classification_2ndLvClstrs (ud2param, lv1clstrs_dat, vol, out_nii, varargin)

curr_cmd = mfilename;

if nargin == 5
	idx = varargin{1};
end

if ud2param.exe.verbose && nargin==4
	fprintf ('%s : generating %s''s 2nd-level clusters.\n', curr_cmd, ud2param.lists.subjs{idx,1});
end

switch ud2param.ud.classification.lv1clstr_method
case 'kmeans'
	Nlv1clstrs = ud2param.ud.classification.k4kmeans;
case 'superpixel'
	Nlv1clstrs = ud2param.ud.classification.n4superpixel_actual;
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
if  ~ud2param.exe.save_more_dskspc && ~strcmp(ud2param.ud.classification.lv1clstr_method,'superpixel')
	if ud2param.exe.verbose && nargin==5
		fprintf ('%s : writing %s''s 2nd-level clusters.\n', curr_cmd, ud2param.lists.subjs{idx,1});
	elseif ud2param.exe.verbose && nargin==4
		fprintf ('%s : writing 2nd-level clusters.\n', curr_cmd);
	end
	cns2_scripts_writeNii (ud2param, ...
						   vol, ...
						   lv2clstrs_dat, ...
						   out_nii, ...
						   '4d');
end