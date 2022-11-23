function lv1clstrs_dat = wmh_ud2_postproc_classification_1stLvClstrs_kmeans (ud2param, dat)
% clean up dark regions
%
% in_nii is FLAIR
% we know WMH is bright
% therefore, suppress intensities lower than a percentile threshold (currently set to 80)
prct80 = prctile (nonzeros(dat), 80, 'method', 'exact');
dat (dat <= prct80) = 0;

if ud2param.exe.verbose
	fprintf ('%s : Using k-means to generate 1st-level clusters.\n', mfilename);
end

lv1clstrs_dat = imsegkmeans3 (single(dat), ud2param.classification.k4kmeans, ...
								'NormalizeInput', true);

% get rid of 1st-level clusters outside brain
if ud2param.exe.verbose
	fprintf ('%s : Excluding k-means output outside brain.\n', mfilename);
end

brn = dat;
brn(brn>0)=1;
brn(brn<=0)=0;
lv1clstrs_dat = lv1clstrs_dat .* uint8(brn);
clearvars brn;