function ME = wmh_handleErrMsg (params, ME)

fprintf ('%s :\n', mfilename);

% whether SPM path is properly set.
% try
% 	assert (isfolder (params.global.directories.spm12), 'wmh:SpmPathNotSet', 'SPM12 path is not properly set.');
% catch spmPathCausedException
% 	ME = addCause (ME, spmPathCausedException);
% end


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
fprintf ('%s :\n', mfilename);
