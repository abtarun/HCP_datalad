import os
from nilearn import image as nimg
from nilearn import plotting as nplot
import matplotlib.pyplot as plt
import numpy as np
import nibabel as nib
import pandas as pd
import sys

#Load functional data, confounds and mask
Id=sys.argv[1]
task_id=sys.argv[2]
task_id2=sys.argv[3]
sesID=sys.argv[4]
acq=sys.argv[5]
output_dir=sys.argv[6]


func_dir='/home/localadmin/Documents/tmp_folder/HCP_fMRI_datalad/'+task_id2+'/sub-'+Id+'/'+sesID+'/func'
confounds_dir='/home/localadmin/Documents/tmp_folder/HCP_fMRI_datalad/'+task_id2+'/derivatives/HCP_preproc/sub-'+Id
func = os.path.join(func_dir, 'sub-'+Id+'_'+sesID+'_task-'+task_id2+'_acq-'+acq+'_bold.nii.gz')
confound = os.path.join(confounds_dir, 'Movement_Regressors_'+acq+'.txt')
mask = os.path.join(confounds_dir,'brainmask_fs_'+acq+'.2.nii.gz')

# Read motion, CSF, and WM confounds
confound_df = pd.read_fwf(confound, sep='s+', header=None)
confound_df.to_numpy()
confound_vars = ['X','Y','Z','RotX','RotY','RotZ','dX','dY','dZ','dRotX','dRotY','dRotZ']

# Read imaging file
raw_func_img = nimg.load_img(func)
# Remove the first few images to achive steady state
func_img = raw_func_img.slicer[:,:,:,6:]
#Drop confound dummy TRs from the dataframe to match the size of our new func_img
drop_confound_df = confound_df.loc[6:].to_numpy()
drop_confound_df[np.isnan(drop_confound_df)] = 0


# Clean!
clean_img = nimg.clean_img(func_img,confounds=drop_confound_df,detrend=True,standardize=False, low_pass=None,high_pass=None,mask_img=mask, ensure_finite=True)

# Saving to nifti file
clean_dir=os.path.join(output_dir, 'wsub-'+Id+'_'+sesID+'_task-'+task_id2+'_acq-'+acq+'_bold.nii.gz')
clean_img.to_filename(clean_dir)