clear global ud3param;
clear;clc
global ud3param

svddDirectory = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\SVDdetector';
spm12directory = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12';
studyDirectory = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2_example_data';

flairDistinctIntensityBtwGmWm = true;
verbose = true;


spm_segment_channels = {2, 'T1<-FLAIR'}; 	% options : {n, 'all->T1'}, <- need all other modalities already registered to T1
											%           {n, 'all->FLAIR'}, <- need all other modalities already registered to FLAIR
											%			{2, 'T1->FLAIR'},
											%			{2, 'T1<-FLAIR'},
											%           {1, 'FLAIRonly'}, or 
											%           {1, 'T1only'}
											% where n is number of modalities.

addpath (genpath (svddDirectory));

wmh_startTime = tic;
fprintf ('%s :\n', mfilename);
fprintf ('%s : Starting WMH pipeline (%s).\n', mfilename, string(datetime));


% set parameters
try
	wmh_ud3_globalParams (svddDirectory, spm12directory, studyDirectory, verbose);
	wmh_ud3_wmhParams (spm_segment_channels);
catch ME
	ME = wmh_ud3_handleErrMsg (ud3param, ME);
	fprintf ('%s : SVDdetector aborted during setting ud3param.\n', mfilename);
	fprintf ('%s : Refer to above info to debug.\n', mfilename);
	error ('SVDdetector aborted during setting ud3param.');
end


% processing T1 + FLAIR

pairedT1FlairProcessing_startTime = tic;

% for i = 1 : ud3param.global.numbers.pairedT1Flair
for i = 2 : 2

	fprintf ('%s : Started processing %s with both T1 and FLAIR.\n', mfilename, ...
			 ud3param.global.subjID.pairedT1Flair {i,1});

	try

		wmh_ud3_initFilesDirs (ud3param, 'paired', i); % initialise folders and copy files

		diary (fullfile (ud3param.global.directories.subjects, ...
						 ud3param.global.subjID.pairedT1Flair {i,1}, ...
						 'wmh', 'scripts', 'wmh_ud3.log'));

		wmh_ud3_spmbatchCoregSeg1stRound (ud3param, 'paired', i); % coreg + seg

		fprintf ('%s : %s finished without error.\n', mfilename, ud3param.global.subjID.pairedT1Flair {i,1});
		fprintf ('%s :\n', mfilename);

		diary off

		ud3param.wmh.failure.pairedT1Flair {i,2} = 0;   % 0 is without error.
		ud3param.wmh.processed.pairedT1Flair {i,2} = 1; % 1 is processed.
	
	catch ME

		ME = wmh_ud3_handleErrMsg (ud3param, ME);
		
		fprintf ('%s : %s finished with ERROR.\n', mfilename, ud3param.global.subjID.pairedT1Flair {i,1});
		fprintf ('%s :\n', mfilename);

		diary off

		ud3param.wmh.failure.pairedT1Flair {i,2} = 1;   % 1 is with error.
		ud3param.wmh.processed.pairedT1Flair {i,2} = 1; % 1 is processed.

		continue; % jump to next iteration (for i)

	end
end

pairedT1FlairProcessing_finishTime = toc (pairedT1FlairProcessing_startTime);
pairedT1FlairProcessing_finishTime = datestr(pairedT1FlairProcessing_finishTime/(24*60*60), 'DD:HH:MM:SS');

fprintf ('%s : Finished processing all subjects with both T1 and FLAIR (%s; %s elapsed).\n', mfilename, ...
		 string(datetime), pairedT1FlairProcessing_finishTime);
fprintf ('%s : There are %d subjects with both T1 and FLAIR.\n', mfilename, ud3param.global.numbers.pairedT1Flair);
fprintf ('%s : %d / %d subjects with both T1 and FLAIR were processed with WMH pipeline.\n', mfilename, ...
			sum ([ud3param.wmh.processed.pairedT1Flair{:,2}]), ...
			ud3param.global.numbers.pairedT1Flair);
fprintf ('%s : %d / %d processed subjects with both T1 and FLAIR failed.\n', mfilename, ...
		 sum ([ud3param.wmh.failure.pairedT1Flair{:,2}]),...
		 sum ([ud3param.wmh.processed.pairedT1Flair{:,2}]));
fprintf ('%s :\n', mfilename);






wmh_finishTime = toc (wmh_startTime);
wmh_finishTime = datestr(wmh_finishTime/(24*60*60), 'DD:HH:MM:SS');

fprintf ('%s : WMH pipeline finished (%s).\n', mfilename, string(datetime)); 
fprintf ('%s : %s elapsed.\n', mfilename, wmh_finishTime);
fprintf ('%s :\n', mfilename);

allProc = sum ([ud3param.wmh.processed.pairedT1Flair{:,2}]) + ...
			sum ([ud3param.wmh.processed.t1ButNotFlair{:,2}]) + ...
			sum ([ud3param.wmh.processed.flairButNotT1{:,2}]);

allSucc = allProc - sum ([ud3param.wmh.failure.pairedT1Flair{:,2}]) - ...
			sum ([ud3param.wmh.failure.t1ButNotFlair{:,2}]) - ...
			sum ([ud3param.wmh.failure.flairButNotT1{:,2}]);

allSubj = ud3param.global.numbers.pairedT1Flair + ...
			ud3param.global.numbers.t1ButNotFlair + ...
			ud3param.global.numbers.flairButNotT1;


fprintf ('%s : %d / %d / %d subjects were successful / processed / included.\n', mfilename, ...
			allSucc, ...
			allProc, ...
			allSubj)