# White matter hyperintensity (WMH) module

The WMH module in SVDdetector is based on 2 pipelines:

- UBO Detector 2, an updated version of UBO Detector, for automated WMH segmentation and quantification. The methodology paper for the original UBO Detector has been published in *Neuroimage*

	>Jiang J, Liu T, Zhu W, Koncz R, Liu H, Lee T, Sachdev PS, Wen W. UBO Detector - A cluster-based, fully automated pipeline for extracting white matter hyperintensities. Neuroimage. 2018 Jul 1;174:539-549. doi: 10.1016/j.neuroimage.2018.03.050. Epub 2018 Mar 22. PMID: 29578029.

- TOolbox for Probabilistic MApping of Lesion (TOPMAL), which automatically calculate WMH loadings on strategic white matter fibre tracts. The methodology and application paper has been published in *Neuroimage: Clinical*

	>Jiang J, Paradise M, Liu T, Armstrong NJ, Zhu W, Kochan NA, Brodaty H, Sachdev PS, Wen W. The association of regional white matter lesions with cognition in a community-based cohort of older individuals. Neuroimage Clin. 2018 Mar 29;19:14-21. doi: 10.1016/j.nicl.2018.03.035. PMID: 30034997; PMCID: PMC6051317.


## Main improvements of UBO Detector 2 over the original UBO Detector

- Fully based on MATLAB. Therefore, it can be used cross platform. The core step of segmenting FLAIR into candidate clusters in UBO Detector has been replaced by kmean or superpixels segmentation using functions provided by MATLAB. An option of using calling FSL FAST (i.e., the method used in the original UBO Detector) from MATLAB is provided.

- Handle errors more elegantly. Program does not quit if a certain imaging is of bad quality. Detailed output from pipeline is documented in a log file.

- Including an option to extract WMH in native FLAIR space. This may be benefitial when the WMH is subtle.
