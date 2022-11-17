% Standard CNS2 UD call:
%
% 	varargin{1} = ud2param
% 	varargin{2} = subject's id in cns2
%
% ALTERNATIVELY, if wmh results from any software, and full array of 
%                measures are required. (To be developed)
%
% 	varargin{1} = t1
%
%
% ALTERNATIVELY, if wmh results from any software, and only global
%                volume is required.
%
% 	only 'wmhmask_dat' and 'flair' is required.
%   no need to pass varargin

function vol_tbl = wmh_ud2_postproc_quantification_vol (wmhmask_dat,flair,varargin)

curr_cmd=mfilename;

% voxel size
vol=spm_vol(flair);
voxsiz = abs(det(vol.mat));

% ++++++++++++++++++++++++++
% standard call from cns2 ud
% ++++++++++++++++++++++++++
if nargin==4
	ud2param = varargin{1};
	subjid    = varargin{2};

	if ud2param.exe.verbose 
		fprintf ('%s : quantifying volume for %s.\n', curr_cmd, subjid);
	end

	% whole brain WMH vol
	wbwmh_vol = sum(nonzeros(wmhmask_dat)) * voxsiz;

	% separation between PVWMH and DWMH
	ventdst_dat = spm_read_vols(spm_vol(ud2param.templates.ventdst));
	pv_mask = ventdst_dat < ud2param.quantification.ud.pvmag;
	pvwmh_dat = wmhmask_dat .* pv_mask;
	dwmh_dat = wmhmask_dat - pvwmh_dat; % NOTE that dwmh vol calculated this way may be
										% larger than summing all ROIs together as some
										% wmh voxels may not fall in ROI atlas.
	pvwmh_vol = sum(nonzeros(pvwmh_dat)) * voxsiz;
	dwmh_vol  = sum(nonzeros(dwmh_dat))  * voxsiz;

	% lobar measures
	lobar_atlas_dat = spm_read_vols(spm_vol(ud2param.templates.lobar));
	dwmh_lobar_dat = dwmh_dat .* lobar_atlas_dat;

	inDwmhNotInLobAtlas = dwmh_dat - (dwmh_lobar_dat>0);
	inDwmhAndInHorns    = (dwmh_lobar_dat==8) + ...
						  (dwmh_lobar_dat==9) + ...
						  (dwmh_lobar_dat==10) + ...
						  (dwmh_lobar_dat==13) + ...
						  (dwmh_lobar_dat==14) + ...
						  (dwmh_lobar_dat==15);
	unid_lob_dat = inDwmhNotInLobAtlas + inDwmhAndInHorns; % those unidentified in lobar template
														   % including those in ventricular horns

	lfron_dat  = dwmh_lobar_dat==7;
	rfron_dat  = dwmh_lobar_dat==6;
	ltemp_dat  = dwmh_lobar_dat==4;
	rtemp_dat  = dwmh_lobar_dat==5;
	lpari_dat  = dwmh_lobar_dat==17;
	rpari_dat  = dwmh_lobar_dat==16;
	locci_dat  = dwmh_lobar_dat==12;
	rocci_dat  = dwmh_lobar_dat==11;
	lcere_dat  = dwmh_lobar_dat==2;
	rcere_dat  = dwmh_lobar_dat==1;
	brnstm_dat = dwmh_lobar_dat==3;

	lfron_vol    = sum(nonzeros(lfron_dat))    * voxsiz;
	rfron_vol    = sum(nonzeros(rfron_dat))    * voxsiz;
	ltemp_vol    = sum(nonzeros(ltemp_dat))    * voxsiz;
	rtemp_vol    = sum(nonzeros(rtemp_dat))    * voxsiz;
	lpari_vol    = sum(nonzeros(lpari_dat))    * voxsiz;
	rpari_vol    = sum(nonzeros(rpari_dat))    * voxsiz;
	locci_vol    = sum(nonzeros(locci_dat))    * voxsiz;
	rocci_vol    = sum(nonzeros(rocci_dat))    * voxsiz;
	lcere_vol    = sum(nonzeros(lcere_dat))    * voxsiz;
	rcere_vol    = sum(nonzeros(rcere_dat))    * voxsiz;
	brnstm_vol   = sum(nonzeros(brnstm_dat))   * voxsiz;
	unid_lob_vol = sum(nonzeros(unid_lob_dat)) * voxsiz;

	% arterial territories measures
	arterial_atlas_dat = spm_read_vols(spm_vol(ud2param.templates.arterial));
	wmh_arterial_dat = wmhmask_dat .* arterial_atlas_dat;

	unid_art_dat = wmhmask_dat - (wmh_arterial_dat>0); % those unidentified in arterial template

	raah_dat   = wmh_arterial_dat==1;
	laah_dat   = wmh_arterial_dat==2;
	rmah_dat   = wmh_arterial_dat==3;
	lmah_dat   = wmh_arterial_dat==6;
	raaml_dat  = wmh_arterial_dat==13;
	laaml_dat  = wmh_arterial_dat==14;
	raac_dat   = wmh_arterial_dat==7;
	laac_dat   = wmh_arterial_dat==8;
	rmall_dat  = wmh_arterial_dat==9;
	lmall_dat  = wmh_arterial_dat==10;
	rpatmp_dat = wmh_arterial_dat==11;
	lpatmp_dat = wmh_arterial_dat==12;
	rpah_dat   = wmh_arterial_dat==4;
	lpah_dat   = wmh_arterial_dat==5;
	rpac_dat   = wmh_arterial_dat==15;
	lpac_dat   = wmh_arterial_dat==16;

	raah_vol     = sum(nonzeros(raah_dat    )) * voxsiz; 
	laah_vol     = sum(nonzeros(laah_dat    )) * voxsiz; 
	rmah_vol     = sum(nonzeros(rmah_dat    )) * voxsiz; 
	lmah_vol     = sum(nonzeros(lmah_dat    )) * voxsiz; 
	raaml_vol    = sum(nonzeros(raaml_dat   )) * voxsiz; 
	laaml_vol    = sum(nonzeros(laaml_dat   )) * voxsiz; 
	raac_vol     = sum(nonzeros(raac_dat    )) * voxsiz; 
	laac_vol     = sum(nonzeros(laac_dat    )) * voxsiz; 
	rmall_vol    = sum(nonzeros(rmall_dat   )) * voxsiz; 
	lmall_vol    = sum(nonzeros(lmall_dat   )) * voxsiz; 
	rpatmp_vol   = sum(nonzeros(rpatmp_dat  )) * voxsiz; 
	lpatmp_vol   = sum(nonzeros(lpatmp_dat  )) * voxsiz; 
	rpah_vol     = sum(nonzeros(rpah_dat    )) * voxsiz; 
	lpah_vol     = sum(nonzeros(lpah_dat    )) * voxsiz; 
	rpac_vol     = sum(nonzeros(rpac_dat    )) * voxsiz; 
	lpac_vol     = sum(nonzeros(lpac_dat    )) * voxsiz;
	unid_art_vol = sum(nonzeros(unid_art_dat)) * voxsiz;

	vol_tbl = table (wbwmh_vol, pvwmh_vol, dwmh_vol, ...
					 lfron_vol, rfron_vol, ...
					 ltemp_vol, rtemp_vol, ...
					 lpari_vol, rpari_vol, ...
					 locci_vol, rocci_vol, ...
					 lcere_vol, rcere_vol, ...
					 brnstm_vol, ...
					 unid_lob_vol, ...
					 raah_vol,    laah_vol, ... 
					 rmah_vol,    lmah_vol, ...
					 raaml_vol,   laaml_vol, ...
					 raac_vol,    laac_vol, ...
					 rmall_vol,   lmall_vol, ...
					 rpatmp_vol,  lpatmp_vol, ...
					 rpah_vol,    lpah_vol, ...
					 rpac_vol,    lpac_vol, ...
					 unid_art_vol);

% ++++++++++++++++++++++++++++++++++++++++
% only global wmh vol
% can be used on results from any software
% ++++++++++++++++++++++++++++++++++++++++
elseif nargin==2

	% whole brain WMH vol
	wbwmh_vol = sum(nonzeros(wmhmask_dat)) * voxsiz;
	vol_tbl = table(wbwmh_vol);

% +++++++++++++++++++++++++++++++++++++++++++
% global + pvwmh + dwmh
% can be used on results from any software
% as long as t1 is passed as the 3rd argument
% +++++++++++++++++++++++++++++++++++++++++++
elseif nargin==3
	t1    = varargin{1};
end



