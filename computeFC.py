# This script computes the region-wise average of a nifti file and for 4D nifti volumes, it also computes the functional connectivity between regions. The script is especially adapted to take HCP fMRI data, but can also be modified to be used in any type of data.

# Input : atlas to use (e.g., Lausanne parcellation), and nifti volume

# Output: vector (3D nifti) or data matrix (if nifti volume is 4D).

# Usage : python computeFC.py $path-to-parcellation-nifti-files $path-to-functional-volume $subject-ID $sessionID-to-run $directory-where-to-save-outputs 
# 
# Author: Anjali Tarun


from nilearn.connectome import ConnectivityMeasure
from nilearn.input_data import NiftiLabelsMasker
import scipy.io as sio
import os
import sys
from numpy import asarray
from numpy import savetxt
from numpy import savez


# Input variables (parcellation used + functional data)
func_parc_dir=sys.argv[1]
func=sys.argv[2]
Id=sys.argv[3]
sesID=sys.argv[4]
save_dir=sys.argv[5]

for i in range(5):
    func_parc = os.path.join(func_parc_dir, 'sub-'+Id+'_atlas-L2018_res-scale'+str(i+1)+'_space-MNI_dseg.nii.gz')

    # Read the parcellation
    masker = NiftiLabelsMasker(labels_img=func_parc, standardize=True,
                            memory='nilearn_cache', verbose=5)

    # Load the functional data (directly parcellated)
    time_series = masker.fit_transform(func)

    # Establish FC measure
    correlation_measure = ConnectivityMeasure(kind='correlation')
    correlation_matrix = correlation_measure.fit_transform([time_series])[0]

    p1 = os.path.join(save_dir, 'sub-'+Id+'_'+sesID+'_atlas-L2018_res-scale'+str(i+1)+'_space-MNI_dseg.mat')
    p2 = os.path.join(save_dir, 'sub-'+Id+'_'+sesID+'_atlas-L2018_res-scale'+str(i+1)+'_space-MNI_dseg.npz')

    sio.savemat(p1,  {'FC': correlation_matrix, 'time_series': time_series})
    savez(p2, FC=correlation_matrix, time_series=time_series)