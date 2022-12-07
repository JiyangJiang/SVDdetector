
in_dir = '/Users/z3402744/Documents/GitHub/example_data/fast_test';
in_basename = 'mwrflair_brn';
out_basename = 'fslfast';

fslfast_opts = ' --type=2 --class=5 --segments -p -B -b --fixed=4 --lowpass=20 --Hyper=0.1 --mixel=0.3 --verbose --iter=4 --fHard=0.02 --init=15 ';

fslfast_opts = [fslfast_opts '--out=' fullfile(in_dir, out_basename) ' '];

fslfast_cmd = ['fast ' fslfast_opts fullfile(in_dir, in_basename)];

[status, output] = call_fsl (fslfast_cmd);



% Usage:
% fast [options] file(s)

% Optional arguments (You may optionally specify one or more of):
% 	-n,--class	number of tissue-type classes; default=3
% 	-I,--iter	number of main-loop iterations during bias-field removal; default=4
% 	-l,--lowpass	bias field smoothing extent (FWHM) in mm; default=20
% 	-t,--type	type of image 1=T1, 2=T2, 3=PD; default=T1
% 	-f,--fHard	initial segmentation spatial smoothness (during bias field estimation); default=0.02
% 	-g,--segments	outputs a separate binary image for each tissue type
% 	-a <standard2input.mat> initialise using priors; you must supply a FLIRT transform
% 	-A <prior1> <prior2> <prior3>    alternative prior images
% 	--nopve	turn off PVE (partial volume estimation)
% 	-b		output estimated bias field
% 	-B		output bias-corrected image
% 	-N,--nobias	do not remove bias field
% 	-S,--channels	number of input images (channels); default 1
% 	-o,--out	output basename
% 	-P,--Prior	use priors throughout; you must also set the -a option
% 	-W,--init	number of segmentation-initialisation iterations; default=15
% 	-R,--mixel	spatial smoothness for mixeltype; default=0.3
% 	-O,--fixed	number of main-loop iterations after bias-field removal; default=4
% 	-H,--Hyper	segmentation spatial smoothness; default=0.1
% 	-v,--verbose	switch on diagnostic messages
% 	-h,--help	display this message
% 	-s,--manualseg <filename> Filename containing intensities
% 	-p		outputs individual probability maps



% other options for future
%
% -s,--manualseg <filename> Filename containing intensities
% -a <standard2input.mat> initialise using priors; you must supply a FLIRT transform
% -P,--Prior	use priors throughout; you must also set the -a option
% -A <prior1> <prior2> <prior3>    alternative prior images
% -S,--channels	number of input images (channels); default 1