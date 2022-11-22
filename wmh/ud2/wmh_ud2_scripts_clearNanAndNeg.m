function varargout = wmh_ud2_scripts_clearNanAndNeg (ud2param, in_img, flag, varargin)
%
% This script replace NaN and negative values with zeros. This is
% useful after, e.g., DARTEL to native space warping, where some
% values on the warped images are NaN or negative.
%
% flag = 'overwrite' or 'new_img'
%
% if strcmp (flag, 'new_img')
% 	path_to_new_img = varargin{1};
% end
%
% varargout{1} = path to out img.
%
% NOTE that SPM12 needs to be in path.
%
%
% 22 Nov 2022, written by Jiyang Jiang
%
wmh_ud2_scripts_clearNanAndNeg_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

in_dat = spm_read_vols (spm_vol (in_img));

if ud2param.exe.verbose
	fprintf ('%s : NaN and negative values will be replaced with zeros.\n', mfilename);
end

in_dat(isnan(in_dat)) = 0; % replace NaN with zeros

in_dat(in_dat<0) = 0; % replace negative values with zeros

switch flag
	case 'overwrite'
		out = in_img;
	case 'new_img'
		out = varargin{1};
end

wmh_ud2_scripts_writeNii (ud2param, spm_vol (in_img), in_dat, out)

varargout{1} = out;

wmh_ud2_scripts_clearNanAndNeg_finishTime = toc (wmh_ud2_scripts_clearNanAndNeg_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed.\n', mfilename, string(datetime), wmh_ud2_scripts_clearNanAndNeg_finishTime);
fprintf ('%s :\n', mfilename);