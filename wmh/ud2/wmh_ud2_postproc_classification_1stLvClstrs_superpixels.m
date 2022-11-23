function [ud2param, lv1clstrs_dat] = wmh_ud2_postproc_classification_1stLvClstrs_superpixels (ud2param, dat)

if ud2param.exe.verbose
	fprintf ('%s : Using superpixes to generate 1st-level clusters.\n', mfilename);
end

[lv1clstrs_dat,Nlabels] = superpixels3 (dat, ud2param.classification.n4superpixel);


% exclude superpixel regions with mean intensity in the bottom 95%
if ud2param.exe.verbose
	fprintf ('%s : Excluding superpixel regions with mean intensity in the bottom 95%.\n', mfilename);
end

msk = zeros(size(lv1clstrs_dat));
idxList = label2idx (lv1clstrs_dat);
for sp = 1 : Nlabels
	msk(idxList{sp}) = mean(dat(idxList{sp}));
end
thr = prctile (msk,95,'all');
msk(msk<thr) = 0;
msk(msk>=thr) = 1;
lv1clstrs_dat = lv1clstrs_dat .* msk;

% assign serial numbers to intensity (1,2,3 ....)
if ud2param.exe.verbose
	fprintf ('%s : Assigning a unique intensity to each superpixel region.\n', mfilename);
end
uniq = unique(lv1clstrs_dat);
for i = 1:size(uniq,1)
	lv1clstrs_dat(lv1clstrs_dat==uniq(i))=i;
end
lv1clstrs_dat = lv1clstrs_dat - 1; % smallest in uniq was 0, and was assigned with 1.
								   % therefore minus 1.
ud2param.classification.n4superpixel_actual = size(uniq,1) - 1;
clearvars msk idxList sp thr uniq;