

# Script for running the regression fMRI.py for task data




for Id in $(cat $inDir)
do 

    echo "Processing $Id"


    n=0
    while [ $n -ne 4 ]
    do  
        echo "Processing $sesID"
        el=$(( $n / 2 ))
        num=$(($n % 2 + 1)) 
        sesID=$(printf 'ses-%02d' $num)
        task_id=${rests[${el}]}
        task_id2=${rests_name[${el}]}

        cd $iPath_fMRI/$task_id2/sub-$Id

        mkdir -p $iPath_fMRI/$task_id2/sub-$Id/$sesID/func
        mkdir -p $iPath_fMRI/$task_id2/sub-$Id/$sesID/anat

        aws s3 cp s3://hcp-openaccess/HCP_1200/$Id/T1w/T1w_acpc_dc_restore.nii.gz $iPath_fMRI/$task_id2/sub-$Id/$sesID/anat/'sub-'$Id'_'$sesID'_acq-restore_T1w.nii.gz'
            
        if (( $n % 2 == 0))
        then
            aws s3 cp s3://hcp-openaccess/HCP_1200/$Id/MNINonLinear/Results/'rfMRI_'$task_id'_LR/rfMRI_'$task_id'_LR_hp2000_clean.nii.gz' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-LR_bold.nii.gz'
            cp $tmp_pth/sub-$Id/func/'sub-'$Id'_task-'$task_id'_acq-LR_bold.json' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-LR_bold.json'
        else
            aws s3 cp s3://hcp-openaccess/HCP_1200/$Id/MNINonLinear/Results/'rfMRI_'$task_id'_RL/rfMRI_'$task_id'_RL_hp2000_clean.nii.gz' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-RL_bold.nii.gz'
            cp $tmp_pth/sub-$Id/func/'sub-'$Id'_task-'$task_id'_acq-RL_bold.json' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-RL_bold.json'
        fi
        n=$((n+1))
    done

    n=0
    while [ $n -ne 14 ]
    do  
        
        el=$(( $n / 2 ))
        num=$(($n % 2 + 1)) 
        sesID=$(printf 'ses-%02d' $num)
        task_id=${tasks[${el}]}
        task_id2=${tasks_name[${el}]}
        echo "Processing $sesID"
        cd $iPath_fMRI/$task_id2/sub-$Id
        
        mkdir -p $iPath_fMRI/$task_id2/sub-$Id/$sesID/func
        mkdir -p $iPath_fMRI/$task_id2/sub-$Id/$sesID/anat

        aws s3 cp s3://hcp-openaccess/HCP_1200/$Id/T1w/T1w_acpc_dc_restore.nii.gz $iPath_fMRI/$task_id2/sub-$Id/$sesID/anat/'sub-'$Id'_'$sesID'_acq-restore_T1w.nii.gz'
        aws s3 cp s3://hcp-openaccess/HCP_1200/$Id/T1w/T2w_acpc_dc_restore.nii.gz $iPath_fMRI/$task_id2/sub-$Id/$sesID/anat/'sub-'$Id'_'$sesID'_acq-restore_T1w.nii.gz'
        

        if (( $n % 2 == 0))
        then
            aws s3 cp s3://hcp-openaccess/HCP_1200/$Id/MNINonLinear/Results/tfMRI_$task_id'_'LR/tfMRI_$task_id'_'LR.nii.gz $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-'$task_id2'_acq-LR_bold.nii.gz'
            cp $tmp_pth/sub-$Id/func/'sub-'$Id'_task-'$task_id'_acq-LR_bold.json' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-'$task_id2'_acq-LR_bold.json'
            
        else
            aws s3 cp s3://hcp-openaccess/HCP_1200/$Id/MNINonLinear/Results/tfMRI_$task_id'_'RL/tfMRI_$task_id'_'RL.nii.gz $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-'$task_id2'_acq-RL_bold.nii.gz'    
            cp $tmp_pth/sub-$Id/func/'sub-'$Id'_task-'$task_id'_acq-RL_bold.json' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-'$task_id2'_acq-RL_bold.json' 
        fi

        
        n=$((n+1))

    done


    # Perform regression
    cd /home/localadmin/Scripts/Git/ConnectomicsLab-Scripts/
    n=0
    while [ $n -ne 4 ]
    do 
        el=$(( $n / 2 ))
        num=$(($n % 2 + 1)) 
        sesID=$(printf 'ses-%02d' $num)
        task_id=${rests[${el}]}
        task_id2=${rests_name[${el}]}


        if (( $n % 2 == 0))
        then
            acq='LR'
        else
            acq='RL'
        fi
        output_dir=$iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id
        cd /home/localadmin/Scripts/Git/ConnectomicsLab-Scripts/
        python Regression-fMRI.py $Id $task_id $task_id2 $sesID $acq $output_dir

        n=$((n+1))
    done


    cd /home/localadmin/Scripts/Git/ConnectomicsLab-Scripts/
    n=0
    while [ $n -ne 14 ]
    do 
        el=$(( $n / 2 ))
        num=$(($n % 2 + 1)) 
        sesID=$(printf 'ses-%02d' $num)
        task_id=${tasks[${el}]}
        task_id2=${tasks_name[${el}]}
        if (( $n % 2 == 0))
        then
            acq='LR'
        else
            acq='RL'
        fi
        output_dir=$iPath_fMRI/$task_id2/derivatives/HCP_preproc/sub-$Id
        cd /home/localadmin/Scripts/Git/ConnectomicsLab-Scripts/
        python Regression-fMRI-task.py $Id $task_id $task_id2 $sesID $acq $output_dir
        n=$((n+1))
    done

   
    n=0
    while [ $n -ne 2 ]
    do  
        task_id2=${rests_name[${n}]}
        cd $iPath_fMRI/$task_id2/sub-$Id
        datalad save -m "Reformatting BIDs of fMRI for sub-$Id" 
        datalad push --to HCP_horus_sibling
        datalad drop .

        cd $iPath_fMRI/$task_id2/derivatives/HCP_preproc/
        datalad save -m "Saving regressed out BOLD data" sub-$Id
        datalad push --to HCP_horus_sibling sub-$Id
        datalad drop sub-$Id
        n=$((n+1))
    done    


    n=0
    while [ $n -ne 7 ]
    do  
        task_id2=${tasks_name[${n}]}
        cd $iPath_fMRI/$task_id2/sub-$Id
        datalad save -m "Reformatting BIDs of fMRI for sub-$Id" 
        datalad push --to HCP_horus_sibling
        datalad drop .

        cd $iPath_fMRI/$task_id2/derivatives/HCP_preproc/
        datalad save -m "Saving regressed out BOLD data" sub-$Id
        datalad push --to HCP_horus_sibling sub-$Id
        datalad drop sub-$Id
        n=$((n+1))
    done 

done



