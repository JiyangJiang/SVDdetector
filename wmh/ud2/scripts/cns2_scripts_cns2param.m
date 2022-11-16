
function cns2_scripts_cns2param (study_dir, ...
					             cns2_dir, ...
					             spm_dir, ...
					             n_cpu_cores, ...
					             save_dskspc, ...
					             save_more_dskspc, ...
					             verbose, ...
					             temp_opt)

cns2_scripts_cns2param_startTime = tic;
fprintf ('%s : \n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

global cns2param

% Execution options
% ++++++++++++++++++++++++++++++++++++
cns2param.exe.n_cpu_cores      = n_cpu_cores;
cns2param.exe.save_dskspc      = save_dskspc;
cns2param.exe.save_more_dskspc = save_more_dskspc;
cns2param.exe.verbose          = verbose;

if cns2param.exe.save_more_dskspc == true
	cns2param.exe.save_dskspc = true;
end

% Host infomation (e.g. os, cpu cores, etc.)
% Ref : http://undocumentedmatlab.com/articles/undocumented-feature-function
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cns2param.host.n_cpu_cores = feature ('numcores');

switch computer
case 'PCWIN64'
	cns2param.host.os = 'windows';
case 'GLNXA64'
	cns2param.host.os = 'linux';
case 'MACI64'
	cns2param.host.os = 'mac';
end

if n_cpu_cores > cns2param.host.n_cpu_cores
	n_cpu_cores = cns2param.host.n_cpu_cores;
end

switch cns2param.host.os
case 'windows'
	cns2param.exe.unix_cmd_compatible = false;
	tmp_word = 'not compatible';
case 'linux'
	cns2param.exe.unix_cmd_compatible = true;
	tmp_word = 'compatible';
case 'mac'
	cns2param.exe.unix_cmd_compatible = true;
	tmp_word = 'compatible';
end

if cns2param.exe.verbose
	fprintf ('%s : ++++++++ Execution options and host info ++++++++++\n', mfilename);
	fprintf ('%s : Verbose is set to %s (cns2param.exe.verbose).\n', mfilename, string(verbose));
	fprintf ('%s : Computer is running on %s operating system (cns2param.host.os).\n', mfilename, cns2param.host.os);
	fprintf ('%s : The operating system is %s with UNIX commands (cns2param.exe.unix_cmd_compatible).\n', mfilename, tmp_word);
	fprintf ('%s : Computer has %d CPU cores (cns2param.host.n_cpu_cores).\n', mfilename, cns2param.host.n_cpu_cores);
	fprintf ('%s : %d CPU cores will be used to run this pipeline (cns2param.exe.n_cpu_cores).\n', mfilename, n_cpu_cores);
	fprintf ('%s : Save disk space is set to %s (cns2param.exe.save_dskspc).\n', mfilename, string(save_dskspc));
	fprintf ('%s : Save more disk space is set to %s (cns2param.exe.save_more_dskspc).\n', mfilename, string(save_more_dskspc));
	fprintf ('%s : +++++++++++++++++++++++++++++++++++++++++++++++++++\n', mfilename);
end

% Directories
% +++++++++++++++++++++++++++++++++++++++++++++++++
% study directory
cns2param.dirs.study = study_dir;
% subjects dir
cns2param.dirs.subjs = fullfile (cns2param.dirs.study, 'subjects');
% CNS2 directory
cns2param.dirs.cns2 = cns2_dir;
% SPM12 path
cns2param.dirs.spm = spm_dir;

if cns2param.exe.verbose
	fprintf ('%s : +++++++++++++++ Directories ++++++++++++++\n', mfilename);
	fprintf ('%s : Study directory (cns2param.dirs.study) is set to ''%s''.\n', mfilename, study_dir);
	fprintf ('%s : Subjects directory (cns2param.dirs.subjs) is set to ''%s''.\n', mfilename, cns2param.dirs.subjs);
	fprintf ('%s : CNS2 directory (cns2param.dirs.cns2) is set to ''%s''.\n', mfilename, cns2param.dirs.cns2);
	fprintf ('%s : SPM12 directory (cns2param.dirs.spm) is set to ''%s''.\n', mfilename, cns2param.dirs.spm);
	fprintf ('%s : ++++++++++++++++++++++++++++++++++++++++++\n', mfilename);
end

% Lists
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% t1, flair, subjs
t1_dir = dir (fullfile (cns2param.dirs.study, 'T1', '*.nii'));
flair_dir = dir (fullfile (cns2param.dirs.study, 'FLAIR', '*.nii'));

cns2param.n_subjs = size(t1_dir,1);

if size(t1_dir,1) ~= size(flair_dir,1)
	ME = MException ('CNS2:setParam:unmatchT1FLAIR', ...
						 'Numbers of T1s and FLAIRs differ.');
	throw (ME);
end
for i = 1 : size(t1_dir,1)
	cns2param.lists.t1{i,1}    = t1_dir(i).name;
	cns2param.lists.flair{i,1} = flair_dir(i).name;
	tmp = strsplit (t1_dir(i).name, '_');
	cns2param.lists.subjs{i,1} = tmp{1};

	% check if t1 and flair pair
	if  ~ startsWith (cns2param.lists.flair{i,1}, [cns2param.lists.subjs{i,1} '_'])

		ME = MException ('CNS2:setParam:unmatchT1FLAIR', ...
						 'T1 and FLAIR do not pair.');
		throw (ME);
	end
end

if cns2param.exe.verbose
	fprintf ('%s : +++++++++++++++++++ Lists +++++++++++++++++++\n', mfilename);
	fprintf ('%s : T1 and FLAIR lists have been established.\n', mfilename);
	fprintf ('%s : %d participants are included (cns2param.n_subjs).\n', mfilename, cns2param.n_subjs);
	fprintf ('%s : +++++++++++++++++++++++++++++++++++++++++++++\n', mfilename);
end

% IDs failed segmentation
% =========================================================================
% NOTE that only those failed segmentation during creating DARTEL templates
% are recorded.
cns2param.lists.crtTempFailSeg = {};



% templates
% ++++++++++++++++++++++++++++++++++++++++++++
cns2param.templates.options = temp_opt;

switch cns2param.templates.options{1}

    case 'existing'
    	age_range = cns2param.templates.options{2};

		cns2param.templates.temp1_6{1,1} = fullfile (cns2param.dirs.cns2,'templates','DARTEL_0to6_templates',age_range,'Template_1.nii');
		cns2param.templates.temp1_6{2,1} = fullfile (cns2param.dirs.cns2,'templates','DARTEL_0to6_templates',age_range,'Template_2.nii');
		cns2param.templates.temp1_6{3,1} = fullfile (cns2param.dirs.cns2,'templates','DARTEL_0to6_templates',age_range,'Template_3.nii');
		cns2param.templates.temp1_6{4,1} = fullfile (cns2param.dirs.cns2,'templates','DARTEL_0to6_templates',age_range,'Template_4.nii');
		cns2param.templates.temp1_6{5,1} = fullfile (cns2param.dirs.cns2,'templates','DARTEL_0to6_templates',age_range,'Template_5.nii');
		cns2param.templates.temp1_6{6,1} = fullfile (cns2param.dirs.cns2,'templates','DARTEL_0to6_templates',age_range,'Template_6.nii');

		cns2param.templates.brnmsk = fullfile (cns2param.dirs.cns2,'templates','DARTEL_brain_mask',age_range,'DARTEL_brain_mask.nii');
        
        cns2param.templates.gmmsk = fullfile (cns2param.dirs.cns2,'templates','DARTEL_GM_WM_CSF_prob_maps',age_range,'DARTEL_GM_prob_map_thr0_8.nii');
        cns2param.templates.wmmsk = fullfile (cns2param.dirs.cns2,'templates','DARTEL_GM_WM_CSF_prob_maps',age_range,'DARTEL_WM_prob_map_thr0_8.nii');

        cns2param.templates.gmprob = fullfile (cns2param.dirs.cns2,'templates','DARTEL_GM_WM_CSF_prob_maps',age_range,'DARTEL_GM_prob_map.nii');
        cns2param.templates.wmprob = fullfile (cns2param.dirs.cns2,'templates','DARTEL_GM_WM_CSF_prob_maps',age_range,'DARTEL_WM_prob_map.nii');
        cns2param.templates.csfprob = fullfile (cns2param.dirs.cns2,'templates','DARTEL_GM_WM_CSF_prob_maps',age_range,'DARTEL_CSF_prob_map.nii');

    case 'creating'
        % GM_average_mask_nii = load_nii ([subj_dir '/cohort_probability_maps/cohort_GM_probability_map_thr0_8.nii.gz']);
        % WM_average_mask_nii = load_nii ([subj_dir '/cohort_probability_maps/cohort_WM_probability_map_thr0_8.nii.gz']);
        % WM_prob_map_nii = load_nii ([subj_dir '/cohort_probability_maps/cohort_WM_probability_map.nii']);
        % GM_prob_map_nii = load_nii ([subj_dir '/cohort_probability_maps/cohort_GM_probability_map.nii']);
        % CSF_prob_map_nii = load_nii ([subj_dir '/cohort_probability_maps/cohort_CSF_probability_map.nii']);

end

cns2param.templates.ventdst  = fullfile (cns2param.dirs.cns2,'templates','DARTEL_ventricle_distance_map',       'DARTEL_ventricle_distance_map.nii');
cns2param.templates.lobar    = fullfile (cns2param.dirs.cns2,'templates','DARTEL_lobar_and_arterial_templates', 'DARTEL_lobar_template.nii');
cns2param.templates.arterial = fullfile (cns2param.dirs.cns2,'templates','DARTEL_lobar_and_arterial_templates', 'DARTEL_arterial_template.nii');

if cns2param.exe.verbose
	fprintf ('%s : ++++++++++++++++++++++++++++++ Templates +++++++++++++++++++++++++++\n', mfilename);
	if strcmp (cns2param.templates.options{1}, 'existing')
		fprintf ('%s : Using existing DARTEL templates for age range %s.\n', mfilename, cns2param.templates.options{2});
	elseif strcmp (cns2param.templates.options{1}, 'creating')
		fprintf ('%s : Cohort-specific DARTEL templates will be created.\n', mfilename);
	end
	fprintf ('%s : DARTEL template 1 (cns2param.templates.temp1_6): %s.\n', mfilename, cns2param.templates.temp1_6{1,1});
	fprintf ('%s : DARTEL template 2 (cns2param.templates.temp1_6): %s.\n', mfilename, cns2param.templates.temp1_6{2,1});
	fprintf ('%s : DARTEL template 3 (cns2param.templates.temp1_6): %s.\n', mfilename, cns2param.templates.temp1_6{3,1});
	fprintf ('%s : DARTEL template 4 (cns2param.templates.temp1_6): %s.\n', mfilename, cns2param.templates.temp1_6{4,1});
	fprintf ('%s : DARTEL template 5 (cns2param.templates.temp1_6): %s.\n', mfilename, cns2param.templates.temp1_6{5,1});
	fprintf ('%s : DARTEL template 6 (cns2param.templates.temp1_6): %s.\n', mfilename, cns2param.templates.temp1_6{6,1});
	fprintf ('%s : DARTEL space brain mask (cns2param.templates.brnmsk) : %s.\n', mfilename, cns2param.templates.brnmsk);
	fprintf ('%s : DARTEL space GM mask (cns2param.templates.gmmsk) : %s.\n', mfilename, cns2param.templates.gmmsk);
	fprintf ('%s : DARTEL space WM mask (cns2param.templates.wmmsk) : %s.\n', mfilename, cns2param.templates.wmmsk);
	fprintf ('%s : DARTEL space GM probability map (cns2param.templates.gmprob) : %s.\n', mfilename, cns2param.templates.gmprob);
	fprintf ('%s : DARTEL space WM probability map (cns2param.templates.wmprob) : %s.\n', mfilename, cns2param.templates.wmprob);
	fprintf ('%s : DARTEL space CSF probability map (cns2param.templates.csfprob) : %s.\n', mfilename, cns2param.templates.csfprob);
	fprintf ('%s : +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n', mfilename);
end

cns2_scripts_cns2param_finishTime = toc (cns2_scripts_cns2param_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), cns2_scripts_cns2param_finishTime);
fprintf ('%s : \n', mfilename);
