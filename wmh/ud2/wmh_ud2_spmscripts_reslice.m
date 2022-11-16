% USAGE
%   ref = reference image to reslice to.
%   img2reslice = image to reslice to ref.
%   interp = interpolation method (B-spline interpolation value; 0 - NN; 1 - trilinear)

function resliced_image = wmh_ud2_spmscripts_reslice (ud2param, ref, img2reslice, interp)

	ud2_spmscripts_reslice_startTime = tic;

	fprintf ('%s :\n', mfilename);
	fprintf ('%s : Started (%s).', mfilename, string(datetime));

	if ud2param.exe.verbose
		switch interp
		case 0
			interpMethod = 'nearest neighbour';
		case 1
			interpMethod = 'trilinear';
		end
		fprintf ('%s : Reslicing %s (reference = %s) using %s interpolation.\n', mfilename, img2reslice, ref, interpMethod);
	end

	[img2reslice_dir, img2reslice_filename, img2reslice_ext] = fileparts (img2reslice);

	resliceFlags= struct('interp',interp,...
					'mask',1,...
					'mean',0,...
					'which',1,...
					'wrap',[0 0 0]);
	

	files = {ref;img2reslice};
    
	spm_reslice(files, resliceFlags);

	resliced_image = fullfile(img2reslice_dir, ['r' img2reslice_filename img2reslice_ext]);

	if ud2param.exe.verbose
		fprintf ('%s : Reslicing finished. Resliced image is %s.\n', resliced_image);
	end

	ud2_spmscripts_reslice_finishTime = toc (ud2_spmscripts_reslice_startTime);
	fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), ud2_spmscripts_reslice_finishTime);
	fprintf ('%s :\n', mfilename);