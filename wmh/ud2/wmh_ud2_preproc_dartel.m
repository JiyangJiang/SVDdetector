% varargin{1} = cell array of flow maps. 'creating templates' will generate
%				flow maps in addition to Template 0-6.

function wmh_ud2_preproc_dartel (ud2param,i,varargin)

wmh_ud2_preproc_dartel_startTime = tic;
fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

if nargin==3 && strcmp(ud2param.templates.options{1},'creating')
	flowmaps = varargin{1}; % creating templates will also generate flowmaps
							% which are passed as a cell array in the 3rd
							% argument.
end

t1    = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'ud', 'preproc', 't1.nii');
flair = fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'ud', 'preproc', 'flair.nii');

% coregistration
% ==============
if ud2param.exe.verbose
	fprintf ('%s : Calling cns2_spmbatch_coregistration to register FLAIR to T1 (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end

rflair = cns2_spmbatch_coregistration (ud2param, flair, t1, 'same_dir');

if ud2param.exe.verbose
	fprintf ('%s : cns2_spmbatch_coregistration finished (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end

switch ud2param.templates.options{1}

    case 'existing'

    	% t1 segmentation
    	% ===============
    	if ud2param.exe.verbose
			fprintf ('%s : Calling cns2_spmbatch_segmentation for tissue segmentation (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
		end

		[cGM,cWM,cCSF,rcGM,rcWM,rcCSF] = cns2_spmbatch_segmentation (ud2param, t1);

		if ud2param.exe.verbose
			fprintf ('%s : cns2_spmbatch_segmentation finished (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
		end

		% run DARTEL
		% ==========
		if ud2param.exe.verbose
			fprintf ('%s : Calling cns2_spmbatch_runDARTELe to run DARTEL with existing templates (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
		end

		flowmap = cns2_spmbatch_runDARTELe (ud2param, ...
											rcGM, rcWM, rcCSF, ...
											ud2param.templates.temp1_6{1,1}, ...
											ud2param.templates.temp1_6{2,1}, ...
											ud2param.templates.temp1_6{3,1}, ...
											ud2param.templates.temp1_6{4,1}, ...
											ud2param.templates.temp1_6{5,1}, ...
											ud2param.templates.temp1_6{6,1});

		if ud2param.exe.verbose
			fprintf ('%s : cns2_spmbatch_runDARTELe finished (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
		end

	case 'creating'

		flowmap = flowmaps{i};
		
end



% bring t1, flair, gm, wm, csf to DARTEL space (create warped)
% ============================================================
if ud2param.exe.verbose
	fprintf ('%s : Calling cns2_spmbatch_nativeToDARTEL to apply flowmap to warp T1, rFLAIR, cGM, cWM, and cCSF to DARTEL space (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end

wt1     = cns2_spmbatch_nativeToDARTEL (ud2param, t1,     flowmap);
wrflair = cns2_spmbatch_nativeToDARTEL (ud2param, rflair, flowmap);
wcGM    = cns2_spmbatch_nativeToDARTEL (ud2param, cGM,    flowmap);
wcWM    = cns2_spmbatch_nativeToDARTEL (ud2param, cWM,    flowmap);
wcCSF   = cns2_spmbatch_nativeToDARTEL (ud2param, cCSF,   flowmap);

if ud2param.exe.verbose
	fprintf ('%s : Finished warping T1, rFLAIR, cGM, cWM, and cCSF to DARTEL space (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end

% mask wrflair and wt1
% ====================
if ud2param.exe.verbose
	fprintf ('%s : Calling cns2_scripts_mask to apply brain mask to warped T1 (wT1) and FLAIR (wrFLAIR) (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end

cns2_scripts_mask  (ud2param, ...
					wt1, ...
					ud2param.templates.brnmsk, ...
					fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'ud', 'preproc', 'wt1_brn.nii'));
cns2_scripts_mask  (ud2param, ...
					wrflair, ...
					ud2param.templates.brnmsk, ...
					fullfile (ud2param.dirs.subjs, ud2param.lists.subjs{i,1}, 'ud', 'preproc', 'wrflair_brn.nii'));

if ud2param.exe.verbose
	fprintf ('%s : Finished masking warped T1 (wT1) and FLAIR (wrFLAIR) (subject ID = %s).\n', mfilename, ud2param.lists.subjs{i,1});
end


wmh_ud2_preproc_dartel_finishTime = toc (wmh_ud2_preproc_dartel_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed.\n', mfilename, string(datetime), wmh_ud2_preproc_dartel_finishTime);
fprintf ('%s :\n', mfilename);