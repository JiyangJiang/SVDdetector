function ud2param = wmh_ud2_param_global (study_dir, ...
					             svdd_dir, ...
					             spm_dir, ...
					             n_workers, ...
					             save_dskspc, ...
					             save_more_dskspc, ...
					             verbose, ...
					             temp_opt)

ud2_scripts_ud2param_startTime = tic;
fprintf ('%s : \n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

% Execution options
% ++++++++++++++++++++++++++++++++++++
ud2param.exe.n_workers        = n_workers;
ud2param.exe.save_dskspc      = save_dskspc;
ud2param.exe.save_more_dskspc = save_more_dskspc;
ud2param.exe.verbose          = verbose;

if ud2param.exe.save_more_dskspc == true
	ud2param.exe.save_dskspc = true;
end

% Host infomation (e.g. os, cpu cores, etc.)
% Ref : http://undocumentedmatlab.com/articles/undocumented-feature-function
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ud2param.host.n_cpu_cores = feature ('numcores');

switch computer
case 'PCWIN64'
	ud2param.host.os = 'windows';
case 'GLNXA64'
	ud2param.host.os = 'linux';
case 'MACI64'
	ud2param.host.os = 'mac';
end

if ud2param.exe.n_workers > ud2param.host.n_cpu_cores
	ud2param.exe.n_workers = ud2param.host.n_cpu_cores;
end

switch ud2param.host.os
case 'windows'
	ud2param.exe.unix_cmd_compatible = false;
	tmp_word = 'not compatible';
case 'linux'
	ud2param.exe.unix_cmd_compatible = true;
	tmp_word = 'compatible';
case 'mac'
	ud2param.exe.unix_cmd_compatible = true;
	tmp_word = 'compatible';
end

% ==================================================================
% Consider memory usage in the future, especially when superpixels.
% Use MATLAB memory function.
% ==================================================================

if ud2param.exe.verbose
	fprintf ('%s : ++++++++ Execution options and host info ++++++++++\n', mfilename);
	fprintf ('%s : Verbose is set to %s (ud2param.exe.verbose).\n', mfilename, string(verbose));
	fprintf ('%s : Computer is running on %s operating system (ud2param.host.os).\n', mfilename, ud2param.host.os);
	fprintf ('%s : The operating system is %s with UNIX commands (ud2param.exe.unix_cmd_compatible).\n', mfilename, tmp_word);
	fprintf ('%s : Computer has %d CPU cores (ud2param.host.n_cpu_cores).\n', mfilename, ud2param.host.n_cpu_cores);
	fprintf ('%s : %d CPU cores will be used to run this pipeline (ud2param.exe.n_workers).\n', mfilename, ud2param.exe.n_workers);
	fprintf ('%s : Save disk space is set to %s (ud2param.exe.save_dskspc).\n', mfilename, string(save_dskspc));
	fprintf ('%s : Save more disk space is set to %s (ud2param.exe.save_more_dskspc).\n', mfilename, string(save_more_dskspc));
	fprintf ('%s : +++++++++++++++++++++++++++++++++++++++++++++++++++\n', mfilename);
end

% Directories
% +++++++++++++++++++++++++++++++++++++++++++++++++
% study directory
ud2param.dirs.study = study_dir;
% subjects dir
ud2param.dirs.subjs = fullfile (ud2param.dirs.study, 'subjects');
% SVDdetector directory
ud2param.dirs.svdd = svdd_dir;
% ud2 directory
ud2param.dirs.ud2 = fullfile (ud2param.dirs.svdd, 'wmh', 'ud2');
% SPM12 path
ud2param.dirs.spm = spm_dir;

if ud2param.exe.verbose
	fprintf ('%s : +++++++++++++++ Directories ++++++++++++++\n', mfilename);
	fprintf ('%s : Study directory (ud2param.dirs.study) is set to ''%s''.\n', mfilename, study_dir);
	fprintf ('%s : Subjects directory (ud2param.dirs.subjs) is set to ''%s''.\n', mfilename, ud2param.dirs.subjs);
	fprintf ('%s : SVDdetector directory (ud2param.dirs.svdd) is set to ''%s''', mfilename, ud2param.dirs.svdd);
	fprintf ('%s : UBO Detector 2 directory (ud2param.dirs.ud2) is set to ''%s''.\n', mfilename, ud2param.dirs.ud2);
	fprintf ('%s : SPM12 directory (ud2param.dirs.spm) is set to ''%s''.\n', mfilename, ud2param.dirs.spm);
	fprintf ('%s : ++++++++++++++++++++++++++++++++++++++++++\n', mfilename);
end

% Lists
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% t1, flair, subjs
t1_dir = dir (fullfile (ud2param.dirs.study, 'T1', '*.nii'));
flair_dir = dir (fullfile (ud2param.dirs.study, 'FLAIR', '*.nii'));

ud2param.n_subjs = size(t1_dir,1);

if size(t1_dir,1) ~= size(flair_dir,1)
	ME = MException ('ud2:setParam:unmatchT1FLAIR', ...
						 'Numbers of T1s and FLAIRs differ.');
	throw (ME);
end
for i = 1 : size(t1_dir,1)
	ud2param.lists.t1{i,1}    = t1_dir(i).name;
	ud2param.lists.flair{i,1} = flair_dir(i).name;
	tmp = strsplit (t1_dir(i).name, '_');
	ud2param.lists.subjs{i,1} = tmp{1};

	% check if t1 and flair pair
	if  ~ startsWith (ud2param.lists.flair{i,1}, [ud2param.lists.subjs{i,1} '_'])

		ME = MException ('ud2:setParam:unmatchT1FLAIR', ...
						 'T1 and FLAIR do not pair.');
		throw (ME);
	end
end

if ud2param.exe.verbose
	fprintf ('%s : +++++++++++++++++++ Lists +++++++++++++++++++\n', mfilename);
	fprintf ('%s : T1 and FLAIR lists have been established.\n', mfilename);
	fprintf ('%s : %d participants are included (ud2param.n_subjs).\n', mfilename, ud2param.n_subjs);
	fprintf ('%s : +++++++++++++++++++++++++++++++++++++++++++++\n', mfilename);
end

% IDs failed segmentation
% =========================================================================
% NOTE that only those failed segmentation during creating DARTEL templates
% are recorded.
ud2param.lists.crtTempFailSeg = {};



% templates
% ++++++++++++++++++++++++++++++++++++++++++++
ud2param.templates.options = temp_opt;

switch ud2param.templates.options{1}

    case 'existing'
    	
    	age_range = ud2param.templates.options{2};

		ud2param.templates.temp1_6{1,1} = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_0to6_templates',age_range,'Template_1.nii');
		ud2param.templates.temp1_6{2,1} = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_0to6_templates',age_range,'Template_2.nii');
		ud2param.templates.temp1_6{3,1} = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_0to6_templates',age_range,'Template_3.nii');
		ud2param.templates.temp1_6{4,1} = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_0to6_templates',age_range,'Template_4.nii');
		ud2param.templates.temp1_6{5,1} = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_0to6_templates',age_range,'Template_5.nii');
		ud2param.templates.temp1_6{6,1} = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_0to6_templates',age_range,'Template_6.nii');
		ud2param.templates.brnmsk = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_brain_mask',age_range,'DARTEL_brain_mask.nii');
        ud2param.templates.gmmsk = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_GM_WM_CSF_prob_maps',age_range,'DARTEL_GM_prob_map_thr0_8.nii');
        ud2param.templates.wmmsk = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_GM_WM_CSF_prob_maps',age_range,'DARTEL_WM_prob_map_thr0_8.nii');
        ud2param.templates.gmprob = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_GM_WM_CSF_prob_maps',age_range,'DARTEL_GM_prob_map.nii');
        ud2param.templates.wmprob = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_GM_WM_CSF_prob_maps',age_range,'DARTEL_WM_prob_map.nii');
        ud2param.templates.csfprob = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_GM_WM_CSF_prob_maps',age_range,'DARTEL_CSF_prob_map.nii');

    case 'creating'

    	ud2param.templates.temp1_6{1,1} = 'TO BE CALCULATED AFTER CREATING TEMPLATES';
		ud2param.templates.temp1_6{2,1} = 'TO BE CALCULATED AFTER CREATING TEMPLATES';
		ud2param.templates.temp1_6{3,1} = 'TO BE CALCULATED AFTER CREATING TEMPLATES';
		ud2param.templates.temp1_6{4,1} = 'TO BE CALCULATED AFTER CREATING TEMPLATES';
		ud2param.templates.temp1_6{5,1} = 'TO BE CALCULATED AFTER CREATING TEMPLATES';
		ud2param.templates.temp1_6{6,1} = 'TO BE CALCULATED AFTER CREATING TEMPLATES';

        ud2param.templates.brnmsk = 'TO BE CALCULATED AFTER CREATING TEMPLATES';
        ud2param.templates.gmmsk = 'TO BE CALCULATED AFTER CREATING TEMPLATES';
        ud2param.templates.wmmsk = 'TO BE CALCULATED AFTER CREATING TEMPLATES';
		ud2param.templates.gmprob = 'TO BE CALCULATED AFTER CREATING TEMPLATES';
        ud2param.templates.wmprob = 'TO BE CALCULATED AFTER CREATING TEMPLATES';
        ud2param.templates.csfprob = 'TO BE CALCULATED AFTER CREATING TEMPLATES';

end

ud2param.templates.ventdst  = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_ventricle_distance_map',       'DARTEL_ventricle_distance_map.nii');
ud2param.templates.lobar    = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_lobar_and_arterial_templates', 'DARTEL_lobar_template.nii');
ud2param.templates.arterial = fullfile (ud2param.dirs.svdd, 'templates','DARTEL_lobar_and_arterial_templates', 'DARTEL_arterial_template.nii');

if ud2param.exe.verbose
	fprintf ('%s : ++++++++++++++++++++++++++++++ Templates +++++++++++++++++++++++++++\n', mfilename);
	if strcmp (ud2param.templates.options{1}, 'existing')
		fprintf ('%s : Using existing DARTEL templates for age range %s.\n', mfilename, ud2param.templates.options{2});
	elseif strcmp (ud2param.templates.options{1}, 'creating')
		fprintf ('%s : Cohort-specific DARTEL templates will be created.\n', mfilename);
	end
	fprintf ('%s : DARTEL template 1 (ud2param.templates.temp1_6): %s.\n', mfilename, ud2param.templates.temp1_6{1,1});
	fprintf ('%s : DARTEL template 2 (ud2param.templates.temp1_6): %s.\n', mfilename, ud2param.templates.temp1_6{2,1});
	fprintf ('%s : DARTEL template 3 (ud2param.templates.temp1_6): %s.\n', mfilename, ud2param.templates.temp1_6{3,1});
	fprintf ('%s : DARTEL template 4 (ud2param.templates.temp1_6): %s.\n', mfilename, ud2param.templates.temp1_6{4,1});
	fprintf ('%s : DARTEL template 5 (ud2param.templates.temp1_6): %s.\n', mfilename, ud2param.templates.temp1_6{5,1});
	fprintf ('%s : DARTEL template 6 (ud2param.templates.temp1_6): %s.\n', mfilename, ud2param.templates.temp1_6{6,1});
	fprintf ('%s : DARTEL space brain mask (ud2param.templates.brnmsk) : %s.\n', mfilename, ud2param.templates.brnmsk);
	fprintf ('%s : DARTEL space GM mask (ud2param.templates.gmmsk) : %s.\n', mfilename, ud2param.templates.gmmsk);
	fprintf ('%s : DARTEL space WM mask (ud2param.templates.wmmsk) : %s.\n', mfilename, ud2param.templates.wmmsk);
	fprintf ('%s : DARTEL space GM probability map (ud2param.templates.gmprob) : %s.\n', mfilename, ud2param.templates.gmprob);
	fprintf ('%s : DARTEL space WM probability map (ud2param.templates.wmprob) : %s.\n', mfilename, ud2param.templates.wmprob);
	fprintf ('%s : DARTEL space CSF probability map (ud2param.templates.csfprob) : %s.\n', mfilename, ud2param.templates.csfprob);
	fprintf ('%s : +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n', mfilename);
end

ud2_scripts_ud2param_finishTime = toc (ud2_scripts_ud2param_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), ud2_scripts_ud2param_finishTime);
fprintf ('%s : \n', mfilename);
