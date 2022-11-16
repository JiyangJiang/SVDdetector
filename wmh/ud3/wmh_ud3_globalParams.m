function wmh_ud3_globalParams (svddDirectory, spm12directory, studyDirectory, verbose)

global ud3param

global_ud3param_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));


% Execution
if verbose
	ud3param.global.exe.verbose = true;
else
	ud3param.global.exe.verbose = false;
end

% Directories
ud3param.global.directories.svdd = svddDirectory;
ud3param.global.directories.spm12 = spm12directory;
ud3param.global.directories.study = studyDirectory;

if exist (fullfile (ud3param.global.directories.study, 't1'), 'dir')

	ud3param.global.directories.rawT1 = fullfile (ud3param.global.directories.study, 't1');

	if ud3param.global.exe.verbose
		fprintf ('%s : T1 folder (%s) exists.\n', mfilename, ud3param.global.directories.rawT1);
	end

	t1_dir = dir (fullfile (ud3param.global.directories.rawT1, '*.nii'));
	ud3param.global.numbers.allT1 = size(t1_dir,1);

	if ud3param.global.exe.verbose
		fprintf ('%s : There are %d T1w images.\n', mfilename, ud3param.global.numbers.allT1);
	end

	for i = 1 : ud3param.global.numbers.allT1
		ud3param.global.imgPath.allT1 {i,1} = fullfile (t1_dir(i).folder, t1_dir(i).name);
		tmp = strsplit (t1_dir(i).name, '_');
		ud3param.global.subjID.allT1 {i,1} = tmp{1};
	end
	 
end

if exist (fullfile (ud3param.global.directories.study, 'flair'), 'dir')

	ud3param.global.directories.rawFlair = fullfile (ud3param.global.directories.study, 'flair');

	if ud3param.global.exe.verbose
		fprintf ('%s : Flair folder (%s) exists.\n', mfilename, ud3param.global.directories.rawFlair);
	end

	flair_dir = dir (fullfile (ud3param.global.directories.rawFlair, '*.nii'));
	ud3param.global.numbers.allFlair = size(flair_dir,1);

	if ud3param.global.exe.verbose
		fprintf ('%s : There are %d FLAIR images.\n', mfilename, ud3param.global.numbers.allFlair);
	end

	for i = 1 : ud3param.global.numbers.allFlair
		ud3param.global.imgPath.allFlair {i,1} = fullfile (flair_dir(i).folder, flair_dir(i).name);
		tmp = strsplit (flair_dir(i).name, '_');
		ud3param.global.subjID.allFlair {i,1} = tmp{1};
	end

end

if ~ exist (fullfile (ud3param.global.directories.study, 'subjects'))
	mkdir (ud3param.global.directories.study, 'subjects');
else
	fprintf ('%s : Subjects directory (%s) exists. Results will be overwritten.\n', mfilename, fullfile (ud3param.global.directories.study, 'subjects'));
end
ud3param.global.directories.subjects = fullfile (ud3param.global.directories.study, 'subjects');

ud3param.global.subjID.pairedT1Flair = ud3param.global.subjID.allT1 (ismember (ud3param.global.subjID.allT1, ud3param.global.subjID.allFlair));
ud3param.global.numbers.pairedT1Flair = size (ud3param.global.subjID.pairedT1Flair, 1);
for i = 1 : ud3param.global.numbers.pairedT1Flair
	currT1dir = dir ([fullfile(ud3param.global.directories.rawT1, ud3param.global.subjID.pairedT1Flair{i,1}), '_*.nii']);
	ud3param.global.imgPath.pairedT1Flair.t1{i,1} = fullfile (currT1dir(1).folder, currT1dir(1).name);

	currFLAIRdir = dir ([fullfile(ud3param.global.directories.rawFlair, ud3param.global.subjID.pairedT1Flair{i,1}), '_*.nii']);
	ud3param.global.imgPath.pairedT1Flair.flair{i,1} = fullfile (currFLAIRdir(1).folder, currFLAIRdir(1).name);
end
if ud3param.global.exe.verbose
	fprintf ('%s : The following IDs have both T1 and FLAIR.\n', mfilename);
	for i = 1 : ud3param.global.numbers.pairedT1Flair
		fprintf ('%s : - %s\n', mfilename, ud3param.global.subjID.pairedT1Flair{i,1});
	end
end

ud3param.global.subjID.t1ButNotFlair = setdiff (ud3param.global.subjID.allT1, ud3param.global.subjID.allFlair);
ud3param.global.numbers.t1ButNotFlair = size (ud3param.global.subjID.t1ButNotFlair, 1);
for i = 1 : ud3param.global.numbers.t1ButNotFlair
	currT1dir = dir ([fullfile(ud3param.global.directories.rawT1, ud3param.global.subjID.t1ButNotFlair{i,1}), '_*.nii']);
	ud3param.global.imgPath.t1ButNotFlair.t1{i,1} = fullfile (currT1dir(1).folder, currT1dir(1).name);
end
if ud3param.global.exe.verbose
	fprintf ('%s : The following IDs have T1 but not FLAIR.\n', mfilename);
	for i = 1 : ud3param.global.numbers.t1ButNotFlair
		fprintf ('%s : - %s\n', mfilename, ud3param.global.subjID.t1ButNotFlair{i,1});
	end
end

ud3param.global.subjID.flairButNotT1 = setdiff (ud3param.global.subjID.allFlair, ud3param.global.subjID.allT1);
ud3param.global.numbers.flairButNotT1 = size (ud3param.global.subjID.flairButNotT1, 1);
for i = 1 : ud3param.global.numbers.flairButNotT1
	currFLAIRdir = dir ([fullfile(ud3param.global.directories.rawFlair, ud3param.global.subjID.flairButNotT1{i,1}), '_*.nii']);
	ud3param.global.imgPath.flairButNotT1.flair{i,1} = fullfile (currFLAIRdir(1).folder, currFLAIRdir(1).name);
end
if ud3param.global.exe.verbose
	fprintf ('%s : The following IDs have FLAIR but not T1.\n', mfilename);
	for i = 1 : ud3param.global.numbers.flairButNotT1
		fprintf ('%s : - %s\n', mfilename, ud3param.global.subjID.flairButNotT1{i,1});
	end
end

% Templates
ud3param.global.templates.tpm.gwm = fullfile (ud3param.global.directories.svdd, 'templates', 'tpm_gwm.nii');


global_ud3param_finishTime = toc (global_ud3param_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), global_ud3param_finishTime);
fprintf ('%s :\n', mfilename);