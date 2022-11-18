
% SENARIO 1
%
% 	Standard call for CNS2 UBO Detector. In this case, 4 arguments are required:
% 	a) 'wmhmask_dat' through calling spm_read_vols and spm_vol, b) path to 'flair',
% 	c) varargin{1} = ud2param, and d) varargin{2} = index used in ud2. The script 
% 	will quantify measures for the index in defined in ud2param.
%
%
% SENARIO 2
%
% 	WMH masks are extracted by other software, e.g. BIANCA, and this script is called
% 	only for extracting global WMH measures, including whole brain WMH volumes, total
% 	number of WMH clusters, average WMH cluster distance, and variance in size between
% 	WMH clusters. In this case, only 'wmhmask_dat' through calling spm_read_vols and
% 	spm_vol, and path to 'flair' are required as arguments.
%
%
% SENARIO 3
%
% 	WMH masks are extracted by other software, e.g. BIANCA, and this scripts is called
% 	to extract the full array of measures as standard UBO Detector. In this case,
%   ---=== TBC ===---
% 	
%
% flair is used for 2 purposes: 1) calculate voxel size (spatial resolution)
%                               2) find weighted centroid


function quant_tbl_subj = wmh_ud2_postproc_quantification (wmhmask_dat,flair,varargin)

wmh_ud2_postproc_quantification_startTime = tic;
fprintf ('%s :\n', mfilename);

% ++++++++++++++++++++++++
% standard call in UD2
% ++++++++++++++++++++++++
if nargin==4

	ud2param = varargin{1};
	idx       = varargin{2};

	subjid = ud2param.lists.subjs{idx,1};

	fprintf ('%s : Started (%s; subject ID = %s).\n', mfilename, string (datetime), subjid);
	
	% quantify volume
	if ud2param.exe.verbose
		fprintf ('%s : Calling wmh_ud2_postproc_quantification_vol to quantify volumes (subject ID = %s).\n', mfilename, subjid);
	end

	vol_tbl = wmh_ud2_postproc_quantification_vol (wmhmask_dat,flair,ud2param,subjid);

	if ud2param.exe.verbose
		fprintf ('%s : Volumes have been quantified (subject ID = %s).\n', mfilename, subjid);
	end


	% quantify number of clusters
	if ud2param.exe.verbose
		fprintf ('%s : Calling wmh_ud2_postproc_quantification_noc to quantify number of clusters (subject ID = %s).\n', mfilename, subjid);
	end

	noc_tbl = wmh_ud2_postproc_quantification_noc (wmhmask_dat,flair,ud2param,subjid);

	if ud2param.exe.verbose
		fprintf ('%s : Number of clusters have been quantified (subject ID = %s).\n', mfilename, subjid);
	end


	% quantify distance
	if ud2param.exe.verbose
		fprintf ('%s : Calling wmh_ud2_postproc_quantification_noc to quantify distance measures (subject ID = %s).\n', mfilename, subjid);
	end

	dist_tbl = wmh_ud2_postproc_quantification_clstrDist (wmhmask_dat,flair,ud2param,subjid);

	if ud2param.exe.verbose
		fprintf ('%s : Distance measures have been quantified (subject ID = %s).\n', mfilename, subjid);
	end


	% quantify cluster size distribution
	if ud2param.exe.verbose
		fprintf ('%s : Calling wmh_ud2_postproc_quantification_clstrSiz to quantify cluster size distribution (subject ID = %s).\n', mfilename, subjid);
	end

	clstrSiz_tbl = wmh_ud2_postproc_quantification_clstrSiz (wmhmask_dat,flair,ud2param,subjid);

	if ud2param.exe.verbose
		fprintf ('%s : Cluster size distribution have been quantified (subject ID = %s).\n', mfilename, subjid);
	end


	% combine measures into one table
	if ud2param.exe.verbose
		fprintf ('%s : All measures have been quantified. Merging into quant_tbl_subj (subject ID = %s).\n', mfilename, subjid);
	end

	quant_tbl_subj = [table({subjid}) ...
					  vol_tbl ...
					  noc_tbl ...
					  dist_tbl ...
					  clstrSiz_tbl];

	quant_tbl_subj.Properties.VariableNames{'Var1'} = 'subjID';

	if ud2param.exe.verbose
		fprintf ('%s : Done merging into quant_tbl_subj (subject ID = %s).\n', mfilename, subjid);
	end


% +++++++++++++++++++++++++++++++++++++++++++++++++++++
% only global measures on wmh segmented by any software
% +++++++++++++++++++++++++++++++++++++++++++++++++++++
elseif nargin==2
	
	fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

	% quantify volume
	if ud2param.exe.verbose
		fprintf ('%s : Calling wmh_ud2_postproc_quantification_vol to quantify volumes (subject ID = %s).\n', mfilename, subjid);
	end

	vol_tbl = wmh_ud2_postproc_quantification_vol (wmhmask_dat,flair);

	if ud2param.exe.verbose
		fprintf ('%s : Volumes have been quantified (subject ID = %s).\n', mfilename, subjid);
	end


	% quantify number of clusters
	if ud2param.exe.verbose
		fprintf ('%s : Calling wmh_ud2_postproc_quantification_noc to quantify number of clusters (subject ID = %s).\n', mfilename, subjid);
	end

	noc_tbl = wmh_ud2_postproc_quantification_noc (wmhmask_dat,flair);

	if ud2param.exe.verbose
		fprintf ('%s : Number of clusters have been quantified (subject ID = %s).\n', mfilename, subjid);
	end


	% quantify distance
	if ud2param.exe.verbose
		fprintf ('%s : Calling wmh_ud2_postproc_quantification_noc to quantify distance measures (subject ID = %s).\n', mfilename, subjid);
	end

	dist_tbl = wmh_ud2_postproc_quantification_clstrDist (wmhmask_dat,flair);

	if ud2param.exe.verbose
		fprintf ('%s : Distance measures have been quantified (subject ID = %s).\n', mfilename, subjid);
	end


	% quantify cluster size distribution
	if ud2param.exe.verbose
		fprintf ('%s : Calling wmh_ud2_postproc_quantification_clstrSiz to quantify cluster size distribution (subject ID = %s).\n', mfilename, subjid);
	end

	clstrSiz_tbl = wmh_ud2_postproc_quantification_clstrSiz (wmhmask_dat,flair);

	if ud2param.exe.verbose
		fprintf ('%s : Cluster size distribution have been quantified (subject ID = %s).\n', mfilename, subjid);
	end


	% combine measures into one table
	if ud2param.exe.verbose
		fprintf ('%s : All measures have been quantified. Merging into quant_tbl_subj (subject ID = %s).\n', mfilename, subjid);
	end

	quant_tbl_subj = [vol_tbl ...
				 	  noc_tbl ...
				 	  dist_tbl ...
				 	  clstrSiz_tbl];

	if ud2param.exe.verbose
		fprintf ('%s : Done merging into quant_tbl_subj (subject ID = %s).\n', mfilename, subjid);
	end


% ++++++++++++++++++++++++++++++++++++++++++++++++++
% both global and regional measures on wmh segmented
% by any software
% ++++++++++++++++++++++++++++++++++++++++++++++++++
elseif nargin==3 && strcmp(varargin{1},'allMeas')
	%
	% TO BE DONE
	%
	% run preproc
	% reverse flowmap
	% bring templates/atlas to native
	% set ud2param
end

wmh_ud2_postproc_quantification_finishTime = toc (wmh_ud2_postproc_quantification_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed; subject ID = %s).\n', mfilename, string(datetime), ...
				wmh_ud2_postproc_quantification_finishTime, subjid);
fprintf ('%s :\n', mfilename);