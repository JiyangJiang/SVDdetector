function wmh_ud3_initFilesDirs (list, i)

wmh_initFilesDirs_startTime = tic;

global ud3param

switch list
	case 'paired'
		subjID = ud3param.global.subjID.pairedT1Flair {i,1};
		orig_t1 = ud3param.global.imgPath.pairedT1Flair.t1 {i,1};
		orig_flair = ud3param.global.imgPath.pairedT1Flair.flair {i,1};
	case 't1only'
	case 'flairOnly'
end

fprintf ('%s : \n', mfilename);
fprintf ('%s : Started (%s; subject ID = %s).\n', mfilename, string(datetime), subjID);

% make each subject's folder
if ~ isfolder (fullfile(ud3param.global.directories.subjects, subjID))
	if ud3param.global.exe.verbose
		fprintf ('%s : Creating %s folder.\n', mfilename, fullfile(ud3param.global.directories.subjects, subjID));
	end
	mkdir (ud3param.global.directories.subjects, subjID);
else
	if ud3param.global.exe.verbose
		fprintf ('%s : %s folder exists.\n', mfilename, fullfile(ud3param.global.directories.subjects, subjID))
	end
end

if ~ isfolder (fullfile (ud3param.global.directories.subjects, subjID, 'wmh'))
	if ud3param.global.exe.verbose
		fprintf ('%s : Creating %s folder.\n', mfilename, fullfile (ud3param.global.directories.subjects, subjID, 'wmh'));
	end
	mkdir (fullfile(ud3param.global.directories.subjects, subjID),'wmh');
else
	if ud3param.global.exe.verbose
		fprintf ('%s : %s folder exists.\n', mfilename, fullfile (ud3param.global.directories.subjects, subjID, 'wmh'));
	end
end

if ~ isfolder (fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'scripts'))
	if ud3param.global.exe.verbose
		fprintf ('%s : Creating %s folder.\n', mfilename, fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'scripts'));
	end
	mkdir (fullfile(ud3param.global.directories.subjects, subjID, 'wmh'), 'scripts');
else
	if ud3param.global.exe.verbose
		fprintf ('%s : %s folder exists.\n', mfilename, fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'scripts'));
	end
end

if ~ isfolder (fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'preproc'))
	if ud3param.global.exe.verbose
		fprintf ('%s : Creating %s folder.\n', mfilename, fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'preproc'));
	end
	mkdir (fullfile(ud3param.global.directories.subjects, subjID, 'wmh'), 'preproc');
else
	if ud3param.global.exe.verbose
		fprintf ('%s : %s folder exists.\n', mfilename, fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'preproc'));
	end
end

if ~ isfolder (fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'postproc'))
	if ud3param.global.exe.verbose
		fprintf ('%s : Creating %s folder.\n', mfilename, fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'postproc'));
	end
	mkdir (fullfile(ud3param.global.directories.subjects, subjID, 'wmh'), 'postproc');
else
	if ud3param.global.exe.verbose
		fprintf ('%s : %s folder exists.\n', mfilename, fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'postproc'));
	end
end

if ud3param.global.exe.verbose
	fprintf ('%s : %s''s processing will be logged in %s.\n', mfilename, subjID, fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'scripts', 'wmh_ud3.log'));
end
diary (fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'scripts', 'wmh_ud3.log'));

% copy original T1 to subject folder
if ud3param.global.exe.verbose
	fprintf ('%s : Start copying %s''s T1 to %s.\n', mfilename, subjID, fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'preproc', 't1.nii'));
end
if isfile (orig_t1)
	copyfile (orig_t1, ...
			  fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'preproc', 't1.nii'));
else
	ME = MException ('SVDdetector:%s:origT1notFound', ...
					 '%s specified in cns2param but not found.', mfilename, orig_t1);
	throw (ME);
end

% copy original FLAIR to subject folder
if ud3param.global.exe.verbose
	fprintf ('%s : Start copying %s''s FLAIR to %s.\n', mfilename, subjID, fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'preproc', 'flair.nii'));
end
if isfile (orig_flair)
	copyfile (orig_flair, ...
			  fullfile (ud3param.global.directories.subjects, subjID, 'wmh', 'preproc', 'flair.nii'));
else
	ME = MException ('SVDdetector:%s:origFLAIRnotFound', ...
					 '%s specified in cns2param but not found.', mfilename, orig_flair);
	throw (ME);
end

diary off



wmh_initFilesDirs_finishTime = toc (wmh_initFilesDirs_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed; subject ID = %s).\n', mfilename, string(datetime), wmh_initFilesDirs_finishTime, subjID);
fprintf ('%s : \n', mfilename);