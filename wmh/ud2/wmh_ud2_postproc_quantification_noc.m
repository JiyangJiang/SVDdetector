% varargin{1} = ud2param
% varargin{2} = subject's id in cns2

function noc_tbl = wmh_ud2_postproc_quantification_noc (wmhmask_dat,flair,varargin)

wmh_ud2_postproc_quantification_noc_startTime = tic;

fprintf ('%s : \n', mfilename);

% default size threshold
% used in wmh results from any software
thr = [3 9 15]; % in num of vox


% ++++++++++++++++++++++++++
% standard call from ud2
% ++++++++++++++++++++++++++
if nargin==4

	ud2param = varargin{1};
	subjid    = varargin{2};

	fprintf ('%s : Started (%s; subject ID = %s).\n', mfilename, string(datetime), subjid);

	if ud2param.exe.verbose
		fprintf ('%s : Start quantifying number of clusters (subject ID = %s).\n', mfilename, subjid);
	end

	% convert size cut-off in mm^3 to num of vox
	ni = niftiinfo (flair);
	voxSiz = ni.PixelDimensions(1) * ni.PixelDimensions(2) * ni.PixelDimensions(3);
	thr = round (ud2param.quantification.ud.sizthr / voxSiz);

	wmhclstrs_struct = bwconncomp (wmhmask_dat, 26); % divide into 26-conn clusters

	wmhclstrs_props = regionprops3 (wmhclstrs_struct,...
									spm_read_vols(spm_vol(flair)),...
									{'WeightedCentroid','Volume'});

	wbwmh_noc   = wmhclstrs_struct.NumObjects; % whole brain noc
	wbwmh_noc_p = 0;
	wbwmh_noc_f = 0;
	wbwmh_noc_m = 0;
	wbwmh_noc_c = 0;


	% quantify whole brain noc of different sizes
	% ===========================================
	for i = 1:wbwmh_noc

		% coordinates
		% NOTE that the 1st and 2nd dimension need to
		%      be flipped after visual inspection, to
		%      correspond to the correct position on
		%      nifti images.
		x = round(wmhclstrs_props.WeightedCentroid(i,2));
		y = round(wmhclstrs_props.WeightedCentroid(i,1));
		z = round(wmhclstrs_props.WeightedCentroid(i,3));

		% size in num of voxels
		siz = wmhclstrs_props.Volume(i);

		if siz <= thr(1)
			wbwmh_noc_p = wbwmh_noc_p + 1;
	  	elseif siz > thr(1) && siz <= thr(2)
	  		wbwmh_noc_f = wbwmh_noc_f + 1;
		elseif siz > thr(2) && siz <= thr(3)
			wbwmh_noc_m = wbwmh_noc_m + 1;
		else
			wbwmh_noc_c = wbwmh_noc_c + 1;
		end

	end

	% quantify lobar noc
	% ===================
	if ud2param.exe.verbose
		fprintf ('%s : Calling wmh_ud2_postproc_quantification_noc_lobar to quantify numbers of clusters in lobes (subject ID = %s).\n', mfilename, subjid);
	end

	lobar_noc_tbl = wmh_ud2_postproc_quantification_noc_lobar (ud2param,wmhclstrs_struct,flair);

	if ud2param.exe.verbose
		fprintf ('%s : Numbers of clusters in lobes have been quantified (subject ID = %s).\n', mfilename, subjid);
	end

	% quantify arterial noc
	% =====================
	if ud2param.exe.verbose
		fprintf ('%s : Calling wmh_ud2_postproc_quantification_noc_lobar to quantify numbers of clusters in arterial territories (subject ID = %s).\n', mfilename, subjid);
	end

	arterial_noc_tbl = wmh_ud2_postproc_quantification_noc_arterial (ud2param,wmhclstrs_struct,flair);

	if ud2param.exe.verbose
		fprintf ('%s : Numbers of clusters in arterial territories have been quantified (subject ID = %s).\n', mfilename, subjid);
	end

	% output table
	% =============
	noc_tbl =  [table(wbwmh_noc, wbwmh_noc_p, wbwmh_noc_f, wbwmh_noc_m, wbwmh_noc_c) ...
				lobar_noc_tbl ...
				arterial_noc_tbl];


	if ud2param.exe.verbose
		fprintf ('%s : Finished quantifying number of clusters (subject ID = %s).\n', mfilename, subjid);
	end


% ++++++++++++++++++++++++++++++++++++++++
% only global wmh noc
% can be used on results from any software
% ++++++++++++++++++++++++++++++++++++++++
elseif nargin==2

	wmhclstrs_struct = bwconncomp (wmhmask_dat, 26); % divide into 26-conn clusters

	wmhclstrs_props = regionprops3 (wmhclstrs_struct,...
									spm_read_vols(spm_vol(flair)),...
									{'WeightedCentroid','Volume'});

	wbwmh_noc = wmhclstrs_struct.NumObjects; % whole brain noc
	wbwmh_noc_p = 0;
	wbwmh_noc_f = 0;
	wbwmh_noc_m = 0;
	wbwmh_noc_c = 0;

	% quantify whole brain noc of different sizes
	% ===========================================
	for i = 1:wbwmh_noc

		% size in num of voxels
		siz = wmhclstrs_props.Volume(i);

		if siz <= thr(1)
			wbwmh_noc_p = wbwmh_noc_p + 1;
	  	elseif siz > thr(1) && siz <= thr(2)
	  		wbwmh_noc_f = wbwmh_noc_f + 1;
		elseif siz > thr(2) && siz <= thr(3)
			wbwmh_noc_m = wbwmh_noc_m + 1;
		else
			wbwmh_noc_c = wbwmh_noc_c + 1;
		end

	end

	noc_tbl = table(wbwmh_noc, wbwmh_noc_p, wbwmh_noc_f, wbwmh_noc_m, wbwmh_noc_c);



% +++++++++++++++++++++++++++++++++++++++++++
% noc in regions, and categorised in sizes.
% can be used on results from any software
% +++++++++++++++++++++++++++++++++++++++++++
elseif nargin==3

	% TO BE DONE

end

wmh_ud2_postproc_quantification_noc_finishTime = toc (wmh_ud2_postproc_quantification_noc_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed; subject ID = %s).\n', mfilename, string(datetime), ...
				wmh_ud2_postproc_quantification_noc_finishTime, subjid);
fprintf ('%s :\n', mfilename);