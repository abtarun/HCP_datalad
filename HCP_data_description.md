# Information regarding the HCP datalad dataset on Stockage-Horus

This file describes the HCP datalad dataset in detail. The dataset is located in the following path: `/archive/PRTNR/CHUV/RADMED/phagmann/hcp/`, which can be accessed using your CHUV account.

Author: Anjali Tarun
Date Created: December 9, 2021

## Data format

* The dataset follows the BIDs format. The functional and diffusion data are separated into two datasets : `HCP_fMRI_datalad` and `HCP_DWI_datalad`.

### Diffusion data
* Under the `HCP_DWI_datalad`, you will find individual subjects which are standalone and are subdatasets of the superdataset (see nested datasets in the datalad handbook). The reason why I set-up datalad to be nested is because the HCP data is too big. In nested datasets, any lower-level Datalad dataset (subdataset) has a stand-alone history, and as such the top-level superdataset only stores which version of the subdataset is currently used.

* Under the individual subject subdatasets, we have
    ```console
    HCP_DWI_datalad > sub-100307 > anat, dwi
    ```

* Under the main superdataset, we have the `derivatives` folder, which contains all the processed outputs, in particular those from the connectome mapper. We have `freesurfer`, `cmp`, `morphometry`, `derivatives`

    * `freesurfer` : contains all freesurfer outputs downloaded directly from the HCP database

    * `cmp` : contains all outputs of the connectome mapper, such as the final SC matrices of different Lausanne parcellation, as well as the tractograms
        
        ```console
        HCP_DWI_datalad > derivatives > cmp > sub-$Id > anat, dwi
        ```

        * `anat` : contains all anatomical outputs (e.g., registration outputs, parcellation, parcellation labels..)
        ```console
        HCP_DWI_datalad > derivatives > cmp > sub-$Id > anat >
        ```

        * `dwi` : contains all diffusion outputs (e.g., tractograms, SC matrices, anisotropy measures)
        ```console
        HCP_DWI_datalad > derivatives > cmp > sub-$Id > dwi > sub-100307_atlas-L2018_res-scale1_conndata-network_connectivity.gpickle, sub-100307_model-CSD_desc-DET_tractogram.trk
        ```

    * `morphometry` : contains all morphometric data, area, curv, sulc, thickness, volume

        * It includes the volumetric nifti files of the morphometry data
        ```console
        HCP_DWI_datalad > derivatives > morphometry > sub-$Id > sub-100307-area-in-volume.nii.gz
        ```

        * The morphometry data in Lausanne parcellated format (.mat, .npz)
        ```console
        HCP_DWI_datalad > derivatives > morphometry > sub-$Id > sub-$Id_curv_atlas-L2018_res-scale1_dseg.mat
        ```
        The code to produce the .mat/.npz files can be found on  [computeMorphometry.py](https://github.com/abtarun/HCP_datalad/blob/main/computeMorphometry.py).

## Functional data
* Under the `HCP_fMRI_datalad`, you will find two runs of resting-state : `rest1`, `rest2`, and 7 different tasks: `emotion`, `gambling`, `language`, `motor`, `social`, `relational`, and `working memory`. These are subdatasets of the superdataset `HCP_fMRI_datalad`, and thus can be downloaded and installed alone. Under these sub-datasets are the different subjects (e.g., `sub-100307`).

* Under the individual subject subdatasets, we have
    ```console
    HCP_fMRI_datalad > rest1 > sub-100307 > ses-01, ses-02 > anat, func
    ```

* Under the superdataset `HCP_fMRI_datalad`, we have the `derivatives` folder, where we save the transformations used in transforming the functional data going from MNI space to individual subject-space, and vice versa.

    ```console
    HCP_fMRI_datalad > derivatives > transformations > sub-$Id > acpc_dc2standard.nii.gz, standard2acpc_dc.nii.gz, NonlinearRegJacobians.nii.gz
    ```

    * Also under this `transformations` folder, we have saved the computed Lausanne parcellation at different scales in the MNI space. We used the transformations saved above to go from the native space (outputs of the parcellation using connectome mapper, see associated code provided) to the MNI space. For example:

    ```console
    HCP_fMRI_datalad > derivatives > transformations > sub-$Id > sub-$Id_atlas_L2018_res-scale3_space-MNI_dseg.nii.gz
    ```

* Under each of the task and rest subdatasets, are the corresponding `derivatives`, as a result of the preprocessing applied to the original data. Under the `HCP_preproc`, we save all the other useful files downloaded from the HCP database, such as motion files, and CSF and WM means used as nuissance regressors.

    ```console
    HCP_fMRI_datalad > rest1 > derivatives > HCP_preproc > sub-$d > Movement_Regressors_LR.txt, Movement_Regressors_RL.txt, Movement_Regressors_dt_LR.txt, Movement_Regressors_RL.txt, brainmask_fs_LR.2.nii.gz, rfMRI_REST1_LR_CSF.txt, rfMRI_REST1_LR_WM.txt
    ```
    * Note that each subjects in the `derivatives` folders are not nested.

    * `HCP_preproc`: the final preprocessed fMRI volumes that underwent standard preprocessing steps. Since the data downloaded from the HCP is already the minimally preprocessed version (gradient distortion correction, motion correction (realignment), registration to MNI standard space, and intensity normalization (Glasser et al., 2013)). We successively performed motion and  nuissance regression (motion parameters + derivatives, CSF and WM means, see associated code provided, [`Regression-fMRI.py`](https://github.com/abtarun/HCP_datalad/blob/main/Regression-fMRI.py).

    * The final preprocessed fMRI volumes are in the following path:
    ```console
    HCP_fMRI_datalad > rest1 > derivatives > HCP_preproc > wsub-$Id_ses-01_task-rest_acq-LR_bold.nii.gz, wsub-$Id_ses-02_task-rest_acq-LR_bold.nii.gz
    ```

    * `measures`: this contains the time-series and functional connectivity values of each subject, parcellated according the Lausanne 2018 atlas of 5 different scales.
    Under this folder, you will find the final .mat/.npz files that can be readily loaded when you perform the analyses. The code for averaging the signals according to the chosen atlas parcellation is on [computeFC.py](https://github.com/abtarun/HCP_datalad/blob/main/computeFC.py).
    
        ```console
        HCP_fMRI_datalad > rest1 > derivatives > measures > ses-01 > sub-$Id_ses-01_atlas-L2018_res-scale1_space-MNI_dseg.mat, sub-$Id_ses-01_atlas-L2018_res-scale1_space-MNI_dseg.npz
        ```



