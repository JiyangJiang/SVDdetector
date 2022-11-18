% distance between each pair of clusters

% varargin{1} = ud2param
% varargin{2} = subject's id in cns2

function dist_tbl = wmh_ud2_postproc_quantification_clstrDist (wmhmask_dat,flair,varargin)

	wmh_ud2_postproc_quantification_clstrDist_startTime = tic;
	fprintf ('%s : \n', mfilename);

	if nargin==4

		ud2param = varargin{1};
		subjid   = varargin{2};

		fprintf ('%s : Started (%s; subject ID = %s).\n', mfilename, string(datetime), subjid);

		if ud2param.exe.verbose
			fprintf ('%s : Quantifying distance between WMH clusters (subject ID = %s).\n', mfilename, subjid);
		end
	end

	% get voxel's spatial resolution
	nii_info = niftiinfo(flair);
	sptRes_x = nii_info.PixelDimensions(1);
	sptRes_y = nii_info.PixelDimensions(2);
	sptRes_z = nii_info.PixelDimensions(3);

	wmhclstrs_struct = bwconncomp (wmhmask_dat, 26); % divide into 26-conn clusters

	wmhclstrs_props = regionprops3 (wmhclstrs_struct,...
									spm_read_vols(spm_vol(flair)),...
									'WeightedCentroid');

	if wmhclstrs_struct.NumObjects <= 1
		dist_tbl = table (NaN, NaN, NaN);
	elseif wmhclstrs_struct.NumObjects == 2
		% clstr_dist = pdist (wmhclstrs_props.WeightedCentroid, 'euclidean');
		% need to consider spatial resolution in x/y/z coordinate, i.e.
		% how many millimeters the voxel represent in x/y/z direction.
		clstr_dist = distInWorldCoord  (wmhclstrs_props.WeightedCentroid,...
										size(spm_read_vols(spm_vol(flair))),...
										sptRes_x,...
										sptRes_y,...
										sptRes_z);
		dist_tbl = table(mean(clstr_dist), NaN, NaN);
	else
		% clstr_dist = pdist (wmhclstrs_props.WeightedCentroid, 'euclidean');
		clstr_dist = distInWorldCoord  (wmhclstrs_props.WeightedCentroid,...
										size(spm_read_vols(spm_vol(flair))),...
										sptRes_x,...
										sptRes_y,...
										sptRes_z);
		dist_tbl = table (mean(clstr_dist), std(clstr_dist), var(clstr_dist));
	end

	dist_tbl.Properties.VariableNames = {'avg_clstr_dist'
										 'std_clstr_dist'
										 'var_clstr_dist'};


	wmh_ud2_postproc_quantification_clstrDist_finishTime = toc (wmh_ud2_postproc_quantification_clstrDist_startTime);

	if nargin==4
		if ud2param.exe.verbose
			fprintf ('%s : Quantifying distance between WMH clusters (subject ID = %s).\n', mfilename, subjid);
			fprintf ('%s : Finished (%s; %.4f seconds elapsed; subject ID = %s).\n', mfilename, string(datetime), ...
					wmh_ud2_postproc_quantification_clstrDist_finishTime, subjid);
		end
	else
		fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), ...
					wmh_ud2_postproc_quantification_clstrDist_finishTime);
	end
	
	fprintf ('%s :\n', mfilename);

end

function clstr_dist = distInWorldCoord (intrinsic_coordinates,img_size,sptRes_x,sptRes_y,sptRes_z)
	% Ref : https://www.mathworks.com/help/images/ref/imref2d.intrinsictoworld.html
	%       https://www.mathworks.com/help/images/ref/imref3d.html
	R = imref3d(img_size,sptRes_x,sptRes_y,sptRes_z);
	world_coordinates = zeros (size(intrinsic_coordinates,1),3);
	for i = 1 : size(intrinsic_coordinates,1)
		world_coordinates(i,:) =   intrinsicToWorld (R,...
													 intrinsic_coordinates(i,1),...
													 intrinsic_coordinates(i,2),...
													 intrinsic_coordinates(i,3));
	end
	clstr_dist = pdist (world_coordinates, 'euclidean');
end
