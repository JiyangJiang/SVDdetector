function wmh_ud2 (study_dir, svdd_dir, spm_dir, ...
					n_workers, save_dskspc, save_more_dskspc, verbose, temp_opt, ...
						lv1clstMethod, k4kmeans, k4knn, n4superpixel, probthr, extSpace, pvmag, sizthr_mm3)

	svdd_wmh_dir = fullfile(svdd_dir,'wmh');
	addpath (svdd_wmh_dir, spm_dir);

	wmh_ud2_startTime = tic;
	fprintf('%s : \n', mfilename);
	fprintf('%s : Started (%s).\n', mfilename, string(datetime));

	try
		
		% general ud2param
		ud2param = wmh_ud2_param_global  (study_dir, ...
								             svdd_dir, ...
								             spm_dir, ...
								             n_workers, ...
								             save_dskspc, ...
								             save_more_dskspc, ...
								             verbose, ...
								             temp_opt);

		% ubo detector-specific ud2param
		ud2param = wmh_ud2_param_wmh  (ud2param, ...
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
		switch ud2param.templates.options{1}

			case 'creating'
				
				[ud2param, flowmaps] = wmh_ud2_crtDartelTemp (ud2param);

			case 'existing'
			
				flowmaps = {}; % This had to be set. Otherwise, an error of unknown
							   % 'flowmaps' will happen, although 'existing' is set.

		end

		
		parfor (i = 1 : ud2param.n_subjs, ud2param.exe.n_workers)
					
			diary (fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'scripts', 'wmh_ud2.log'));

			try

				switch ud2param.templates.options{1}

				    case 'existing'

				    	switch ud2param.classification.ext_space

					    	case 'dartel'

						    	wmh_ud2_preproc (ud2param,i);

						    case 'native'

						    	ud2param_nat = wmh_ud2_preproc (ud2param,i);

					    end

					case 'creating'

						if ismember (ud2param.lists.subjs{i,1}, ud2param.lists.crtTempSucceedSeg)

							switch ud2param.classification.ext_space

								case 'dartel'

									wmh_ud2_preproc (ud2param, i, flowmaps);

								case 'native'

									ud2param_nat = wmh_ud2_preproc (ud2param, i, flowmaps);

							end

						else

							ME = MException ('wmh_ud2:crtTempFailSeg', ...
							 '%s failed tissue segmentation during creating templates. The T1w image may have some issue. Therefore, %s is given all NaN values in the final output.', ud2param.lists.subjs{i,1}, ud2param.lists.subjs{i,1});
							throw (ME);

						end

				end
				
				switch  ud2param.classification.ext_space

					case 'dartel'

						quant_tbl_subj = wmh_ud2_postproc (ud2param,i); % postprocessing, including 
																		% classification and quantification

					case 'native'

						quant_tbl_subj = wmh_ud2_postproc (ud2param_nat, i);
				end


			catch ME
				
				fprintf (2,'\nException thrown\n');
				fprintf (2,'++++++++++++++++++++++\n');
				fprintf (2,'identifier: %s\n', ME.identifier);
				fprintf (2,'message: %s\n\n', ME.message);

				% assign NaN values if errors.
				quant_tbl_coh (i,:) = nan_entry (ud2param,i);
				
				fprintf ('%s : %s finished UBO Detector 2 with ERROR.\n', mfilename, ud2param.lists.subjs{i,1});

				diary off

				continue; % jump to next iteration (for i)

			end

			quant_tbl_coh (i,:) = quant_tbl_subj; % accumulate into cohort-level results

			fprintf ('%s : %s finished UBO Detector 2 without error.\n', mfilename, ud2param.lists.subjs{i,1});

			diary off
		end

		% save cohort results
		writetable (quant_tbl_coh, ...
					fullfile (ud2param.dirs.subjs,'wmh_ud2.csv')); % write out cohort-level quantification table
		
		if ~ud2param.exe.save_dskspc
			save (fullfile (ud2param.dirs.subjs,'wmh_ud2.mat'), 'quant_tbl_coh'); % save matlab .mat file
		end

	catch ME
		fprintf (2,'\n%s : Exception thrown\n', mfilename);
		fprintf (2,'+++++++++++++++++++++++++++++++++\n');
		fprintf (2,'identifier: %s\n', ME.identifier);
		fprintf (2,'message: %s\n', ME.message);
		fprintf (2,'stack: a stack of %d functions threw exceptions.\n', size(ME.stack,1));
		for k = 1:size(ME.stack,1)
			if isfile (ME.stack(k).file)
				code = readlines (ME.stack(k).file);
				fprintf (2, 'exception #%d in line %d of %s ( ==> %s <== ).\n', k, ME.stack(k).line, ME.stack(k).name, strtrim(code(ME.stack(k).line)));
			elseif strcmp (ME.stack(k).name, 'MATLABbatch system')
				fprintf (2, 'exception #%d is from MATLAB batch system, most likely caused by failure in running SPM functions.\n', k);
			end
		end
		fprintf ('%s : \n', mfilename);

		fprintf ('%s : UBO Detector aborted from initialisation.\n', mfilename);
		fprintf ('%s : Error at either setting ud2param, organising dirs/files, or creating templates.\n', mfilename);
	end

	wmh_ud2_finishTime = toc (wmh_ud2_startTime);
	fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), wmh_ud2_finishTime);
	fprintf('%s : \n', mfilename);
end


function nan_entry_tbl = nan_entry (ud2param,i)
	nan_entry_tbl (1,1)     = table (ud2param.lists.subjs(i,1));
	nan_entry_tbl (1,2:194) = table (NaN);
end