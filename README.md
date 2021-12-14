# HCP_datalad

Author: Anjali Tarun
Date Created: December 9, 2021

This repository describes the HCP datalad dataset available on UNIL servers (`/archive/PRTNR/CHUV/RADMED/phagmann/hcp/`).

## Data format

A detailed description of the dataset and its subdatasets are available on [HCP_data_description.md](https://github.com/abtarun/HCP_datalad/blob/main/HCP_data_description.md).

## Subject IDs used

The subject IDs used are those that have complete imaging files (functional, anatomical, and diffusion data). The list of subjects used can be found in the following file: [subject_IDs_good.txt](https://github.com/abtarun/HCP_datalad/blob/main/subject_IDs_good.txt). Alternatively, one can opt to use only the 100 unrelated subjects available in the following file: [subjects_IDs_unrelated100.txt](https://github.com/abtarun/HCP_datalad/blob/main/subjects_IDs_unrelated100.txt)

## Preprocessing 

This repository also includes the scripts used in preprocessing the fMRI data, as well as the code used in running the conectome mapper to obtain the SC matrices.

  * Diffusion MRI
    * Diffusion MRI data were downloaded in their minimally preprocessed format. I used the connectome mapper to obtain the structural connectivity matrices using the Lausanne parcellation (5 scales). Diffusion parameters are as follows: I used single shell (b=3000) multi-tissue to estimate the response function, while fiber orientation distribution functions were computed using constrained spherical deconvolution of order 8. Tractogram generation was performed using deterministic tractography with about 2 Million output streamlines, and was seeded from the white matter. 
    * The reference codes used in the cmp runs can be found [here](https://github.com/abtarun/HCP_datalad/blob/main/diffusion).
    
  * Functional MRI
    * Functional data were downloaded in their minimally preprocessed format (gradient distortion correction, motion correction (realignment), registration to MNI standard space, and intensity normalization (see Glasser et al., 2013)). I successively performed motion and  nuissance regression (motion parameters + derivatives, CSF and WM means, see associated code provided, [`Regression-fMRI.py`](https://github.com/abtarun/HCP_datalad/blob/main/Regression-fMRI.py).


## How to access the data using datalad?

The HCP data is in datalad format, and can be downloaded and installed using datalad. The tutorial on how to access the data using datalad can be found [here](https://github.com/abtarun/HCP_datalad/blob/main/HCP_datalad_info.md).

## If not using datalad

If datalad can't be used, one can also opt to access the files using ssh. If you have access in the UNIL Vital-it and in the folder HCP folder, you can copy and paste the files using ssh. To modify the files, you have to make sure that the permissions are properly set.
