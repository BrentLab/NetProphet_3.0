#!/bin/bash
# ======================================================================== #
# |                        *** HELPER FUNCTIONS ***                      | #
# ======================================================================== #
function create_paths(){
    # parameters
    l_name_net=${1}  # name of network separated by comma: 'lasso,de,bart'
    prefix=${2}  # prefix of file name
    p_dir=${3}  # path of directory of files
    
    IFS=',' read -ra l_name <<< "${l_name_net}"  # put ${l_name_net} into an array ${l_name_net}
    l_path_net="${p_dir}${prefix}_${l_name[0]}.tsv"  # create the first path
    
    # loop over the name of networks for creating the remaining paths
    for (( i=1;i<${#l_name[@]};i++ ))
    do
        l_path_net="${l_path_net},${p_dir}${prefix}_${l_name[i]}.tsv"
    done
    
    # return list of paths
    echo "${l_path_net}"
}


# ======================================================================== #
# |                         *** PARSE ARGUMENTS ***                      | #
# ======================================================================== #
while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                # Input
                p_in_net_binding)
                    p_in_net_binding="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                l_in_path_net)
                    l_in_path_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                l_in_name_net)
                    l_in_name_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                in_model_name)
                    in_model_name="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                in_nbr_reg)
                    in_nbr_reg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                seed)
                    seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                    
                # Output
                p_out_dir)
                    p_out_dir="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                
                # Logistic
                p_progress)
                    p_progress="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                flag_debug)
                    flag_debug="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                nbr_job)
                    nbr_job="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                
                # SLURM
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                    
                # Singularity
                flag_singularity)
                    flag_singularity="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                p_singularity_img)
                    p_singularity_img="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                p_singularity_bindpath)
                    p_singularity_bindpath="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                
                # regression
                flag_intercept)
                    flag_intercept="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                
                # penalization
                flag_penalize)
                    flag_penalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                penalize_nbr_fold)
                    penalize_nbr_fold="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                    
            esac;
    esac
done

echo "- select training/testing sets for small subset training.." >> ${p_progress}
cmd_select_training="${p_src_code}src/combine_networks/wrapper/select_training_testing_sets_for_small_subset.sh \
    --p_in_net_binding ${p_in_net_binding} \
    --l_in_name_net ${l_in_name_net} \
    --l_in_path_net ${l_in_path_net} \
    --seed ${seed} \
    --p_out_dir ${p_out_dir}data/ \
    --in_nbr_reg ${in_nbr_reg} \
    --flag_singularity ${flag_singularity} \
    --p_singularity_img ${p_singularity_img} \
    --p_singularity_bindpath ${p_singularity_bindpath} \
    --flag_slurm ${flag_slurm} \
    --p_src_code ${p_src_code} \
    --p_progress ${p_progress} \
    --flag_debug ${flag_debug}"
    
if [ ${flag_debug} == "ON" ]; then printf "${cmd_select_training}\n" >> ${p_progress}; fi
eval ${cmd_select_training}

if [ ${flag_penalize} == "OFF" ]; then
    p_dir_penalize="NONE"
else
    p_dir_penalize=${p_out_dir}tmp_penalize/
    mkdir -p ${p_dir_penalize}
    mkdir -p ${p_dir_penalize}data_cv/
    mkdir -p ${p_dir_penalize}predictions/
    
    echo "- select training/testing sets for CV folds for penalization.." >> ${p_progress}
    cmd_select_training_penalize="${p_src_code}src/combine_networks/wrapper/select_training_testing_sets_for_cv_folds.sh \
                              --p_in_net_binding ${p_out_dir}data/train_binding.tsv \
                              --l_in_name_net ${l_in_name_net} \
                              --l_in_path_net $(create_paths ${l_in_name_net} train ${p_out_dir}data/) \
                              --seed ${seed} \
                              --p_out_dir ${p_dir_penalize}data_cv/ \
                              --p_src_code ${p_src_code} \
                              --flag_debug ${flag_debug} \
                              --p_progress ${p_progress} \
                              --flag_slurm ${flag_slurm} \
                              --flag_singularity ${flag_singularity} \
                              --p_singularity_img ${p_singularity_img} \
                              --p_singularityP_bindpath ${p_singularity_bindpath}"
     if [ ${flag_debug} == "ON" ]; then printf "${cmd_select_training_penalize}\n" >> ${p_progress}; fi
     eval ${cmd_select_training_penalize}
fi

echo "- train/test using a small subset.." >> ${p_progress}
mkdir -p ${p_out_dir}predictions/
cmd_train_test="${p_src_code}src/combine_networks/wrapper/train_test.sh \
                --p_in_binding_train ${p_out_dir}data/train_binding.tsv \
                --l_in_name_net ${l_in_name_net} \
                --l_in_path_net_train $(create_paths ${l_in_name_net} train ${p_out_dir}data/) \
                --l_in_path_net_test $(create_paths ${l_in_name_net} test ${p_out_dir}data/) \
                --in_model_name ${in_model_name} \
                --p_out_pred_train ${p_out_dir}predictions/pred_train.tsv \
                --p_out_pred_test ${p_out_dir}net_np3.tsv \
                --p_out_model_summary ${p_out_dir}predictions/model_summary.txt \
                --p_out_model ${p_out_dir}predictions/model.RData \
                --p_out_optimal_lambda ${p_out_dir}predictions/optimal_lambda.tsv \
                --p_src_code ${p_src_code} \
                --flag_debug ${flag_debug} \
                --p_progress ${p_progress} \
                --nbr_job ${nbr_job} \
                --flag_intercept ${flag_intercept} \
                --flag_penalize ${flag_penalize} \
                --p_dir_penalize ${p_dir_penalize} \
                --penalize_nbr_fold ${penalize_nbr_fold} \
                --flag_slurm ${flag_slurm} \
                --flag_singularity ${flag_singularity} \
                --p_singularity_img ${p_singularity_img} \
                --p_singularity_bindpath ${p_singularity_bindpath}"


if [ ${flag_debug} == "ON" ]; then printf "${cmd_train_test}\n" >> ${p_progress}; fi
eval ${cmd_train_test}