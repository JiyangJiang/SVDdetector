% varargin{1} = '4d'
function wmh_ud2_scripts_writeNii (ud2param, vol, dat, out, varargin)
	
	ud2_scripts_writeNii_startTime = tic;

	fprintf ('%s :\n', mfilename);
	fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

	[outdir,fname,ext] = fileparts (out);

	if ud2param.exe.verbose
		fprintf ('%s : Writing nifti %s.\n', mfilename, out);
	end

	% write 4D nii
	if nargin == 5 && strcmp (varargin{1},'4d')
		if ud2param.exe.verbose
			fprintf ('%s : %s is 4D.\n', mfilename, [fname ext]);
		end
		for i = 1:size (dat,4)
			split_vols{i,1} = fullfile (outdir, [fname '_' num2str(i) ext]);
			writeNii (vol, dat(:,:,:,i), split_vols{i,1});
		end
		spm_file_merge (split_vols,out); % merge all split 3D imgs to 4D
		delete (split_vols{:,1}); % remove split 3D imgs
	% write 3D nii
	elseif nargin == 4
		if ud2param.exe.verbose
			fprintf ('%s : %s is 3D.\n', mfilename, [fname ext]);
		end
		writeNii (vol, dat, out);
	end

	if ud2param.exe.verbose
		fprintf ('%s : %s is written.\n', mfilename, out);
	end

	ud2_scripts_writeNii_finishTime = toc (ud2_scripts_writeNii_startTime);
	fprintf ('%s : Finished (%s; %.4f seconds elapsed.\n', mfilename, string(datetime), ud2_scripts_writeNii_finishTime);
	fprintf ('%s :\n', mfilename);

end


function writeNii (vol, dat, out)
	vol.fname = out;
	vol.private.dat.fname = out;
	spm_write_vol (vol,dat);
end