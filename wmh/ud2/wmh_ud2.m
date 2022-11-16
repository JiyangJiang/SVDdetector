function wmh_ud2

	% study_dir = '/Users/z3402744/GitHub/CNS2/example_data';
	study_dir = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2_example_data'; % Dell XPS 13
	% study_dir = 'D:\GitHub\CNS2\example_data';

	% cns2_dir = '/Users/z3402744/GitHub/CNS2';
	cns2_dir = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2'; % Dell XPS 13
	% cns2_dir = 'D:\GitHub\CNS2';

	% spm_dir = '/Applications/spm12';
	spm_dir = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12'; % Dell XPS 13
	% spm_dir = 'C:\Program Files\spm12';


	n_cpu_cores = 2;
	save_dskspc = false;
	save_more_dskspc = false;
	verbose = true;

	temp_opt = {'existing'; '70to80'};

	% lv1clstMethod = 'kmeans';
	lv1clstMethod = 'superpixel';
	k4kmeans = 6;
	k4knn    = 5;
	n4superpixel = 5000;
	probthr = 0.7;
	extSpace = 'dartel';

	pvmag = 12;

	sizthr_mm3 = [10.125 30.375 50.625]; % in mm^3

	addpath (genpath (cns2_dir));
	addpath (spm_dir);

	global Defaults
	Defaults = spm_get_defaults;

	% +++++++++++++
	% Run from here
	% +++++++++++++

	wmh_ud2_startTime = tic;
	fprintf('%s : \n', mfilename);
	fprintf('%s : Started (%s).\n', mfilename, string(datetime));

	try
		global ud2param

		% general ud2param
		ud2param = cns2_scripts_ud2param  (study_dir, ...
								             cns2_dir, ...
								             spm_dir, ...
								             n_cpu_cores, ...
								             save_dskspc, ...
								             save_more_dskspc, ...
								             verbose, ...
								             temp_opt);

		% ubo detector-specific ud2param
		ud2param = wmh_ud2_ud2param  (ud2param, ...
											lv1clstMethod, ...
										    k4kmeans, ...
										    n4superpixel, ...
										    k4knn, ...
										    probthr, ...
										    extSpace, ...
										    pvmag, ...
										    sizthr_mm3);

		% initialising/organising directories/files
		wmh_ud2_initDirFile (ud2param);

		% initialise cohort-level quantification table
		quant_tbl_coh = wmh_ud2_initCohQuantTbl (ud2param);

		% creating template
		if strcmp(ud2param.templates.options{1},'creating') % creating templates
			[flowmaps,ud2param] = wmh_ud2_crtDartelTemp (ud2param);
		else
			flowmaps = {}; % This had to be set. Otherwise, an error of unknown
						   % 'flowmaps' will happen, although 'existing' is set.
		end

		% for parfor
		subjs_list = ud2param.lists.subjs;

		% parfor (i = 1 : ud2param.n_subjs, ud2param.exe.n_cpu_cores)
		% for i = 1 : ud2param.n_subjs
		for i = 4:6 % only run one (0022)
			
			diary (fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'ud', 'scripts', 'cns2_ud.log'));

			try

				switch ud2param.templates.options{1}
				    case 'existing'
				    	wmh_ud2_preproc (ud2param,i);           	 % preprocessing (existing templates)
					case 'creating'
						if ~ismember (ud2param.lists.subjs{i,1},ud2param.lists.crtTempFailSeg)
							wmh_ud2_preproc (ud2param,i,flowmaps);  % preprocessing (creating templates - 
																		 % flowmaps are generated during creating
																		 % templates).
						else
							ME = MException ('CNS2:ud:crtTempFailSeg', ...
							 '%s failed segmentation during creating templates.', ud2param.lists.subjs{i,1});
							throw (ME);
						end
				end
				
				quant_tbl_subj = wmh_ud2_postproc (ud2param,i); % postprocessing, including 
																	 % classification and quantification

			catch ME
				
				fprintf (2,'\nException thrown\n');
				fprintf (2,'++++++++++++++++++++++\n');
				fprintf (2,'identifier: %s\n', ME.identifier);
				fprintf (2,'message: %s\n\n', ME.message);

				% assign NaN values if errors.
				quant_tbl_coh (i,:) = nan_entry (ud2param,i);
				
				fprintf ('%s : %s finished UBO Detector with ERROR.\n', mfilename, ud2param.lists.subjs{i,1});

				diary off

				continue; % jump to next iteration (for i)

			end

			% quant_tbl_coh (i,:) = quant_tbl_subj; % accumulate into cohort-level results

			% fprintf ('%s : %s finished UBO Detector without error.\n', mfilename, ud2param.lists.subjs{i,1});

			diary off
		end

		% save cohort results
		% writetable (quant_tbl_coh, ...
		% 			fullfile (ud2param.dirs.subjs,'wmh_ud2.csv')); % write out cohort-level quantification table
		
		% if ~ud2param.exe.save_dskspc
		% 	save (fullfile (ud2param.dirs.subjs,'wmh_ud2.mat'), 'quant_tbl_coh'); % save matlab .mat file
		% end

	catch ME
		fprintf (2,'\nException thrown\n');
		fprintf (2,'++++++++++++++++++++++\n');
		fprintf (2,'identifier: %s\n', ME.identifier);
		fprintf (2,'message: %s\n\n', ME.message);

		fprintf ('%s : UBO Detector aborted from initialisation.\n', curr_cmd);
		fprintf ('%s : Error at either setting ud2param, organising dirs/files, or creating templates.\n', curr_cmd);
	end

	wmh_ud2_finishTime = toc (wmh_ud2_startTime);
	fprintf ('%s : Finished (%s; %.4f seconds elapsed.\n', mfilename, string(datetime), wmh_ud2_finishTime);
	fprintf('%s : \n', mfilename);
end


function nan_entry_tbl = nan_entry (ud2param,i)
	nan_entry_tbl (1,1)     = table (ud2param.lists.subjs(i,1));
	nan_entry_tbl (1,2:194) = table (NaN);
end