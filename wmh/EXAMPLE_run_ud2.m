clear;clc

study_dir = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2_example_data\ud2'; % Dell XPS 13
svdd_dir = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\SVDdetector'; % Dell XPS 13
spm_dir = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12'; % Dell XPS 13

% study_dir = '/Users/z3402744/Documents/GitHub/example_data'; % Macbook Pro 13
% svdd_dir = '/Users/z3402744/Documents/GitHub/SVDdetector';
% spm_dir = '/Applications/spm12'

n_workers = 2;
save_dskspc = false;
save_more_dskspc = false;
verbose = true;

temp_opt = {'existing'; '65to75'}; % options = {'existing'; '65to75'}, {'exsiting'; '70to80'}, or {'creating'}

lv1clstMethod = 'superpixels'; % options = 'kmeans', 'superpixels', or 'fslfast' (in development)
k4kmeans = 6;
k4knn    = 5;
n4superpixel = 5000;
probthr = 0.7;
extSpace = 'dartel'; % options = 'dartel' or 'native'

pvmag = 12; % distance threshold from lateral ventricles to separate PVWMH and DWMH. 12 works well in most cases.

sizthr_mm3 = [10.125 30.375 50.625]; % size thresholds in mm^3 to separate punctuate, focal, medium, confluent WMH clusters.
									 % [10.125 30.375 50.625] corresponds to 3, 9 and 15 voxels in DARTEL space.

% run ud2
wmh_ud2 (study_dir, svdd_dir, spm_dir, ...
			n_workers, save_dskspc, save_more_dskspc, verbose, temp_opt, ...
				lv1clstMethod, k4kmeans, k4knn, n4superpixel, probthr, extSpace, pvmag, sizthr_mm3);