clear global params;
clear;clc
global params

svddDirectory = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\SVDdetector';
spm12directory = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12';
studyDirectory = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2_example_data';

flairDistinctIntensityBtwGmWm = true;
verbose = true;

spm_segment_channels = 'T1->FLAIR';

addpath (genpath (svddDirectory));

wmh_startTime = tic;
fprintf ('%s :\n', mfilename);
fprintf ('%s : Starting WMH pipeline (%s).\n', mfilename, string(datetime));


% set parameters
try
	global_params (svddDirectory, spm12directory, studyDirectory, verbose);
	wmh_params (spm_segment_channels);
catch ME
	ME = wmh_handleErrMsg (params, ME);
	fprintf ('%s : SVDdetector aborted during setting params.\n', mfilename);
	fprintf ('%s : Refer to above info to debug.\n', mfilename);
	error ('SVDdetector aborted during setting params.');
end


% processing T1 + FLAIR

pairedT1FlairProcessing_startTime = tic;

% for i = 1 : params.global.numbers.pairedT1Flair
for i = 1 : 1

	fprintf ('%s : Started processing %s with both T1 and FLAIR.\n', mfilename, ...
			 params.global.subjID.pairedT1Flair {i,1});

	try

		wmh_initFilesDirs (params, 'paired', i); % initialise folders and copy files

		diary (fullfile (params.global.directories.subjects, ...
						 params.global.subjID.pairedT1Flair {i,1}, ...
						 'wmh', 'scripts', 'cns2_ud.log'));

		wmh_spmbatchCoregSeg (params, 'paired', i); % coreg + seg

		fprintf ('%s : %s finished without error.\n', mfilename, params.global.subjID.pairedT1Flair {i,1});
		fprintf ('%s :\n', mfilename);

		diary off

		params.wmh.failure.pairedT1Flair {i,2} = 0;   % 0 is without error.
		params.wmh.processed.pairedT1Flair {i,2} = 1; % 1 is processed.
	
	catch ME

		ME = wmh_handleErrMsg (params, ME);
		
		fprintf ('%s : %s finished with ERROR.\n', mfilename, params.global.subjID.pairedT1Flair {i,1});
		fprintf ('%s :\n', mfilename);

		diary off

		params.wmh.failure.pairedT1Flair {i,2} = 1;   % 1 is with error.
		params.wmh.processed.pairedT1Flair {i,2} = 1; % 1 is processed.

		continue; % jump to next iteration (for i)

	end
end

pairedT1FlairProcessing_finishTime = toc (pairedT1FlairProcessing_startTime);
pairedT1FlairProcessing_finishTime = datestr(pairedT1FlairProcessing_finishTime/(24*60*60), 'DD:HH:MM:SS');

fprintf ('%s : Finished processing all subjects with both T1 and FLAIR (%s; %s elapsed).\n', mfilename, ...
		 string(datetime), pairedT1FlairProcessing_finishTime);
fprintf ('%s : There are %d subjects with both T1 and FLAIR.\n', mfilename, params.global.numbers.pairedT1Flair);
fprintf ('%s : %d / %d subjects with both T1 and FLAIR were processed with WMH pipeline.\n', mfilename, ...
			sum ([params.wmh.processed.pairedT1Flair{:,2}]), ...
			params.global.numbers.pairedT1Flair);
fprintf ('%s : %d / %d processed subjects with both T1 and FLAIR failed.\n', mfilename, ...
		 sum ([params.wmh.failure.pairedT1Flair{:,2}]),...
		 sum ([params.wmh.processed.pairedT1Flair{:,2}]));
fprintf ('%s :\n', mfilename);






wmh_finishTime = toc (wmh_startTime);
wmh_finishTime = datestr(wmh_finishTime/(24*60*60), 'DD:HH:MM:SS');

fprintf ('%s : WMH pipeline finished (%s).\n', mfilename, string(datetime)); 
fprintf ('%s : %s elapsed.\n', mfilename, wmh_finishTime);
fprintf ('%s :\n', mfilename);

allProc = sum ([params.wmh.processed.pairedT1Flair{:,2}]) + ...
			sum ([params.wmh.processed.t1ButNotFlair{:,2}]) + ...
			sum ([params.wmh.processed.flairButNotT1{:,2}]);

allSucc = allProc - sum ([params.wmh.failure.pairedT1Flair{:,2}]) - ...
			sum ([params.wmh.failure.t1ButNotFlair{:,2}]) - ...
			sum ([params.wmh.failure.flairButNotT1{:,2}]);

allSubj = params.global.numbers.pairedT1Flair + ...
			params.global.numbers.t1ButNotFlair + ...
			params.global.numbers.flairButNotT1;


fprintf ('%s : %d / %d / %d subjects were successful / processed / included.\n', mfilename, ...
			allSucc, ...
			allProc, ...
			allSubj)