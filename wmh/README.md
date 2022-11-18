# UBO Detector 2
WMH module in SVDdetector is based on UBO Detector 2, an updated version of UBO Detector published in *Neuroimage*:

>Jiang J, Liu T, Zhu W, Koncz R, Liu H, Lee T, Sachdev PS, Wen W. UBO Detector - A cluster-based, fully automated pipeline for extracting white matter hyperintensities. Neuroimage. 2018 Jul 1;174:539-549. doi: 10.1016/j.neuroimage.2018.03.050. Epub 2018 Mar 22. PMID: 29578029.


## Main improvements over the original UBO Detector

- Fully based on MATLAB. Therefore, it can be used cross platform. The core step of segmenting FLAIR into candidate clusters in UBO Detector has been replaced by kmean or superpixels segmentation using functions provided by MATLAB. An option of using calling FSL FAST (i.e., the method used in the original UBO Detector) from MATLAB is provided.

- Handle errors more elegantly. Program does not quit if a certain imaging is of bad quality. Detailed output from pipeline is documented in a log file.

- Including an option to extract WMH in native FLAIR space. This may be benefitial when the WMH is subtle.
