function flowMapCellArr = wmh_ud2_crtDartelTemp (ud2param)

wmh_ud2_crtDartelTemp_startTime = tic;
fprintf ('%s : \n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

if ud2param.exe.verbose
    fprintf ('%s : Creating cohort-specific DARTEL template.\n', mfilename);
end

rcGMcellArr_col  = cell (ud2param.n_subjs,1);
rcWMcellArr_col  = cell (ud2param.n_subjs,1);
rcCSFcellArr_col = cell (ud2param.n_subjs,1);

cGMcellArr_col  = cell (ud2param.n_subjs,1);
cWMcellArr_col  = cell (ud2param.n_subjs,1);
cCSFcellArr_col = cell (ud2param.n_subjs,1);

% deal with parfor's 'unable to classify' issue
subjs_dir = ud2param.dirs.subjs;
subjid_arr = ud2param.lists.subjs;
crtTempFailSeg = cell (ud2param.n_subjs,1);

parfor (i = 1 : ud2param.n_subjs, ud2param.exe.n_workers)

	diary (fullfile (subjs_dir, subjid_arr{i,1}, 'wmh', 'ud2', 'scripts', 'wmh_ud2.log'))

	t1 = fullfile (subjs_dir, subjid_arr{i,1}, 'wmh', 'ud2', 'preproc', 't1.nii');

	try
		% t1 segmentation
		% ===============
		if ud2param.exe.verbose
			fprintf ('%s : Calling wmh_ud2_spmbatch_segmentation for tissue segmentation on %s''s T1.\n', mfilename, subjid_arr{i,1});
		end
		[cGM,cWM,cCSF,rcGM,rcWM,rcCSF] = wmh_ud2_spmbatch_segmentation (ud2param, t1);

	catch ME

		fprintf (2,'\n%s : Exception thrown during calling wmh_ud2_spmbatch_segmentation for tissue segmentation.\n', mfilename);
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

		fprintf ('%s :\n', mfilename);
		fprintf ('%s : %s'' T1 failed segmentation therefore was excluded from creating cohort-specific templates.\n\n', mfilename, subjid_arr{i,1});

		rcGMcellArr_col{i,1}  = 'N/A';
		rcWMcellArr_col{i,1}  = 'N/A';
		rcCSFcellArr_col{i,1} = 'N/A';

		cGMcellArr_col{i,1}  = 'N/A';
		cWMcellArr_col{i,1}  = 'N/A';
		cCSFcellArr_col{i,1} = 'N/A';

		crtTempFailSeg{i,1} = subjid_arr{i,1};

		continue;
	end
	
	rcGMcellArr_col{i,1}  = rcGM;
	rcWMcellArr_col{i,1}  = rcWM;
	rcCSFcellArr_col{i,1} = rcCSF;

	cGMcellArr_col{i,1}  = cGM;
	cWMcellArr_col{i,1}  = cWM;
	cCSFcellArr_col{i,1} = cCSF;

	diary off

end

% eliminate elements with empty. the rest is IDs failed seg. assign to 
% ud2param.lists.crtTempFailSeg
ud2param.lists.crtTempFailSeg = crtTempFailSeg(find(~cellfun(@isempty,crtTempFailSeg)));

% deal with situations where there are segmentation failures
rcGMcellArr_col_noFail  = rcGMcellArr_col  (~strcmp(rcGMcellArr_col, 'N/A'));
rcWMcellArr_col_noFail  = rcWMcellArr_col  (~strcmp(rcWMcellArr_col, 'N/A'));
rcCSFcellArr_col_noFail = rcCSFcellArr_col (~strcmp(rcCSFcellArr_col,'N/A'));
cGMcellArr_col_noFail   = cGMcellArr_col   (~strcmp(cGMcellArr_col,  'N/A'));
cWMcellArr_col_noFail   = cWMcellArr_col   (~strcmp(cWMcellArr_col,  'N/A'));
cCSFcellArr_col_noFail  = cCSFcellArr_col  (~strcmp(cCSFcellArr_col, 'N/A'));

[flowMapCellArr,...
          temp0,...
          temp1,...
          temp2,...
          temp3,...
          temp4,...
          temp5,...
          temp6]    = wmh_ud2_spmbatch_runDARTELc (ud2param,...
      												rcGMcellArr_col_noFail, ...
	                                                rcWMcellArr_col_noFail, ...
	                                                rcCSFcellArr_col_noFail);

coh_temp_dir = fullfile(ud2param.dirs.subjs,'coh_temp');

if ~ isfolder (coh_temp_dir)
	mkdir (ud2param.dirs.subjs,'coh_temp');
end
movefile (temp0,fullfile(coh_temp_dir,'Template_0.nii'));
movefile (temp1,fullfile(coh_temp_dir,'Template_1.nii'));
movefile (temp2,fullfile(coh_temp_dir,'Template_2.nii'));
movefile (temp3,fullfile(coh_temp_dir,'Template_3.nii'));
movefile (temp4,fullfile(coh_temp_dir,'Template_4.nii'));
movefile (temp5,fullfile(coh_temp_dir,'Template_5.nii'));
movefile (temp6,fullfile(coh_temp_dir,'Template_6.nii'));

ud2param.templates.temp1_6{1,1} = fullfile(coh_temp_dir,'Template_1.nii');
ud2param.templates.temp1_6{2,1} = fullfile(coh_temp_dir,'Template_2.nii');
ud2param.templates.temp1_6{3,1} = fullfile(coh_temp_dir,'Template_3.nii');
ud2param.templates.temp1_6{4,1} = fullfile(coh_temp_dir,'Template_4.nii');
ud2param.templates.temp1_6{5,1} = fullfile(coh_temp_dir,'Template_5.nii');
ud2param.templates.temp1_6{6,1} = fullfile(coh_temp_dir,'Template_6.nii');

% generate cohort-specific prob maps
wcGMcellArr  = cell (size(cGMcellArr_col_noFail));
wcWMcellArr  = cell (size(cWMcellArr_col_noFail));
wcCSFcellArr = cell (size(cCSFcellArr_col_noFail));

parfor (i = 1 : size(cGMcellArr_col_noFail,1), ud2param.exe.n_workers)
	temp = [];
	temp.exe.verbose = true;
	wcGMcellArr{i,1}  = cns2_spmbatch_nativeToDARTEL (temp, cGMcellArr_col_noFail{i,1},  flowMapCellArr{i,1});
	wcWMcellArr{i,1}  = cns2_spmbatch_nativeToDARTEL (temp, cWMcellArr_col_noFail{i,1},  flowMapCellArr{i,1});
	wcCSFcellArr{i,1} = cns2_spmbatch_nativeToDARTEL (temp, cCSFcellArr_col_noFail{i,1}, flowMapCellArr{i,1});
end

GMavg  = cns2_spmbatch_imgCal   (ud2param, ...
									'avg', ...
	                                 coh_temp_dir, ...
	                                 'coh_GMprob', ...
	                                 size(wcGMcellArr,1), ...
	                                 wcGMcellArr);

WMavg  = cns2_spmbatch_imgCal   (ud2param, ...
									'avg', ...
	                                 coh_temp_dir, ...
	                                 'coh_WMprob', ...
	                                 size(wcWMcellArr,1), ...
	                                 wcWMcellArr);

CSFavg = cns2_spmbatch_imgCal   (ud2param, ...
									'avg', ...
	                                 coh_temp_dir, ...
	                                 'coh_CSFprob', ...
	                                 size(wcCSFcellArr,1), ...
	                                 wcCSFcellArr);

ud2param.templates.gmprob  = GMavg;
ud2param.templates.wmprob  = WMavg;
ud2param.templates.csfprob = CSFavg;

wmh_ud2_crtDartelTemp_finishTime = toc (wmh_ud2_crtDartelTemp_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), wmh_ud2_crtDartelTemp_finishTime);
fprintf ('%s : \n', mfilename);