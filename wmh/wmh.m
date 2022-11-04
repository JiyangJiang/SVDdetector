clear global params;
clear;clc
global params

svddDirectory = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\SVDdetector';
spm12directory = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12';
studyDirectory = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2_example_data';

flairDistinctIntensityBtwGmWm = true;
verbose = true;

spm_segment_channels = 'T1+FLAIR';

addpath (genpath (svddDirectory));

wmh_startTime = tic;
fprintf ('%s :\n', mfilename);
fprintf ('%s : Starting WMH pipeline (%s).\n', mfilename, string(datetime));


% set parameters
try
	global_params (svddDirectory, spm12directory, studyDirectory, verbose);
	wmh_params (spm_segment_channels);
catch ME
	fprintf (2,'\nException thrown\n');
	fprintf (2,'++++++++++++++++++++++\n');
	fprintf (2,'identifier: %s\n', ME.identifier);
	fprintf (2,'message: %s\n\n', ME.message);

	fprintf ('%s : SVDdetector aborted during setting params.\n', mfilename);

	error ('SVDdetector aborted during setting params.');
end


% processing T1 + FLAIR

pairedT1FlairProcessing_startTime = tic;

for i = 1 : params.global.numbers.pairedT1Flair

	fprintf ('%s : Started processing %s with both T1 and FLAIR.\n', mfilename, ...
			 params.global.subjID.pairedT1Flair {i,1});

	try

		wmh_initFilesDirs (params, 'paired', i); % initialise folders and copy files

		diary (fullfile (params.global.directories.subjects, ...
						 params.global.subjID.pairedT1Flair {i,1}, ...
						 'wmh', 'scripts', 'cns2_ud.log'));

		wmh_spmbatchCoregSeg (params, 'paired', i); % FLAIR->T1 coreg + 2-channel seg

		fprintf ('%s : %s finished without error.\n', mfilename, params.global.subjID.pairedT1Flair {i,1});
		fprintf ('%s :\n', mfilename);

		diary off

		params.wmh.success.pairedT1Flair {i,2} = 0;
	
	catch ME

		fprintf (2,'\nException thrown\n');
		fprintf (2,'++++++++++++++++++++++\n');
		fprintf (2,'identifier: %s\n', ME.identifier);
		fprintf (2,'message: %s\n\n', ME.message);

		fprintf ('%s : %s finished with ERROR.\n', mfilename, params.global.subjID.pairedT1Flair {i,1});
		fprintf ('%s :\n', mfilename);

		diary off

		params.wmh.success.pairedT1Flair {i,2} = 1;

		continue; % jump to next iteration (for i)

	end
end

pairedT1FlairProcessing_finishTime = toc (pairedT1FlairProcessing_startTime);
pairedT1FlairProcessing_finishTime = datestr(pairedT1FlairProcessing_finishTime/(24*60*60), 'DD:HH:MM:SS');

fprintf ('%s : Finished processing all subjects with both T1 and FLAIR (%s; %s elapsed).\n', mfilename, ...
		 string(datetime), pairedT1FlairProcessing_finishTime);
fprintf ('%s : %d / %d subjects with both T1 and FLAIR were successfully processed.\n', mfilename, ...
		 params.global.numbers.pairedT1Flair - sum ([params.wmh.success.pairedT1Flair{:,2}]),...
		 params.global.numbers.pairedT1Flair);
fprintf ('%s :\n', mfilename);






wmh_finishTime = toc (wmh_startTime);
wmh_finishTime = datestr(wmh_finishTime/(24*60*60), 'DD:HH:MM:SS');

fprintf ('%s : WMH pipeline finished (%s).\n', mfilename, string(datetime)); 
fprintf ('%s : %s elapsed.\n', mfilename, wmh_finishTime);
allNumSubj = params.global.numbers.pairedT1Flair + ...
			params.global.numbers.t1ButNotFlair + ...
			params.global.numbers.flairButNotT1;
allNumSuccess = allNumSubj - sum ([params.wmh.success.pairedT1Flair{:,2}]) - ...
			sum ([params.wmh.success.t1ButNotFlair{:,2}]) - ...
			sum ([params.wmh.success.flairButNotT1{:,2}]);
fprintf ('%s : %d / %d subjects were successfully processed.\n', mfilename, ...
			allNumSuccess, ...
			allNumSubj)