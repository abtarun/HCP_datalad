## Run the preprocessing of the fMRI

## Anjali Tarun


## -------------




inDir='/home/localadmin/Scripts/subjects_IDs_good.txt'
archivePath_fmri='/stornext/CHUV1/archive/PRTNR/CHUV/RADMED/phagmann/hcp/HCP_fMRI_datalad'
iPath2='/home/localadmin/Documents/tmp_folder/HCP_DWI_datalad'
archivePath_dwi='/stornext/CHUV1/archive/PRTNR/CHUV/RADMED/phagmann/hcp/HCP_DWI_datalad'
for Id in $(cat $inDir)
do 

    echo "Processing $Id"
    n=1
    el=$(( $n / 2 ))
    num=$(($n % 2 + 1)) 
    sesID=$(printf 'ses-%02d' $num)
    task_id=${rests[${el}]}
    task_id2=${rests_name[${el}]}

    if [ -d $iPath_fMRI/$task_id2/sub-$Id ];
    then
       echo "subject dataset already installed"
    else
        cd $iPath_fMRI/$task_id2
        datalad install $username@stockage-horus.chuv.ch:$archivePath_fmri/$task_id2/sub-$Id
    fi
    

    
    if (( $n % 2 == 0))
    then
        acq='LR'
        pp='/home/localadmin/Documents/HCP_fMRI_datalad/rest1/sub-289555/ses-01/func/sub-289555_ses-01_task-rest_acq-LR_bold.json'
    else
        acq='RL'
        pp='/home/localadmin/Documents/HCP_fMRI_datalad/rest1/sub-289555/ses-02/func/sub-289555_ses-02_task-rest_acq-RL_bold.json'
    fi

    if [ -f $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/'wsub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz' ] && [ -f $iPath_fMRI/derivatives/transformations/sub-$Id/sub-$Id'_atlas-L2018_res-scale3_space-MNI_dseg.nii.gz' ];
    then  
        echo "Ready to extract FC for sub-$Id and $sesID"
        mkdir $iPath_fMRI/$task_id2/derivatives/measures/sub-$Id/$sesID
        savepath=$iPath_fMRI/$task_id2/derivatives/measures/sub-$Id/$sesID
        cd /home/localadmin/Scripts/Git/ConnectomicsLab-Scripts/
        python computeFC.py $iPath_fMRI/derivatives/transformations/sub-$Id $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/'wsub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz' $Id $sesID $savepath
        s='HCP_horus_sibling'
    else
        # Check if atlas are available
        if [ -f $iPath_fMRI/derivatives/transformations/sub-$Id/sub-$Id'_atlas-L2018_res-scale3_space-MNI_dseg.nii.gz' ]; then
            echo "Done. Atlas transformed"
        elif [ -L $iPath_fMRI/derivatives/transformations/sub-$Id/sub-$Id'_atlas-L2018_res-scale3_space-MNI_dseg.nii.gz' ]; then
            cd $iPath_fMRI/derivatives/transformations
            datalad get sub-$Id
            datalad unlock sub-$Id
        else
            if [ -f $iPath_fMRI/derivatives/transformations/sub-$Id/'acpc_dc2standard.nii.gz' ]; then
                echo "Done. Transformation nifti file"
            elif [ -L $iPath_fMRI/derivatives/transformations/sub-$Id/'acpc_dc2standard.nii.gz' ]; then
                cd $iPath_fMRI/derivatives/transformations
                datalad get sub-$Id/'acpc_dc2standard.nii.gz'
                datalad unlock sub-$Id/'acpc_dc2standard.nii.gz'
            fi

            # get the anat files from HCP_DWI_datalad
            if [ -f $iPath2/derivatives/cmp/sub-$Id/anat/sub-$Id'_atlas-L2018_res-scale1_dseg.nii.gz' ]; then
                'Done. Downloaded anat files from Horus'
            elif [ -L $iPath2/derivatives/cmp/sub-$Id/anat/sub-$Id'_atlas-L2018_res-scale1_dseg.nii.gz' ]; then
                cd $iPath2/derivatives/cmp/sub-$Id
                datalad get anat
                datalad unlock anat
            else
                rm -rf $iPath2/derivatives/cmp/sub-$Id
                cd $iPath2/derivatives/cmp
                datalad install atarun@stockage-horus.chuv.ch:$archivePath_dwi/derivatives/cmp/sub-$Id
                cd $iPath2/derivatives/cmp/sub-$Id
                datalad get anat
                datalad unlock anat
            fi

            cd $iPath_fMRI/derivatives/transformations/sub-$Id
            echo "Warping the atlas files for sub-$Id"
            
            applywarp --interp=nn  -i $iPath2/derivatives/cmp/sub-$Id/anat/sub-$Id'_atlas-L2018_res-scale1_dseg.nii.gz' -r $iPath_fMRI/derivatives/MNI152_T1_2mm_brain.nii.gz -w acpc_dc2standard.nii.gz -o sub-$Id'_atlas-L2018_res-scale1_space-MNI_dseg.nii.gz'
            applywarp --interp=nn  -i $iPath2/derivatives/cmp/sub-$Id/anat/sub-$Id'_atlas-L2018_res-scale2_dseg.nii.gz' -r $iPath_fMRI/derivatives/MNI152_T1_2mm_brain.nii.gz -w acpc_dc2standard.nii.gz -o sub-$Id'_atlas-L2018_res-scale2_space-MNI_dseg.nii.gz'
            applywarp --interp=nn  -i $iPath2/derivatives/cmp/sub-$Id/anat/sub-$Id'_atlas-L2018_res-scale3_dseg.nii.gz' -r $iPath_fMRI/derivatives/MNI152_T1_2mm_brain.nii.gz -w acpc_dc2standard.nii.gz -o sub-$Id'_atlas-L2018_res-scale3_space-MNI_dseg.nii.gz'
            applywarp --interp=nn  -i $iPath2/derivatives/cmp/sub-$Id/anat/sub-$Id'_atlas-L2018_res-scale4_dseg.nii.gz' -r $iPath_fMRI/derivatives/MNI152_T1_2mm_brain.nii.gz -w acpc_dc2standard.nii.gz -o sub-$Id'_atlas-L2018_res-scale4_space-MNI_dseg.nii.gz'
            applywarp --interp=nn  -i $iPath2/derivatives/cmp/sub-$Id/anat/sub-$Id'_atlas-L2018_res-scale5_dseg.nii.gz' -r $iPath_fMRI/derivatives/MNI152_T1_2mm_brain.nii.gz -w acpc_dc2standard.nii.gz -o sub-$Id'_atlas-L2018_res-scale5_space-MNI_dseg.nii.gz'

        fi

        # Check if the func file is already regressed out
        if [ -f $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/'wsub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz' ]; then
            echo "Done. Regressed Functional data"
            s='HCP_horus_sibling'
        elif [ -L $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/'wsub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz' ]; then   
            cd $iPath_fMRI/$task_id2/derivatives/HCP_preproc
            datalad get sub-$Id/'wsub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz'
            datalad unlock sub-$Id/'wsub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz'
            s='HCP_horus_sibling'
        else
            # get the motion parameters
            cd $iPath_fMRI/$task_id2/derivatives/HCP_preproc
            # if [ -f $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/'Movement_Regressors_'$acq'.txt' ]; then
            #     echo "Done. Motion Parameters"
            # elif [ -L $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/'Movement_Regressors_'$acq'.txt' ]; then
            #     datalad get sub-$Id/'Movement_Regressors_'$acq'.txt'
            #     datalad unlock sub-$Id/'Movement_Regressors_'$acq'.txt'
            #else
            aws s3 cp s3://hcp-openaccess/HCP_1200/$Id/MNINonLinear/Results/rfMRI_$task_id'_'$acq/'Movement_Regressors.txt' $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/Movement_Regressors_$acq.txt
            aws s3 cp s3://hcp-openaccess/HCP_1200/$Id/MNINonLinear/Results/rfMRI_$task_id'_'$acq/'rfMRI_'$task_id'_'$acq'_WM.txt' $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id
            aws s3 cp s3://hcp-openaccess/HCP_1200/$Id/MNINonLinear/Results/rfMRI_$task_id'_'$acq/'rfMRI_'$task_id'_'$acq'_CSF.txt' $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id

            #fi 

            if [ -f $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/'Movement_Regressors_'$acq'.txt' ]; then
                # get original functional data
                cd $iPath_fMRI/$task_id2
                if [ -f $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz' ]; then
                    echo "Done. Orign func data"
                    s='HCP_horus_sibling'
                elif [ -L $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz' ]; then
                    cd $iPath_fMRI/$task_id2/sub-$Id/$sesID
                    datalad get func
                    datalad unlock func
                    s='HCP_horus_sibling'
                else
                    aws s3 cp s3://hcp-openaccess/HCP_1200/$Id/MNINonLinear/Results/'rfMRI_'$task_id'_'$acq/'rfMRI_'$task_id'_'$acq'_hp2000_clean.nii.gz' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz'
                    cp $pp $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.json'
                    s='origin'
                fi
                
                if [ -f $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/'brainmask_fs_'$acq'.2.nii.gz' ]; then
                    echo "Done. brainmask"
                elif [ -L $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/'brainmask_fs_'$acq'.2.nii.gz' ]; then
                    cd $iPath_fMRI/$task_id2/derivatives/HCP_preproc
                    datalad get sub-$Id/'brainmask_fs_'$acq'.2.nii.gz'
                    datalad unlock sub-$Id/'brainmask_fs_'$acq'.2.nii.gz'
                else
                    aws s3 cp s3://hcp-openaccess/HCP_1200/$Id/MNINonLinear/Results/'rfMRI_'$task_id'_'$acq'/brainmask_fs.2.nii.gz' $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/'brainmask_fs_'$acq'.2.nii.gz'
                fi
                    

                # Perform regression
                cd /home/localadmin/Scripts/Git/ConnectomicsLab-Scripts/

                output_dir=$iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id
                cd /home/localadmin/Scripts/Git/ConnectomicsLab-Scripts/
                python Regression-fMRI.py $Id $task_id $task_id2 $sesID $acq $output_dir
            else
                echo "No motion parameter data"
            fi
        fi

        if [ -f $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/'wsub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz' ] && [ -f $iPath_fMRI/derivatives/transformations/sub-$Id/sub-$Id'_atlas-L2018_res-scale3_space-MNI_dseg.nii.gz' ];
        then
            echo "Ready to extract FC for sub-$Id and $sesID"
            mkdir $iPath_fMRI/$task_id2/derivatives/measures/sub-$Id/$sesID
            savepath=$iPath_fMRI/$task_id2/derivatives/measures/sub-$Id/$sesID
            cd /home/localadmin/Scripts/Git/ConnectomicsLab-Scripts/
            python computeFC.py $iPath_fMRI/derivatives/transformations/sub-$Id $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/'wsub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz' $Id $sesID $savepath

        fi



        if [ -f $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz' ] && [ -L $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.json']; then
            cd $iPath_fMRI/$task_id2/sub-$Id
            datalad save -m "fMRI volumes for sub-$Id" $sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz'
            datalad push --to origin $sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz'
            datalad drop $sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz'
        else
            cd $iPath_fMRI/$task_id2/sub-$Id
            datalad save -m "fMRI volumes for sub-$Id" $sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz'
            datalad push --to HCP_horus_sibling $sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz'
            datalad drop $sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz'
        fi

        if [ -f $iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id/'wsub-'$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz' ]; then
            cd $iPath_fMRI/$task_id2/derivatives/HCP_preproc
            datalad save -m "Regressed fMRI vol for sub-$Id" sub-$Id/wsub-$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz'
            datalad push --to HCP_horus_sibling sub-$Id/wsub-$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz'
            datalad drop sub-$Id/wsub-$Id'_'$sesID'_task-rest_acq-'$acq'_bold.nii.gz'
        fi
    fi
done

