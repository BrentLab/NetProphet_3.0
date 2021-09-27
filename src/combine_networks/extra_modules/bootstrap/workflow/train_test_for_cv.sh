#!/bin/bash
function create_paths(){
    # read argument
    l_in_name_net=${1}
    prefix=${2}
    p_in_dir=${3}
    
    IFS=',' read -ra l_in_name <<< "${l_in_name_net}"
    l_path_net="${p_in_dir}${prefix}_${l_in_name[0]}.tsv"
    for ((i=1;i<${#l_in_name[@]};i++))
    do
        l_path_net+=",${p_in_dir}${prefix}_${l_in_name[i]}.tsv"
    done
    
    echo ${l_path_net}
}

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in 
                # input
                p_in_dir)
                    p_in_dir="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                bootstrap_idx)
                    bootstrap_idx="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                in_model_name)
                    in_model_name="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                l_in_name_net)
                    l_in_name_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                nbr_cv_fold)
                    nbr_cv_fold="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                   
                # singularity
                flag_singularity)
                    flag_singularity="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_singularity_img)
                    p_singularity_img="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_singularity_bindpath)
                    p_singularity_bindpath="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                # slurm
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                    
                # logistics
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
            esac;;
    esac
done

# define general variables
p_in_dir_bootstrap=${p_in_dir}tmp_combine/network_construction/bootstrap/${bootstrap_idx}/
p_in_dir_test=${p_in_dir}tmp_combine/network_construction/
# create output directory
mkdir -p ${p_in_dir_bootstrap}unsupported/predictions/
mkdir -p ${p_in_dir_bootstrap}supported/predictions/

# unsupported
cmd_train_unsupported=""

if [ ${flag_slurm} == "ON" ]; then
    cmd_train_unsupported+="srun --exclusive -N 1 -n 1 "
fi

cmd_train_unsupported+="${p_src_code}src/combine_networks/wrapper/train_test.sh \
    --p_in_binding_train ${p_in_dir_bootstrap}unsupported/net_binding.tsv \
    --in_model_name ${in_model_name} \
    --l_in_name_net ${l_in_name_net} \
    --l_in_path_net_train $(create_paths ${l_in_name_net} net ${p_in_dir_bootstrap}unsupported/) \
    --l_in_path_net_test $(create_paths ${l_in_name_net} net ${p_in_dir_test}unsupported/) \
    --p_out_pred_train ${p_in_dir_bootstrap}unsupported/predictions/pred_train.tsv \
    --p_out_pred_test ${p_in_dir_bootstrap}unsupported/predictions/pred_test.tsv \
    --p_out_model_summary ${p_in_dir_bootstrap}unsupported/predictions/model_summary.txt \
    --p_out_model ${p_in_dir_bootstrap}unsupported/predictions/model.RData \
    --p_out_optimal_lambda NONE \
    --p_out_dir ${p_in_dir_bootstrap}unsupported/predictions/ \
    --p_src_code ${p_src_code} \
    --flag_singularity ${flag_singularity} \
    --p_singularity_img ${p_singularity_img} \
    --p_singularity_bindpath ${p_singularity_bindpath} \
    --flag_slurm ${flag_slurm} \
    --slurm_nbr_tasks 1 \
    --nbr_job 2 \
    --flag_intercept NONE \
    --flag_penalize XGBOOST-OPTIMIZE \
    --p_dir_penalize NONE \
    --penalize_nbr_fold 1 \
    --flag_debug OFF & "

eval ${cmd_train_unsupported}
    
# supported
for ((i=0;i<${nbr_cv_fold};i++))
do
     cmd_train_support=""
     if [ ${flag_slurm} == "ON" ]; then
         cmd_train_support+="srun --exclusive -N 1 -n 1 "
     fi
 cmd_train_support+="${p_src_code}src/combine_networks/wrapper/train_test.sh \
      --p_in_binding_train ${p_in_dir_bootstrap}supported/data_cv/fold${i}_train_binding.tsv \
      --in_model_name ${in_model_name} \
      --l_in_name_net ${l_in_name_net} \
      --l_in_path_net_train $(create_paths ${l_in_name_net} fold${i}_train ${p_in_dir_bootstrap}supported/data_cv/) \
      --l_in_path_net_test $(create_paths ${l_in_name_net} fold${i}_test ${p_in_dir_test}supported/data_cv/) \
      --p_out_pred_train ${p_in_dir_bootstrap}supported/predictions/fold${i}_pred_train.tsv \
      --p_out_pred_test ${p_in_dir_bootstrap}supported/predictions/fold${i}_pred_test.tsv \
      --p_out_model_summary ${p_in_dir_bootstrap}supported/predictions/fold${i}_model_summary.txt \
      --p_out_model ${p_in_dir_bootstrap}supported/predictions/fold${i}_model.RData \
      --p_out_optimal_lambda NONE \
      --p_out_dir ${p_in_dir_bootstrap}supported/predictions/ \
      --p_src_code ${p_src_code} \
      --flag_singularity ${flag_singularity} \
      --p_singularity_img ${p_singularity_img} \
      --p_singularity_bindpath ${p_singularity_bindpath} \
      --flag_slurm ${flag_slurm} \
      --slurm_nbr_tasks 1 \
      --nbr_job 2 \
      --flag_intercept NONE \
      --flag_penalize XGBOOST-OPTIMIZE \
      --p_dir_penalize NONE \
      --penalize_nbr_fold 1 \
      --flag_debug OFF & "
    
    # parallelzation
    if [ ${flag_slurm} == "ON" ]; then
        nbr_running_jobs=$(jobs -p | wc -l)
        while ((${nbr_running_jobs} >= ${SLURM_JOB_NUM_NODES}))
        do
            sleep 20
            nbr_running_jobs=$(job -p | wc -l)
        done
    fi
    eval ${cmd_train_support}
        
done
wait

# concatenate CV folds
cmd_concat_cv_networks="${p_src_code}src/combine_networks/wrapper/concat_networks.sh \
    --p_in_dir_data_cv NONE \
    --p_in_dir_pred ${p_in_dir_bootstrap}supported/predictions/ \
    --p_out_net_np3 ${p_in_dir_bootstrap}supported/net_np3.tsv \
    --flag_concat concat_cv \
    --nbr_fold ${nbr_cv_fold} \
    --flag_slurm ${flag_slurm} \
    --p_src_code ${p_src_code} \
    --flag_debug OFF \
    --p_progress OFF \
    --flag_singularity ${flag_singularity} \
    --p_singularity_img ${p_singularity_img} \
    --p_singularity_bindpath ${p_singularity_bindpath}"
    
eval ${cmd_concat_cv_networks}

# concatenate support & unsupport
cmd_concat_supported_unsupported="${p_src_code}src/combine_networks/wrapper/concat_networks.sh \
    --p_in_net_np3_1 ${p_in_dir_bootstrap}supported/net_np3.tsv \
    --p_in_net_np3_2 ${p_in_dir_bootstrap}unsupported/predictions/pred_test.tsv \
    --p_out_net_np3 ${p_in_dir_bootstrap}net_np3.tsv \
    --flag_concat two_networks \
    --flag_slurm ${flag_slurm} \
    --p_src_code ${p_src_code} \
    --p_progress OFF \
    --flag_debug OFF \
    --flag_singularity ${flag_singularity} \
    --p_singularity_img ${p_singularity_img} \
    --p_singularity_bindpath ${p_singularity_bindpath}"

eval ${cmd_concat_supported_unsupported}