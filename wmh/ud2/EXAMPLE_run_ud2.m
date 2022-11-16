clear global ud2param;
clear;clc
global ud2param

global Defaults
Defaults = spm_get_defaults;

study_dir = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\CNS2_example_data\ud2'; % Dell XPS 13
svdd_dir = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\SVDdetector'; % Dell XPS 13
spm_dir = 'C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\spm12'; % Dell XPS 13

n_cpu_cores = 2;
save_dskspc = false;
save_more_dskspc = false;
verbose = true;

% temp_opt = {'existing'; '70to80'};
temp_opt = {'creating'};

% lv1clstMethod = 'kmeans';
lv1clstMethod = 'superpixel';
k4kmeans = 6;
k4knn    = 5;
n4superpixel = 5000;
probthr = 0.7;
extSpace = 'dartel';

pvmag = 12;

sizthr_mm3 = [10.125 30.375 50.625]; % in mm^3

% run ud2
wmh_ud2 (study_dir, svdd_dir, spm_dir, ...
			n_cpu_cores, save_dskspc, save_more_dskspc, verbose, temp_opt, ...
				lv1clstMethod, k4kmeans, k4knn, n4superpixel, probthr, extSpace, pvmag, sizthr_mm3);