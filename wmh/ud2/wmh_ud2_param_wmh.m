% varargin{1} = sizthr - cut-off for punctuate, focal, medium, confluent
function ud2param = wmh_ud2_param_wmh (ud2param, ...
							lv1clstMethod, ...
						    k4kmeans, ...
						    n4superpixel, ...
						    k4knn, ...
						    probthr, ...
						    extSpace, ...
						    pvmag, ...
						    sizthr);

wmh_ud2_ud2param_startTime = tic;
fprintf ('%s : \n', mfilename);
fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

% classification
% +++++++++++++++++++++++++++++++++++++++++++++
ud2param.classification.lv1clstr_method = lv1clstMethod;
ud2param.classification.k4kmeans        = k4kmeans;
ud2param.classification.n4superpixel    = n4superpixel;
ud2param.classification.k4knn           = k4knn;
ud2param.classification.probthr         = probthr;
ud2param.classification.ext_space       = extSpace;

if ud2param.exe.verbose
	fprintf ('%s : ++++++++++++++++++++++ Parameters for classification ++++++++++++++++++++++\n', mfilename);
	fprintf ('%s : Level 1 cluterisation method (ud2param.ud.classification.lv1clstr_method) is set to ''%s''.\n', mfilename, lv1clstMethod);
	fprintf ('%s : Number of clusters (k) for k-means clustering (ud2param.ud.classification.k4kmeans) is set to %d.\n', mfilename, k4kmeans);
	fprintf ('%s : Number of superpixels (N) for superpixel oversegmentation (ud2param.ud.classification.n4superpixel) is set to %d.\n', mfilename, n4superpixel);
	fprintf ('%s : Number of neighbours (k) for k-NN (ud2param.ud.classification.k4knn) is set to %d.\n', mfilename, k4knn);
	fprintf ('%s : Probability threshold (ud2param.ud.classification.probthr) is set to %.2f.\n', mfilename, probthr);
	fprintf ('%s : WMH extraction will be done in ''%s'' space (ud2param.ud.classification.ext_space).\n', mfilename, extSpace);
	fprintf ('%s : +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n', mfilename);
end

% if strcmp (ud2param.classification.lv1clstr_method, 'superpixels')
% 	warning ('%s : +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
% 	warning ('%s : WMH will be extracted with ''superpixels'' method to construct 1st level clusters. This may use a large amount of memory. Consider using kmeans.');
% end

% if strcmp (extSpace, 'native')
% 	warning ('%s : Extracting WMH in ''native'' space may take a few hours. Consider extraction in ''dartel'' space.\n', mfilename);
% 	warning ('%s : +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
% end

% quantification
% ++++++++++++++++++++++++++++++++++++++++++
ud2param.quantification.pvmag  = pvmag;  % distance from lateral ventricle - used to define PVWMH and DWMH.
ud2param.quantification.sizthr = sizthr; % cut-off in mm^3 between punctuate, focal, medium, and confluent

if ud2param.exe.verbose
	fprintf ('%s : ++++++++++++++++++++++++++++++++++++ Parameters for quantification ++++++++++++++++++++++++++++++++++\n', mfilename);
	fprintf ('%s : Periventricular magnitude (i.e., distance from lateral ventricles to separate PVWMH and DWMH) is set to %.4f mm.\n', mfilename, pvmag);
	fprintf ('%s : Cut-offs in mm3 to separate punctuate, focal, medium, and confluent WMH are set to %.4f, %.4f, and %.4f mm3.\n', mfilename, sizthr(1), sizthr(2), sizthr(3));
	fprintf ('%s : +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n', mfilename);
end

wmh_ud2_ud2param_finishTime = toc (wmh_ud2_ud2param_startTime);
fprintf ('%s : Finished (%s; %.4f seconds elapsed).\n', mfilename, string(datetime), wmh_ud2_ud2param_finishTime);
fprintf ('%s : \n', mfilename);
