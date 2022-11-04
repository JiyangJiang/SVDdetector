function wmh_initFilesDirs (params, list, i)

wmh_initFilesDirs_startTime = tic;

switch list
	case 'paired'
		subjID = params.global.subjID.pairedT1Flair {i,1};
		orig_t1 = params.global.imgPath.pairedT1Flair.t1 {i,1};
		orig_flair = params.global.imgPath.pairedT1Flair.flair {i,1};
	case 't1only'
	case 'flairOnly'
end

fprintf ('%s : \n', mfilename);
fprintf ('%s : Started (%s; subject ID = %s).\n', mfilename, string(datetime), subjID);

% make each subject's folder
if ~ isfolder (fullfile(params.global.directories.subjects, subjID))
	if params.global.exe.verbose
		fprintf ('%s : Creating %s folder.\n', mfilename, fullfile(params.global.directories.subjects, subjID));
	end
	mkdir (params.global.directories.subjects, subjID);
else
	if params.global.exe.verbose
		fprintf ('%s : %s folder exists.\n', mfilename, fullfile(params.global.directories.subjects, subjID))
	end
end

if ~ isfolder (fullfile (params.global.directories.subjects, subjID, 'wmh'))
	if params.global.exe.verbose
		fprintf ('%s : Creating %s folder.\n', mfilename, fullfile (params.global.directories.subjects, subjID, 'wmh'));
	end
	mkdir (fullfile(params.global.directories.subjects, subjID),'wmh');
else
	if params.global.exe.verbose
		fprintf ('%s : %s folder exists.\n', mfilename, fullfile (params.global.directories.subjects, subjID, 'wmh'));
	end
end

if ~ isfolder (fullfile (params.global.directories.subjects, subjID, 'wmh', 'scripts'))
	if params.global.exe.verbose
		fprintf ('%s : Creating %s folder.\n', mfilename, fullfile (params.global.directories.subjects, subjID, 'wmh', 'scripts'));
	end
	mkdir (fullfile(params.global.directories.subjects, subjID, 'wmh'), 'scripts');
else
	if params.global.exe.verbose
		fprintf ('%s : %s folder exists.\n', mfilename, fullfile (params.global.directories.subjects, subjID, 'wmh', 'scripts'));
	end
end

if ~ isfolder (fullfile (params.global.directories.subjects, subjID, 'wmh', 'preproc'))
	if params.global.exe.verbose
		fprintf ('%s : Creating %s folder.\n', mfilename, fullfile (params.global.directories.subjects, subjID, 'wmh', 'preproc'));
	end
	mkdir (fullfile(params.global.directories.subjects, subjID, 'wmh'), 'preproc');
else
	if params.global.exe.verbose
		fprintf ('%s : %s folder exists.\n', mfilename, fullfile (params.global.directories.subjects, subjID, 'wmh', 'preproc'));
	end
end

if ~ isfolder (fullfile (params.global.directories.subjects, subjID, 'wmh', 'postproc'))
	if params.global.exe.verbose
		fprintf ('%s : Creating %s folder.\n', mfilename, fullfile (params.global.directories.subjects, subjID, 'wmh', 'postproc'));
	end
	mkdir (fullfile(params.global.directories.subjects, subjID, 'wmh'), 'postproc');
else
	if params.global.exe.verbose
		fprintf ('%s : %s folder exists.\n', mfilename, fullfile (params.global.directories.subjects, subjID, 'wmh', 'postproc'));
	end
end

if params.global.exe.verbose
	fprintf ('%s : %s''s processing will be logged in %s.\n', mfilename, subjID, fullfile (params.global.directories.subjects, subjID, 'wmh', 'scripts', 'cns2_ud.log'));
end
diary (fullfile (params.global.directories.subjects, subjID, 'wmh', 'scripts', 'cns2_ud.log'));

% copy original T1 to subject folder
if params.global.exe.verbose
	fprintf ('%s : Start copying %s''s T1 to %s.\n', mfilename, subjID, fullfile (params.global.directories.subjects, subjID, 'wmh', 'preproc', 't1.nii'));
end
if isfile (orig_t1)
	copyfile (orig_t1, ...
			  fullfile (params.global.directories.subjects, subjID, 'wmh', 'preproc', 't1.nii'));
else
	ME = MException ('SVDdetector:%s:origT1notFound', ...
					 '%s specified in cns2param but not found.', mfilename, orig_t1);
	throw (ME);
end

% copy original FLAIR to subject folder
if params.global.exe.verbose
	fprintf ('%s : Start copying %s''s FLAIR to %s.\n', mfilename, subjID, fullfile (params.global.directories.subjects, subjID, 'wmh', 'preproc', 'flair.nii'));
end
if isfile (orig_flair)
	copyfile (orig_flair, ...
			  fullfile (params.global.directories.subjects, subjID, 'wmh', 'preproc', 'flair.nii'));
else
	ME = MException ('SVDdetector:%s:origFLAIRnotFound', ...
					 '%s specified in cns2param but not found.', mfilename, orig_flair);
	throw (ME);
end

diary off



wmh_initFilesDirs_finishTime = toc (wmh_initFilesDirs_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed; subject ID = %s).\n', mfilename, string(datetime), wmh_initFilesDirs_finishTime, subjID);
fprintf ('%s : \n', mfilename);