

# Script for running the regression fMRI.py

# read tasks

IFS=$'\n' read -d '' -r -a tasks < $taskList
IFS=$'\n' read -d '' -r -a rests < $restList
IFS=$'\n' read -d '' -r -a tasks_name < $taskListnames
IFS=$'\n' read -d '' -r -a rests_name < $restListnames

for Id in $(cat $inDir)
do 

    echo "Processing $Id"
    cd $tmp_pth
    datalad get sub-$Id/anat sub-$Id/func
    datalad unlock sub-$Id/func
    datalad unlock sub-$Id/anat

    n=0
    while [ $n -ne 4 ]
    do  
        echo "Processing $sesID"
        el=$(( $n / 2 ))
        num=$(($n % 2 + 1)) 
        sesID=$(printf 'ses-%02d' $num)
        task_id=${rests[${el}]}
        task_id2=${rests_name[${el}]}

        mkdir -p $iPath_fMRI/$task_id2/sub-$Id/$sesID/func
        mkdir -p $iPath_fMRI/$task_id2/sub-$Id/$sesID/anat
        cp $tmp_pth/sub-$Id/anat/'sub-'$Id'_acq-restore125_T1w.nii.gz' $iPath_fMRI/$task_id2/sub-$Id/$sesID/anat/'sub-'$Id'_'$sesID'_acq-restore125_T1w.nii.gz'
   
        if (( $n % 2 == 0))
        then
            cp $tmp_pth/sub-$Id/func/'sub-'$Id'_task-'$task_id'_acq-LR_bold.nii.gz' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-LR_bold.nii.gz'
            cp $tmp_pth/sub-$Id/func/'sub-'$Id'_task-'$task_id'_acq-LR_bold.json' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-LR_bold.json'
        else
            cp $tmp_pth/sub-$Id/func/'sub-'$Id'_task-'$task_id'_acq-RL_bold.nii.gz' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-RL_bold.nii.gz'
            cp $tmp_pth/sub-$Id/func/'sub-'$Id'_task-'$task_id'_acq-RL_bold.json' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-rest_acq-RL_bold.json'
        fi

        n=$((n+1))

    done

    n=0
    while [ $n -ne 14 ]
    do  
        echo "Processing $sesID"
        el=$(( $n / 2 ))
        num=$(($n % 2 + 1)) 
        sesID=$(printf 'ses-%02d' $num)
        task_id=${tasks[${el}]}
        task_id2=${tasks_name[${el}]}

        mkdir -p $iPath_fMRI/$task_id2/sub-$Id/$sesID/func
        mkdir -p $iPath_fMRI/$task_id2/sub-$Id/$sesID/anat
        cp $tmp_pth/sub-$Id/anat/'sub-'$Id'_acq-restore125_T1w.nii.gz' $iPath_fMRI/$task_id2/sub-$Id/$sesID/anat/'sub-'$Id'_'$sesID'_acq-restore125_T1w.nii.gz'
   

        if (( $n % 2 == 0))
        then
            cp $tmp_pth/sub-$Id/func/'sub-'$Id'_task-'$task_id'_acq-LR_bold.nii.gz' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-'$task_id2'_acq-LR_bold.nii.gz'
            cp $tmp_pth/sub-$Id/func/'sub-'$Id'_task-'$task_id'_acq-LR_bold.json' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-'$task_id2'_acq-LR_bold.json'
        else
            cp $tmp_pth/sub-$Id/func/'sub-'$Id'_task-'$task_id'_acq-RL_bold.nii.gz' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-'$task_id2'_acq-RL_bold.nii.gz'
            cp $tmp_pth/sub-$Id/func/'sub-'$Id'_task-'$task_id'_acq-RL_bold.json' $iPath_fMRI/$task_id2/sub-$Id/$sesID/func/'sub-'$Id'_'$sesID'_task-'$task_id2'_acq-RL_bold.json'
        fi

        n=$((n+1))

    done

    # drop the data from HCP_datalad
    cd $tmp_pth
    rm -r sub-$Id/func sub-$Id/anat


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

        
        cd $iPath_fMRI/$task_id2/derivatives/HCP_preproc/
        datalad get sub-$Id
        datalad unlock sub-$Id

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
