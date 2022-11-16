
function wmh_ud2_initDirFile (ud2param)

wmh_ud2_initDirFile_startTime = tic;
fprintf ('%s : \n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

% make study/subjects folder
if ~ isfolder (fullfile (ud2param.dirs.study, 'subjects'))
	if ud2param.exe.verbose
		fprintf ('%s : Subjects directory does not exist. Creating one.\n', mfilename);
	end
	mkdir (ud2param.dirs.study, 'subjects');
else
	if ud2param.exe.verbose
		fprintf ('%s : Subjects directory exists.\n', mfilename)
	end
end

parfor (i = 1 : ud2param.n_subjs, ud2param.exe.n_cpu_cores)

	subjsdir = ud2param.dirs.subjs;
	subjid   = ud2param.lists.subjs{i,1};

	% make each subject's folder
	if ~ isfolder (fullfile(subjsdir, subjid))
		if ud2param.exe.verbose
			fprintf ('%s : Creating %s folder.\n', mfilename, fullfile(subjsdir, subjid));
		end
		mkdir (subjsdir, subjid);
	else
		if ud2param.exe.verbose
			fprintf ('%s : %s folder exists.\n', mfilename, fullfile(subjsdir, subjid))
		end
	end
	if ~ isfolder (fullfile (subjsdir, subjid, 'ud'))
		if ud2param.exe.verbose
			fprintf ('%s : Creating %s folder.\n', mfilename, fullfile (subjsdir, subjid, 'ud'));
		end
		mkdir (fullfile(subjsdir, subjid),'ud');
	else
		if ud2param.exe.verbose
			fprintf ('%s : %s folder exists.\n', mfilename, fullfile (subjsdir, subjid, 'ud'));
		end
	end
	if ~ isfolder (fullfile (subjsdir, subjid, 'ud', 'scripts'))
		if ud2param.exe.verbose
			fprintf ('%s : Creating %s folder.\n', mfilename, fullfile (subjsdir, subjid, 'ud', 'scripts'));
		end
		mkdir (fullfile(subjsdir, subjid, 'ud'), 'scripts');
	else
		if ud2param.exe.verbose
			fprintf ('%s : %s folder exists.\n', mfilename, fullfile (subjsdir, subjid, 'ud', 'scripts'));
		end
	end
	if ~ isfolder (fullfile (subjsdir, subjid, 'ud', 'preproc'))
		if ud2param.exe.verbose
			fprintf ('%s : Creating %s folder.\n', mfilename, fullfile (subjsdir, subjid, 'ud', 'preproc'));
		end
		mkdir (fullfile(subjsdir, subjid, 'ud'), 'preproc');
	else
		if ud2param.exe.verbose
			fprintf ('%s : %s folder exists.\n', mfilename, fullfile (subjsdir, subjid, 'ud', 'preproc'));
		end
	end
	if ~ isfolder (fullfile (subjsdir, subjid, 'ud', 'postproc'))
		if ud2param.exe.verbose
			fprintf ('%s : Creating %s folder.\n', mfilename, fullfile (subjsdir, subjid, 'ud', 'postproc'));
		end
		mkdir (fullfile(subjsdir, subjid, 'ud'), 'postproc');
	else
		if ud2param.exe.verbose
			fprintf ('%s : %s folder exists.\n', mfilename, fullfile (subjsdir, subjid, 'ud', 'postproc'));
		end
	end
	if ~ isfolder (fullfile (subjsdir, subjid, 'ud', 'wmh'))
		if ud2param.exe.verbose
			fprintf ('%s : Creating %s folder.\n', mfilename, fullfile (subjsdir, subjid, 'ud', 'wmh'));
		end
		mkdir (fullfile(subjsdir, subjid, 'ud'), 'wmh');
	else
		if ud2param.exe.verbose
			fprintf ('%s : %s folder exists.\n', mfilename, fullfile (subjsdir, subjid, 'ud', 'wmh'));
		end
	end

	if ud2param.exe.verbose
		fprintf ('%s : %s''s processing will be logged in %s.\n', mfilename, subjid, fullfile (subjsdir, subjid, 'ud', 'scripts', 'cns2_ud.log'));
	end
	diary (fullfile (subjsdir, subjid, 'ud', 'scripts', 'cns2_ud.log'));

	orig_t1    = fullfile (ud2param.dirs.study, 'T1',    ud2param.lists.t1{i,1});
	orig_flair = fullfile (ud2param.dirs.study, 'FLAIR', ud2param.lists.flair{i,1});

	% copy original T1 to subject folder
	if ud2param.exe.verbose
		fprintf ('%s : Start copying %s''s T1 to %s.\n', mfilename, subjid, fullfile (subjsdir, subjid, 'ud', 'preproc', 't1.nii'));
	end
	if isfile (orig_t1)
		copyfile (orig_t1, ...
				  fullfile (subjsdir, subjid, 'ud', 'preproc', 't1.nii'));
	else
		ME = MException ('CNS2:initDirFile:origT1notFound', ...
						 '%s specified in ud2param but not found.', orig_t1);
		throw (ME);
	end

	% copy original FLAIR to subject folder
	if ud2param.exe.verbose
		fprintf ('%s : Start copying %s''s FLAIR to %s.\n', mfilename, subjid, fullfile (subjsdir, subjid, 'ud', 'preproc', 'flair.nii'));
	end
	if isfile (orig_flair)
		copyfile (orig_flair, ...
				  fullfile (subjsdir, subjid, 'ud', 'preproc', 'flair.nii'));
	else
		ME = MException ('CNS2:initDirFile:origFLAIRnotFound', ...
						 '%s specified in ud2param but not found.', orig_flair);
		throw (ME);
	end

	diary off
end


wmh_ud2_initDirFile_finishTime = toc (wmh_ud2_initDirFile_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), wmh_ud2_initDirFile_finishTime);
fprintf ('%s : \n', mfilename);