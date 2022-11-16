% varargin{1} = '4d'
function cns2_scripts_writeNii (cns2param, vol, dat, out, varargin)
	
	cns2_scripts_writeNii_startTime = tic;

	fprintf ('%s :\n', mfilename);
	fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

	[outdir,fname,ext] = fileparts (out);

	if cns2param.exe.verbose
		fprintf ('%s : Writing nifti %s.\n', mfilename, out);
	end

	% write 4D nii
	if nargin == 5 && strcmp (varargin{1},'4d')
		if cns2param.exe.verbose
			fprintf ('%s : %s is 4D.\n', mfilename, [fname ext]);
		end
		for i = 1:size (dat,4)
			split_vols{i,1} = fullfile (outdir, [fname '_' num2str(i) ext]);
			writeNii (vol, dat(:,:,:,i), split_vols{i,1});
		end
		spm_file_merge (split_vols,out);
	% write 3D nii
	elseif nargin == 4
		if cns2param.exe.verbose
			fprintf ('%s : %s is 3D.\n', mfilename, [fname ext]);
		end
		writeNii (vol, dat, out);
	end

	if cns2param.exe.verbose
		fprintf ('%s : %s is written.\n', mfilename, out);
	end

	cns2_scripts_writeNii_finishTime = toc (cns2_scripts_writeNii_startTime);
	fprintf ('%s : Finished (%s; %.4f seconds elapsed.\n', mfilename, string(datetime), cns2_scripts_writeNii_finishTime);
	fprintf ('%s :\n', mfilename);

end


function writeNii (vol, dat, out)
	vol.fname = out;
	vol.private.dat.fname = out;
	spm_write_vol (vol,dat);
end