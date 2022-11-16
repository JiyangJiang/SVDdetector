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
switch ud2param.ud.classification.lv1clstr_method

	case 'kmeans'

		if ud2param.exe.verbose
			fprintf ('%s : Using k-means to generate 1st-level clusters.\n', mfilename);
		end

		lv1clstrs_dat = imsegkmeans3 (single(dat), ud2param.ud.classification.k4kmeans, ...
										'NormalizeInput', true);

		% get rid of 1st-level clusters outside brain
		if ud2param.exe.verbose
			fprintf ('%s : Excluding k-means output outside brain.\n', mfilename);
		end

		brn = dat;
		brn(brn>0)=1;
		brn(brn<=0)=0;
		lv1clstrs_dat = lv1clstrs_dat .* uint8(brn);
		clearvars brn;

	case 'superpixel'

		if ud2param.exe.verbose
			fprintf ('%s : Using superpixes to generate 1st-level clusters.\n', mfilename);
		end

		[lv1clstrs_dat,Nlabels] = superpixels3 (dat, ud2param.ud.classification.n4superpixel);


		% exclude superpixel regions with mean intensity in the bottom 95%
		if ud2param.exe.verbose
			fprintf ('%s : Excluding superpixel regions with mean intensity in the bottom 95%.\n', mfilename);
		end

		msk = zeros(size(lv1clstrs_dat));
		idxList = label2idx (lv1clstrs_dat);
		for sp = 1 : Nlabels
			msk(idxList{sp}) = mean(dat(idxList{sp}));
		end
		thr = prctile (msk,95,'all');
		msk(msk<thr) = 0;
		msk(msk>=thr) = 1;
		lv1clstrs_dat = lv1clstrs_dat .* msk;

		% assign serial numbers to intensity (1,2,3 ....)
		if ud2param.exe.verbose
			fprintf ('%s : Assigning a unique intensity to each superpixel region.\n', mfilename);
		end
		uniq = unique(lv1clstrs_dat);
		for i = 1:size(uniq,1)
			lv1clstrs_dat(lv1clstrs_dat==uniq(i))=i;
		end
		lv1clstrs_dat = lv1clstrs_dat - 1; % smallest in uniq was 0, and was assigned with 1.
										   % therefore minus 1.
		ud2param.ud.classification.n4superpixel_actual = size(uniq,1) - 1;
		clearvars msk idxList sp thr uniq;
end

% write out 1st-level clusters
if  ~ud2param.exe.save_dskspc

	if ud2param.exe.verbose && nargin==4
		fprintf ('%s : Writing out %s''s 1st-level clusters.\n', mfilename, ud2param.lists.subjs{idx,1});
	elseif ud2param.exe.verbose && nargin==3
		fprintf ('%s : Writing out 1st-level clusters.\n', mfilename);
	end

	cns2_scripts_writeNii (ud2param, ...
						   vol, ...
						   lv1clstrs_dat, ...
						   out_nii);
end

wmh_ud2_postproc_classification_1stLvClstrs_finishTime = toc (wmh_ud2_postproc_classification_1stLvClstrs_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), wmh_ud2_postproc_classification_1stLvClstrs_finishTime);
fprintf ('%s :\n', mfilename);