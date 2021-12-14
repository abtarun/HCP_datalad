# Information on how to use datalad to access HCP data on Stockage-Horus

This file describes the step by step procedure when using datalad to download the HCP data. The dataset is located in the following path: `/archive/PRTNR/CHUV/RADMED/phagmann/hcp/`, which can be accessed using your CHUV account.

Author: Anjali Tarun
Date Created: December 9, 2021

## Set-up datalad

* Before accessing the HCP data,  make sure that your datalad environment is configured and activated. The environment can be configured using [datalad_environment.yml](https://github.com/abtarun/HCP_datalad/tree/main/datalad-configure/datalad_environment.yml). To activate using conda:

    ```console
    conda activate bids-datalad
    ```
By now, you should be able to read in your terminal:
    ```console
    (bids-datalad) localadmin@hos----:~/
    ```
## Install datalad dataset
* To use datalad at ease, we recommend to read the datalad handbook, which contains a detailed tutorial on how to use it. See [datalad handbook](http://handbook.datalad.org/en/latest/).
* As described in [HCP_data_description.md](https://github.com/abtarun/HCP_datalad/blob/main/HCP_data_description.md), the dataset is nested, and one can therefore install each of the main folders as an independent dataset.
    * Install the processed time-series in Lausanne 2018 parcellation of resting-state : `HCP_fMRI_datalad/rest1/derivatives/measures`:
    ```console
    datalad install $username@stockage-horus.chuv.ch:/archive/PRTNR/CHUV/RADMED/phagmann/hcp/HCP_fMRI_datalad/rest1/derivatives/measures --recursive
    ```

* Once the dataset is installed, you can get the data by typing:
    ```console
        cd measures/sub-100307
        datalad get .
    ```

* In principle, the subject data should already be in your directory, to unlock it and be able to mofidy it, type:
    ```console
        cd measures
        datalad unlock .