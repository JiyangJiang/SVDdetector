% varargin{1} = cell array of flow maps. 'creating templates' will generate
%				flow maps in addition to Template 0-6.
%
% varargin{2} = wcCellArr_allIncFailSeg, i.e., wc1, wc2 and wc3 for all subjects
%               including those failed segmentation in creating DARTEL templates.
%               'failedTissueSeg' is assigned for these subjects.

function wmh_ud2_preproc (ud2param,i,varargin)

wmh_ud2_preproc_startTime = tic;

fprintf ('%s :\n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

if ud2param.exe.verbose
	fprintf ('%s : Start preprocessing %s.\n', mfilename, ud2param.lists.subjs{i,1});
end

switch ud2param.classification.ext_space

	case 'dartel'

		if ud2param.exe.verbose
			fprintf ('%s : WMH extraction from DARTEL space.\n', mfilename);
		end

		switch ud2param.templates.options{1}
		    
		    case 'existing'

		    	if ud2param.exe.verbose
					fprintf ('%s : Using existing DARTEL templates.\n', mfilename);
					fprintf ('%s : Calling wmh_ud2_preproc_dartel for preprocessing.\n', mfilename);
				end

				wmh_ud2_preproc_dartel (ud2param,i);

			case 'creating'

				if ud2param.exe.verbose
					fprintf ('%s : Using created DARTEL templates.\n', mfilename);
				end

				if nargin==4
					flowmaps = varargin{1}; % creating templates will also generate flowmaps
											% which are passed as a cell array in the 3rd
											% argument.
					wcCellArr_allIncFailSeg = varargin{2};

					if ud2param.exe.verbose
						fprintf ('%s : Calling wmh_ud2_preproc_dartel for preprocessing.\n', mfilename);
					end

					wmh_ud2_preproc_dartel (ud2param,i,flowmaps,wcCellArr_allIncFailSeg);
				else
					ME = MException ('wmh_ud2_preproc:incorrNumOfArguments', ...
								 	 '''Creating templates'' should pass flowmaps and wcCellArr_allIncFailSeg to wmh_ud2_preproc.');
					throw (ME);
				end
		end

	case 'native'

		if ud2param.exe.verbose
			fprintf ('%s : WMH extraction from native FLAIR space.\n', mfilename);
		end

		switch ud2param.templates.options{1}

		    case 'existing'

		    	if ud2param.exe.verbose
					fprintf ('%s : Using existing DARTEL templates.\n', mfilename);
					fprintf ('%s : Calling wmh_ud2_preproc_native for preprocessing.\n', mfilename);
				end

				wmh_ud2_preproc_native ('ud2',ud2param,i);

			case 'creating'

				if ud2param.exe.verbose
					fprintf ('%s : Using created DARTEL templates.\n', mfilename);
				end
				
				if nargin==3

					flowmaps = varargin{1}; % creating templates will also generate flowmaps
											% which are passed as a cell array in the 3rd
											% argument.
					wcCellArr_allIncFailSeg = varargin{2};

					if ud2param.exe.verbose
						fprintf ('%s : Calling wmh_ud2_preproc_native for preprocessing.\n', mfilename);
					end

					wmh_ud2_preproc_native ('ud2',ud2param,i,flowmaps,wcCellArr_allIncFailSeg);

				else

					ME = MException ('CNS2:preproc:incorrNumInputCreatingTemp', ...
								 	 '''Creating templates'' should pass flowmaps and wcCellArr_allIncFailSeg to wmh_ud2_preproc.');
					
					throw (ME);

				end
		end
end

wmh_ud2_preproc_finishTime = toc (wmh_ud2_preproc_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed.\n', mfilename, string(datetime), wmh_ud2_preproc_finishTime);
fprintf ('%s :\n', mfilename);