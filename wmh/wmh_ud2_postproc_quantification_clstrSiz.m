% varargin{1} = ud2param
% varargin{2} = subject's id in ud2
function clstrSiz_tbl = wmh_ud2_postproc_quantification_clstrSiz (wmhmask_dat,flair,varargin)

wmh_ud2_postproc_quantification_clstrSiz_startTime = tic;
fprintf ('%s : \n', mfilename);

if nargin==4
	ud2param = varargin{1};
	subjid   = varargin{2};

	fprintf ('%s : Started (%s; subject ID = %s).\n', mfilename, string(datetime), subjid);

	if ud2param.exe.verbose
		fprintf ('%s : Quantifying variance in WMH cluster sizes (subject ID = %s).\n', mfilename, subjid);
	end
end

% get voxel's spatial resolution
nii_info = niftiinfo(flair);
sptRes_x = nii_info.PixelDimensions(1);
sptRes_y = nii_info.PixelDimensions(2);
sptRes_z = nii_info.PixelDimensions(3);
sptRes = sptRes_x * sptRes_y * sptRes_z;

wmhclstrs_struct = bwconncomp (wmhmask_dat, 26); % divide into 26-conn clusters

wmhclstrs_props = regionprops3 (wmhclstrs_struct,...
								'Volume');

clstrSiz_tbl = table (mean(wmhclstrs_props.Volume * sptRes),...
					  std (wmhclstrs_props.Volume * sptRes),...
					  var (wmhclstrs_props.Volume * sptRes));

clstrSiz_tbl.Properties.VariableNames = {'avg_clstrSiz'
										 'std_clstrSiz'
										 'var_clstrSiz'};

wmh_ud2_postproc_quantification_clstrSiz_finishTime = toc (wmh_ud2_postproc_quantification_clstrSiz_startTime);

if nargin==4
	if ud2param.exe.verbose
		fprintf ('%s : Finished quantifying variance in WMH cluster sizes (subject ID = %s).\n', mfilename, subjid);
		fprintf ('%s : Finished (%s; %.4f seconds elapsed; subject ID = %s).\n', mfilename, string(datetime), ...
				wmh_ud2_postproc_quantification_clstrSiz_finishTime, subjid);
	end
else
	fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), ...
				wmh_ud2_postproc_quantification_clstrSiz_finishTime);
end

fprintf ('%s :\n', mfilename);