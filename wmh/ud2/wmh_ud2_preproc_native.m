% varargin{1} = cell array of flow maps. 'creating templates' will generate
%				flow maps in addition to Template 0-6.

% switch flag
%
% 	case 'ud2'
% 		standard UBO Detector 2 call
% 		(ud2param,i) as input if using 'existing' templates
% 		(ud2param,i,flowmaps) as input if using 'creating' templates
%
% 	case 'general'
% 		wmh extracted from other software but full array of measures
% 		are required. Therefore, preproc is needed to bring all templates
% 		and atlases to native space. (t1,flair) as input in this case.
% end

function ud2param = wmh_ud2_preproc_native (flag,varargin)

wmh_ud2_preproc_native_startTime = tic;
fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

switch flag

	case 'ud2'

		ud2param = varargin{1};
		       i = varargin{2};

		if ud2param.exe.verbose
			fprintf ('%s : Using UBO Detector-segmented WMH (flag = ''ud2'').\n', mfilename);
		end
		
		t1    = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 't1.nii');
		flair = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'flair.nii');

		switch ud2param.templates.options{1}

		    case 'existing'

		    	% t1 segmentation
		    	% ===============
		    	if ud2param.exe.verbose
		    		fprintf ('%s : Using existing DARTEL templates.\n', mfilename);
					fprintf ('%s : Calling wmh_ud2_spmbatch_segmentation for tissue segmentation (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
				end

				[cGM,cWM,cCSF,rcGM,rcWM,rcCSF] = wmh_ud2_spmbatch_segmentation (ud2param, t1);

				if ud2param.exe.verbose
					fprintf ('%s : wmh_ud2_spmbatch_segmentation finished (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
				end

				% run DARTEL
				% ==========
				if ud2param.exe.verbose
					fprintf ('%s : Calling wmh_ud2_spmbatch_runDARTELe to run DARTEL with existing templates (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
				end

				flowmap = wmh_ud2_spmbatch_runDARTELe (ud2param, ...
													rcGM, rcWM, rcCSF, ...
													ud2param.templates.temp1_6{1,1}, ...
													ud2param.templates.temp1_6{2,1}, ...
													ud2param.templates.temp1_6{3,1}, ...
													ud2param.templates.temp1_6{4,1}, ...
													ud2param.templates.temp1_6{5,1}, ...
													ud2param.templates.temp1_6{6,1});

				if ud2param.exe.verbose
					fprintf ('%s : wmh_ud2_spmbatch_runDARTELe finished (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
				end

			case 'creating' && nargin==4 && strcmp(ud2param.templates.options{1},'creating')

				if ud2param.exe.verbose
		    		fprintf ('%s : Using created DARTEL templates.\n', mfilename);
				end

				flowmaps = varargin{3}; % creating templates will also generate flowmaps
										% which are passed as a cell array in the 3rd
										% argument.
				flowmap = flowmaps{i};
		end

		% templates used in classification back to native space
		if ud2param.exe.verbose
			fprintf ('%s : Calling wmh_ud2_spmbatch_DARTELtoNative for reverse warping GM/WM masks, GM/WM/CSF probability maps, and brain mask from DARTEL back to native T1 space (subject ID = %s).\n', mfilename, ...
																																							ud2param.lists.subjs{i,1});
		end

		gmmsk_t1spc   = wmh_ud2_spmbatch_DARTELtoNative (ud2param, ud2param.templates.gmmsk,   flowmap      );
		wmmsk_t1spc   = wmh_ud2_spmbatch_DARTELtoNative (ud2param, ud2param.templates.wmmsk,   flowmap      );
		gmprob_t1spc  = wmh_ud2_spmbatch_DARTELtoNative (ud2param, ud2param.templates.gmprob,  flowmap      );
		wmprob_t1spc  = wmh_ud2_spmbatch_DARTELtoNative (ud2param, ud2param.templates.wmprob,  flowmap      );
		csfprob_t1spc = wmh_ud2_spmbatch_DARTELtoNative (ud2param, ud2param.templates.csfprob, flowmap      );
		brnmsk_t1spc  = wmh_ud2_spmbatch_DARTELtoNative (ud2param, ud2param.templates.brnmsk,  flowmap, 'NN');

		% reslice t1spc images to t1 dimension.
		% wmh_ud2_spmbatch_DARTELtoNative only estimate, doesn't reslice.
		% those need further wmh_ud2_scripts_revReg will reslice in wmh_ud2_scripts_revReg.
		if ud2param.exe.verbose
			fprintf ('%s : Calling wmh_ud2_spmscripts_reslice to reslice reverse-warped GM/WM masks, GM/WM/CSF probability maps, and brain mask to native T1 space (subject ID = %s).\n', mfilename, ...
																																							ud2param.lists.subjs{i,1});
		end
		gmmsk_t1spc_resliced   = wmh_ud2_spmscripts_reslice (ud2param, t1, gmmsk_t1spc,   1);
		wmmsk_t1spc_resliced   = wmh_ud2_spmscripts_reslice (ud2param, t1, wmmsk_t1spc,   1);
		gmprob_t1spc_resliced  = wmh_ud2_spmscripts_reslice (ud2param, t1, gmprob_t1spc,  1);
		wmprob_t1spc_resliced  = wmh_ud2_spmscripts_reslice (ud2param, t1, wmprob_t1spc,  1);
		csfprob_t1spc_resliced = wmh_ud2_spmscripts_reslice (ud2param, t1, csfprob_t1spc, 1);
		brnmsk_t1spc_resliced  = wmh_ud2_spmscripts_reslice (ud2param, t1, brnmsk_t1spc,  0);
		% rename to avoid confusion with img resliced to FLAIR space
		[gmmsk_t1spc_resliced_dir, gmmsk_t1spc_resliced_fname, gmmsk_t1spc_resliced_ext] = fileparts (gmmsk_t1spc_resliced);
		[wmmsk_t1spc_resliced_dir, wmmsk_t1spc_resliced_fname, wmmsk_t1spc_resliced_ext] = fileparts (wmmsk_t1spc_resliced);
		[gmprob_t1spc_resliced_dir, gmprob_t1spc_resliced_fname, gmprob_t1spc_resliced_ext] = fileparts (gmprob_t1spc_resliced);
		[wmprob_t1spc_resliced_dir, wmprob_t1spc_resliced_fname, wmprob_t1spc_resliced_ext] = fileparts (wmprob_t1spc_resliced);
		[csfprob_t1spc_resliced_dir, csfprob_t1spc_resliced_fname, csfprob_t1spc_resliced_ext] = fileparts (csfprob_t1spc_resliced);
		[brnmsk_t1spc_resliced_dir, brnmsk_t1spc_resliced_fname, brnmsk_t1spc_resliced_ext] = fileparts (brnmsk_t1spc_resliced);
		movefile (gmmsk_t1spc_resliced, fullfile (gmmsk_t1spc_resliced_dir, [gmmsk_t1spc_resliced_fname '_t1spc' gmmsk_t1spc_resliced_ext]));
		movefile (wmmsk_t1spc_resliced, fullfile (wmmsk_t1spc_resliced_dir, [wmmsk_t1spc_resliced_fname '_t1spc' wmmsk_t1spc_resliced_ext]));
		movefile (gmprob_t1spc_resliced, fullfile (gmprob_t1spc_resliced_dir, [gmprob_t1spc_resliced_fname '_t1spc' gmprob_t1spc_resliced_ext]));
		movefile (wmprob_t1spc_resliced, fullfile (wmprob_t1spc_resliced_dir, [wmprob_t1spc_resliced_fname '_t1spc' wmprob_t1spc_resliced_ext]));
		movefile (csfprob_t1spc_resliced, fullfile (csfprob_t1spc_resliced_dir, [csfprob_t1spc_resliced_fname '_t1spc' csfprob_t1spc_resliced_ext]));
		movefile (brnmsk_t1spc_resliced, fullfile (brnmsk_t1spc_resliced_dir, [brnmsk_t1spc_resliced_fname '_t1spc' brnmsk_t1spc_resliced_ext]));

		if ud2param.exe.verbose
			fprintf ('%s : Finish reverse warping GM/WM masks, GM/WM/CSF probability maps, and brain mask from DARTEL to native T1 space (subject ID = %s).\n', mfilename, ...
																																								ud2param.lists.subjs{i,1});
		end

		if ud2param.exe.verbose
			fprintf ('%s : Calling wmh_ud2_scripts_revReg for reverse registering GM/WM masks, GM/WM/CSF probability maps, and brain mask from native T1 to native FLAIR space (subject ID = %s).\n', mfilename, ...
																																							ud2param.lists.subjs{i,1});
		end

		gmmsk_flairSpc   = wmh_ud2_scripts_revReg (ud2param, flair, t1, gmmsk_t1spc,   'Tri');
		wmmsk_flairSpc   = wmh_ud2_scripts_revReg (ud2param, flair, t1, wmmsk_t1spc,   'Tri');
		gmprob_flairSpc  = wmh_ud2_scripts_revReg (ud2param, flair, t1, gmprob_t1spc,  'Tri');
		wmprob_flairSpc  = wmh_ud2_scripts_revReg (ud2param, flair, t1, wmprob_t1spc,  'Tri');
		csfprob_flairSpc = wmh_ud2_scripts_revReg (ud2param, flair, t1, csfprob_t1spc, 'Tri');
		brnmsk_flairSpc  = wmh_ud2_scripts_revReg (ud2param, flair, t1, brnmsk_t1spc        );
		% rename to avoid confusion with img resliced to T1 space
		[gmmsk_flairSpc_dir, gmmsk_flairSpc_fname, gmmsk_flairSpc_ext] = fileparts (gmmsk_flairSpc);
		[wmmsk_flairSpc_dir, wmmsk_flairSpc_fname, wmmsk_flairSpc_ext] = fileparts (wmmsk_flairSpc);
		[gmprob_flairSpc_dir, gmprob_flairSpc_fname, gmprob_flairSpc_ext] = fileparts (gmprob_flairSpc);
		[wmprob_flairSpc_dir, wmprob_flairSpc_fname, wmprob_flairSpc_ext] = fileparts (wmprob_flairSpc);
		[csfprob_flairSpc_dir, csfprob_flairSpc_fname, csfprob_flairSpc_ext] = fileparts (csfprob_flairSpc);
		[brnmsk_flairSpc_dir, brnmsk_flairSpc_fname, brnmsk_flairSpc_ext] = fileparts (brnmsk_flairSpc);
		movefile (gmmsk_flairSpc, fullfile (gmmsk_flairSpc_dir, [gmmsk_flairSpc_fname '_flairspc' gmmsk_flairSpc_ext]));
		movefile (wmmsk_flairSpc, fullfile (wmmsk_flairSpc_dir, [wmmsk_flairSpc_fname '_flairspc' wmmsk_flairSpc_ext]));
		movefile (gmprob_flairSpc, fullfile (gmprob_flairSpc_dir, [gmprob_flairSpc_fname '_flairspc' gmprob_flairSpc_ext]));
		movefile (wmprob_flairSpc, fullfile (wmprob_flairSpc_dir, [wmprob_flairSpc_fname '_flairspc' wmprob_flairSpc_ext]));
		movefile (csfprob_flairSpc, fullfile (csfprob_flairSpc_dir, [csfprob_flairSpc_fname '_flairspc' csfprob_flairSpc_ext]));
		movefile (brnmsk_flairSpc, fullfile (brnmsk_flairSpc_dir, [brnmsk_flairSpc_fname '_flairspc' brnmsk_flairSpc_ext]));
		gmmsk_flairSpc = fullfile (gmmsk_flairSpc_dir, [gmmsk_flairSpc_fname '_flairspc' gmmsk_flairSpc_ext]);
		wmmsk_flairSpc = fullfile (wmmsk_flairSpc_dir, [wmmsk_flairSpc_fname '_flairspc' wmmsk_flairSpc_ext]);
		gmprob_flairSpc = fullfile (gmprob_flairSpc_dir, [gmprob_flairSpc_fname '_flairspc' gmprob_flairSpc_ext]);
		wmprob_flairSpc = fullfile (wmprob_flairSpc_dir, [wmprob_flairSpc_fname '_flairspc' wmprob_flairSpc_ext]);
		csfprob_flairSpc = fullfile (csfprob_flairSpc_dir, [csfprob_flairSpc_fname '_flairspc' csfprob_flairSpc_ext]);
		brnmsk_flairSpc = fullfile (brnmsk_flairSpc_dir, [brnmsk_flairSpc_fname '_flairspc' brnmsk_flairSpc_ext]);

		delete (gmmsk_t1spc);
		delete (wmmsk_t1spc);
		delete (gmprob_t1spc);
		delete (wmprob_t1spc);
		delete (csfprob_t1spc);
		delete (brnmsk_t1spc);

		gmmsk_t1spc = fullfile (gmmsk_t1spc_resliced_dir, [gmmsk_t1spc_resliced_fname '_t1spc' gmmsk_t1spc_resliced_ext]);
		wmmsk_t1spc = fullfile (wmmsk_t1spc_resliced_dir, [wmmsk_t1spc_resliced_fname '_t1spc' wmmsk_t1spc_resliced_ext]);
		gmprob_t1spc = fullfile (gmprob_t1spc_resliced_dir, [gmprob_t1spc_resliced_fname '_t1spc' gmprob_t1spc_resliced_ext]);
		wmprob_t1spc = fullfile (wmprob_t1spc_resliced_dir, [wmprob_t1spc_resliced_fname '_t1spc' wmprob_t1spc_resliced_ext]);
		csfprob_t1spc = fullfile (csfprob_t1spc_resliced_dir, [csfprob_t1spc_resliced_fname '_t1spc' csfprob_t1spc_resliced_ext]);
		brnmsk_t1spc = fullfile (brnmsk_t1spc_resliced_dir, [brnmsk_t1spc_resliced_fname '_t1spc' brnmsk_t1spc_resliced_ext]);

		if ud2param.exe.verbose
			fprintf ('%s : Finish reverse registering GM/WM masks, GM/WM/CSF probability maps, and brain mask from native T1 to native FLAIR space (subject ID = %s).\n', mfilename, ...
																																							ud2param.lists.subjs{i,1});
		end

		% mask native flair and t1
		if ud2param.exe.verbose
			fprintf ('%s : Calling wmh_ud2_scripts_mask to apply brain mask to native T1 and FLAIR (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
		end

		wmh_ud2_scripts_mask  (ud2param, flair, brnmsk_flairSpc, ...
								fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'flair_brn.nii'));
		wmh_ud2_scripts_mask  (ud2param, t1, brnmsk_t1spc, ...
								fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 't1_brn.nii'));

		if ud2param.exe.verbose
			fprintf ('%s : Finished masking native T1 and FLAIR (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
		end

		% rename to be more self-explanatory
		if ud2param.exe.verbose
			fprintf ('%s : Renaming T1/FLAIR space GM/WM/brain masks, and GM/WM/CSF probability maps (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
		end
		movefile (gmmsk_t1spc,     fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'gmmsk_t1spc.nii'     ));
		movefile (wmmsk_t1spc,     fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'wmmsk_t1spc.nii'     ));
		movefile (gmprob_t1spc,    fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'gmprob_t1spc.nii'    ));
		movefile (wmprob_t1spc,    fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'wmprob_t1spc.nii'    ));
		movefile (csfprob_t1spc,   fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'csfprob_t1spc.nii'   ));
		movefile (brnmsk_t1spc,    fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'brnmsk_t1spc.nii'    ));
		movefile (gmmsk_flairSpc,  fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'gmmsk_flairSpc.nii'  ));
		movefile (wmmsk_flairSpc,  fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'wmmsk_flairSpc.nii'  ));
		movefile (gmprob_flairSpc, fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'gmprob_flairSpc.nii' ));
		movefile (wmprob_flairSpc, fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'wmprob_flairSpc.nii' ));
		movefile (csfprob_flairSpc,fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'csfprob_flairSpc.nii'));
		movefile (brnmsk_flairSpc, fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'brnmsk_flairSpc.nii' ));

		% update ud2param
		if ud2param.exe.verbose
			fprintf ('%s : Updading ud2param.templates to use FLAIR-space GM/WM/brain masks and GM/WM/CSF probability maps (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
		end
		ud2param.templates.gmmsk   = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'gmmsk_flairSpc.nii'  );
		ud2param.templates.wmmsk   = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'wmmsk_flairSpc.nii'  );
		ud2param.templates.gmprob  = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'gmprob_flairSpc.nii' );
		ud2param.templates.wmprob  = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'wmprob_flairSpc.nii' );
		ud2param.templates.csfprob = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'csfprob_flairSpc.nii');
		ud2param.templates.brnmsk  = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'brnmsk_flairSpc.nii' );


	case 'general' % ==> need to test (31/10/2022)

		global ud2param % calling the global variable

		if ud2param.exe.verbose
			fprintf ('%s : Using WMH generated from other sources (flag = ''general'').\n', mfilename);
		end

		wmh_ud2_templates06_dir = fullfile(fileparts(fileparts(mfilename)),'templates','DARTEL_0to6_templates','65to75');
		t1    = varargin{1}; % pass t1 and flair path. Organise as the same folder structure as UBD. Also need to assign ud2param, such as lists.subjs.
		flair = varargin{2};
		
		% t1 segmentation
		% ===============
		if ud2param.exe.verbose
			fprintf ('%s : Calling wmh_ud2_spmbatch_segmentation for tissue segmentation (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
		end

		[cGM,cWM,cCSF,rcGM,rcWM,rcCSF] = wmh_ud2_spmbatch_segmentation (ud2param, t1);

		if ud2param.exe.verbose
			fprintf ('%s : wmh_ud2_spmbatch_segmentation finished (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
		end

		% run DARTEL
		% ==========
		if ud2param.exe.verbose
			fprintf ('%s : Calling wmh_ud2_spmbatch_runDARTELe to run DARTEL with existing templates (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
		end

		flowmap = wmh_ud2_spmbatch_runDARTELe (ud2param, ...
											rcGM, rcWM, rcCSF, ...
											fullfile(wmh_ud2_templates06_dir,'Template_1.nii'), ...
											fullfile(wmh_ud2_templates06_dir,'Template_2.nii'), ...
											fullfile(wmh_ud2_templates06_dir,'Template_3.nii'), ...
											fullfile(wmh_ud2_templates06_dir,'Template_4.nii'), ...
											fullfile(wmh_ud2_templates06_dir,'Template_5.nii'), ...
											fullfile(wmh_ud2_templates06_dir,'Template_6.nii'));

		if ud2param.exe.verbose
			fprintf ('%s : wmh_ud2_spmbatch_runDARTELe finished (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
		end
end


% Templates for quantification to native space
if ud2param.exe.verbose
	fprintf ('%s : Calling wmh_ud2_spmbatch_DARTELtoNative for reverse warping ventricular distance map, lobar atlas, and arterial territory atlas from DARTEL back to native T1 space (subject ID = %s).\n', mfilename, ...
																																					ud2param.lists.subjs{i,1});
end

ventdst_t1spc  = wmh_ud2_spmbatch_DARTELtoNative (ud2param, ud2param.templates.ventdst,  flowmap      );
lobar_t1spc    = wmh_ud2_spmbatch_DARTELtoNative (ud2param, ud2param.templates.lobar,    flowmap, 'NN');
arterial_t1spc = wmh_ud2_spmbatch_DARTELtoNative (ud2param, ud2param.templates.arterial, flowmap, 'NN');

if ud2param.exe.verbose
	fprintf ('%s : Finish reverse warping ventricular distance map, lobar atlas, and arterial territory atlas from DARTEL to native T1 space (subject ID = %s).\n', mfilename, ...
																																						ud2param.lists.subjs{i,1});
end

if ud2param.exe.verbose
	fprintf ('%s : Calling wmh_ud2_scripts_revReg for reverse registering ventricular distance map, lobar atlas, and arterial territory atlas from native T1 to native FLAIR space (subject ID = %s).\n', mfilename, ...
																																					ud2param.lists.subjs{i,1});
end

ventdst_flairSpc  = wmh_ud2_scripts_revReg (ud2param, flair, t1, ventdst_t1spc,   'Tri');
lobar_flairSpc    = wmh_ud2_scripts_revReg (ud2param, flair, t1, lobar_t1spc           );
arterial_flairSpc = wmh_ud2_scripts_revReg (ud2param, flair, t1, arterial_t1spc        );

if ud2param.exe.verbose
	fprintf ('%s : Finish reverse registering ventricular distance map, lobar atlas, and arterial territory atlas from native T1 to native FLAIR space (subject ID = %s).\n', mfilename, ...
																																					ud2param.lists.subjs{i,1});
end

% rename to be more self-explanatory
if ud2param.exe.verbose
	fprintf ('%s : Renaming T1/FLAIR space ventricular distance map, lobar atlas, and arterial territory atlas (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end
movefile (ventdst_t1spc,    fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'ventdst_t1spc.nii'    ));
movefile (lobar_t1spc,      fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'lobar_t1spc.nii'      ));
movefile (arterial_t1spc,   fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'arterial_t1spc.nii'   ));
movefile (ventdst_flairSpc, fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'ventdst_flairSpc.nii' ));
movefile (lobar_flairSpc,   fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'lobar_flairSpc.nii'   ));
movefile (arterial_flairSpc,fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'arterial_flairSpc.nii'));

% update ud2param
if ud2param.exe.verbose
	fprintf ('%s : Updading ud2param.templates to use FLAIR-space ventricular distance map, lobar atlas, and arterial territory atlas (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end
ud2param.templates.ventdst  = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'ventdst_flairSpc.nii' );
ud2param.templates.lobar    = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'lobar_flairSpc.nii'   );
ud2param.templates.arterial = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'wmh', 'ud2', 'preproc', 'arterial_flairSpc.nii');


wmh_ud2_preproc_native_finishTime = toc (wmh_ud2_preproc_native_startTime);
fprintf ('%s : Finished (subject ID = %s; %s; %.4f seconds elapsed.\n', mfilename, ud2param.lists.subjs{i,1}, string(datetime), wmh_ud2_preproc_native_finishTime);
fprintf ('%s :\n', mfilename);