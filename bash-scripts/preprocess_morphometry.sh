#!/bin/sh
# Script for parcellating processed nifti files to obtain ROI-averaged morphometric values.

# Author: Anjali Tarun

archivePath_dwi='/stornext/CHUV1/archive/PRTNR/CHUV/RADMED/phagmann/hcp/HCP_DWI_datalad'
iPath_dwi='/home/localadmin/Documents/tmp_folder/HCP_DWI_datalad'
iPath_atlas=$iPath_dwi/derivatives/cmp
archivePath_fmri='/stornext/CHUV1/archive/PRTNR/CHUV/RADMED/phagmann/hcp/HCP_fMRI_datalad'
username='atarun'

inDir='/home/localadmin/Scripts/subject_IDs_good.txt'
for Id in $(cat $inDir)
do 

    savepath=$iPath_dwi/derivatives/morphometry/sub-$Id

    if [ ! -L $savepath/sub-$Id'_area_atlas-L2018_res-scale1_dseg.mat' ] || [ ! -f $savepath/sub-$Id'_area_atlas-L2018_res-scale1_dseg.mat' ]; then

        echo "Processing sub-$Id"

        if [ ! -f $iPath_atlas/sub-$Id/anat/sub-$Id'_atlas-L2018_res-scale1_dseg.nii.gz' ]; then

            # get the Lausanne parcellation 
            cd $iPath_atlas/sub-$Id
            datalad get anat
            datalad unlock anat
        
        fi

        if [ -f $iPath_atlas/sub-$Id/anat/sub-$Id'_atlas-L2018_res-scale1_dseg.nii.gz' ]; then

            cd /home/localadmin/Scripts/Git/ConnectomicsLab-Scripts/
            fil='area'
            python computeMorphometry.py $iPath_atlas/sub-$Id/anat $savepath/sub-$Id-area-in-volume.nii.gz $Id $savepath $fil
            fil='curv'
            python computeMorphometry.py $iPath_atlas/sub-$Id/anat $savepath/sub-$Id-curv-in-volume.nii.gz $Id $savepath $fil
            fil='sulc'
            python computeMorphometry.py $iPath_atlas/sub-$Id/anat $savepath/sub-$Id-sulc-in-volume.nii.gz $Id $savepath $fil
            fil='thickness'
            python computeMorphometry.py $iPath_atlas/sub-$Id/anat $savepath/sub-$Id-thickness-in-volume.nii.gz $Id $savepath $fil
            fil='volume'
            python computeMorphometry.py $iPath_atlas/sub-$Id/anat $savepath/sub-$Id-volume-in-volume.nii.gz $Id $savepath $fil
        else
            echo "No atlas available"
        fi

    fi
    
    if [ -f $savepath/sub-$Id'_area_atlas-L2018_res-scale1_dseg.mat' ]; then
        echo "sub-$Id already done"
        cd $iPath_dwi/derivatives/morphometry
        datalad save -m "Morphometric values for " sub-$Id
        datalad push --to HCP_horus_sibling sub-$Id
    fi

    if [ -f $iPath_atlas/sub-$Id/anat/sub-$Id'_atlas-L2018_res-scale1_dseg.nii.gz' ]; then
        # drop the Lausanne parcellation 
        cd $iPath_atlas/sub-$Id
        datalad drop anat
    fi

done
