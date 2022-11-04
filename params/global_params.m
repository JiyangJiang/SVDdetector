function global_params (svddDirectory, spm12directory, studyDirectory, verbose)

global params

global_params_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));


% Execution
if verbose
	params.global.exe.verbose = true;
else
	params.global.exe.verbose = false;
end

% Directories
params.global.directories.svdd = svddDirectory;
params.global.directories.spm12 = spm12directory;
params.global.directories.study = studyDirectory;

if exist (fullfile (params.global.directories.study, 't1'), 'dir')

	params.global.directories.rawT1 = fullfile (params.global.directories.study, 't1');

	if params.global.exe.verbose
		fprintf ('%s : T1 folder (%s) exists.\n', mfilename, params.global.directories.rawT1);
	end

	t1_dir = dir (fullfile (params.global.directories.rawT1, '*.nii'));
	params.global.numbers.allT1 = size(t1_dir,1);

	if params.global.exe.verbose
		fprintf ('%s : There are %d T1w images.\n', mfilename, params.global.numbers.allT1);
	end

	for i = 1 : params.global.numbers.allT1
		params.global.imgPath.allT1 {i,1} = fullfile (t1_dir(i).folder, t1_dir(i).name);
		tmp = strsplit (t1_dir(i).name, '_');
		params.global.subjID.allT1 {i,1} = tmp{1};
	end
	 
end

if exist (fullfile (params.global.directories.study, 'flair'), 'dir')

	params.global.directories.rawFlair = fullfile (params.global.directories.study, 'flair');

	if params.global.exe.verbose
		fprintf ('%s : Flair folder (%s) exists.\n', mfilename, params.global.directories.rawFlair);
	end

	flair_dir = dir (fullfile (params.global.directories.rawFlair, '*.nii'));
	params.global.numbers.allFlair = size(flair_dir,1);

	if params.global.exe.verbose
		fprintf ('%s : There are %d FLAIR images.\n', mfilename, params.global.numbers.allFlair);
	end

	for i = 1 : params.global.numbers.allFlair
		params.global.imgPath.allFlair {i,1} = fullfile (flair_dir(i).folder, flair_dir(i).name);
		tmp = strsplit (flair_dir(i).name, '_');
		params.global.subjID.allFlair {i,1} = tmp{1};
	end

end

if ~ exist (fullfile (params.global.directories.study, 'subjects'))
	mkdir (params.global.directories.study, 'subjects');
else
	fprintf ('%s : Subjects directory (%s) exists. Results will be overwritten.\n', mfilename, fullfile (params.global.directories.study, 'subjects'));
end
params.global.directories.subjects = fullfile (params.global.directories.study, 'subjects');

params.global.subjID.pairedT1Flair = params.global.subjID.allT1 (ismember (params.global.subjID.allT1, params.global.subjID.allFlair));
params.global.numbers.pairedT1Flair = size (params.global.subjID.pairedT1Flair, 1);
for i = 1 : params.global.numbers.pairedT1Flair
	currT1dir = dir ([fullfile(params.global.directories.rawT1, params.global.subjID.pairedT1Flair{i,1}), '_*.nii']);
	params.global.imgPath.pairedT1Flair.t1{i,1} = fullfile (currT1dir(1).folder, currT1dir(1).name);

	currFLAIRdir = dir ([fullfile(params.global.directories.rawFlair, params.global.subjID.pairedT1Flair{i,1}), '_*.nii']);
	params.global.imgPath.pairedT1Flair.flair{i,1} = fullfile (currFLAIRdir(1).folder, currFLAIRdir(1).name);
end

params.global.subjID.t1ButNotFlair = setdiff (params.global.subjID.allT1, params.global.subjID.allFlair);
params.global.numbers.t1ButNotFlair = size (params.global.subjID.t1ButNotFlair, 1);
for i = 1 : params.global.numbers.t1ButNotFlair
	currT1dir = dir ([fullfile(params.global.directories.rawT1, params.global.subjID.t1ButNotFlair{i,1}), '_*.nii']);
	params.global.imgPath.t1ButNotFlair.t1{i,1} = fullfile (currT1dir(1).folder, currT1dir(1).name);
end

params.global.subjID.flairButNotT1 = setdiff (params.global.subjID.allFlair, params.global.subjID.allT1);
params.global.numbers.flairButNotT1 = size (params.global.subjID.flairButNotT1, 1);
for i = 1 : params.global.numbers.flairButNotT1
	currFLAIRdir = dir ([fullfile(params.global.directories.rawFlair, params.global.subjID.flairButNotT1{i,1}), '_*.nii']);
	params.global.imgPath.flairButNotT1.flair{i,1} = fullfile (currFLAIRdir(1).folder, currFLAIRdir(1).name);
end

% Templates
params.global.templates.tpm.gwm = fullfile (params.global.directories.svdd, 'templates', 'tpm_gwm.nii');


global_params_finishTime = toc (global_params_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), global_params_finishTime);
fprintf ('%s :\n', mfilename);