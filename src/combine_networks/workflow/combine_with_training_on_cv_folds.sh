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
                p_in_binding_event)
                    p_in_binding_event="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
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
                nbr_fold)
                    nbr_fold="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
                slurm_nbr_nodes)
                  slurm_nbr_nodes="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                  ;;
                slurm_nbr_tasks)
                  slurm_nbr_tasks="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                  ;;
                slurm_nbr_cpus)
                  slurm_nbr_cpus="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                  ;;
                slurm_mem)
                  slurm_mem="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
                
                # method
                seed)
                    seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                
                # small subset
                nbr_reg)
                    nbr_reg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                
                # default
                coef)
                    coef="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                p_model)
                    p_model="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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

# ======================================================================== #
# |                    *** WORKFLOW OF THE FUNCTION ***                  | #
# ======================================================================== #


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# |      *** Split networks based on binding support ***      | #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    
echo "- split networks by supported/unsupported edges.." >> ${p_progress}
# define command
cmd_split_networks="${p_src_code}src/combine_networks/wrapper/split_networks_based_on_binding_support.sh \
                    --p_in_binding_event ${p_in_binding_event} \
                    --p_in_net_binding ${p_in_net_binding} \
                    --l_in_name_net ${l_in_name_net} \
                    --l_in_path_net ${l_in_path_net} \
                    --p_out_dir ${p_out_dir} \
                    --flag_singularity ${flag_singularity} \
                    --p_singularity_img ${p_singularity_img} \
                    --p_singularity_bindpath ${p_singularity_bindpath} \
                    --flag_slurm ${flag_slurm} \
                    --flag_debug ${flag_debug} \
                    --p_src_code ${p_src_code} \
                    --p_progress ${p_progress}"
# run command                    
if [ ${flag_debug} == "ON" ]; then printf "${cmd_split_networks}\n" >> ${p_progress}; fi
eval ${cmd_split_networks}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# |      *** Combine networks (Train/Test) by 10-fold CV ***      | #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# 1. UNSUPPORTED: Predict scores for edges that do not have labels (binding events)
# Train on all data, use that model for prediction for these unsupported edges
if [ -d ${p_out_dir}unsupported ]
then
    echo "- train/test unsupported edges by training all data.." >> ${p_progress}
    # create necessary directories
    mkdir -p ${p_out_dir}unsupported/predictions/
    # Prepare data for penalization: CV data, create directories, etc.
    p_dir_penalize_unsupported="NONE"
    if [ ${flag_penalize} == "ON" ]; then
        p_dir_penalize_unsupported=${p_out_dir}unsupported/tmp_penalize/
        mkdir -p ${p_dir_penalize_unsupported}
        mkdir -p ${p_dir_penalize_unsupported}data_cv/
        mkdir -p ${p_dir_penalize_unsupported}predictions/
        cmd_select_training_penalize="${p_src_code}src/combine_networks/wrapper/select_training_testing_sets_for_cv_folds.sh \
                              --p_in_net_binding ${p_out_dir}supported/net_binding.tsv \
                              --l_in_name_net ${l_in_name_net} \
                              --l_in_path_net $(create_paths ${l_in_name_net} net ${p_out_dir}supported/) \
                              --nbr_fold ${nbr_fold} \
                              --seed ${seed} \
                              --p_out_dir ${p_dir_penalize_unsupported}/data_cv/ \
                              --p_src_code ${p_src_code} \
                              --flag_debug ${flag_debug} \
                              --p_progress ${p_progress} \
                              --flag_slurm ${flag_slurm} \
                              --flag_singularity ${flag_singularity} \
                              --p_singularity_img ${p_singularity_img} \
                              --p_singularity_bindpath ${p_singularity_bindpath}"
            if [ ${flag_debug} == "ON" ]; then printf "${cmd_select_training_penalize}\n"; fi
            eval ${cmd_select_training_penalize}
    fi
    
    # Train using all data & Predict for unsupported edges
    cmd_train_test_unsupported=""
    if [ ${flag_slurm} == "ON" ]; then 
        cmd_train_test_unsupported+="srun --exclusive --nodes 1 --ntasks 1 --cpus-per-task ${slurm_nbr_cpus} --mem ${slurm_mem} "
    fi
    
    cmd_train_test_unsupported+=" ${p_src_code}src/combine_networks/wrapper/train_test.sh \
        --p_in_binding_train ${p_out_dir}supported/net_binding.tsv \
        --l_in_path_net_train $(create_paths ${l_in_name_net} net ${p_out_dir}supported/) \
        --l_in_path_net_test $(create_paths ${l_in_name_net} net ${p_out_dir}unsupported/) \
        --l_in_name_net ${l_in_name_net} \
        --in_model_name ${in_model_name} \
        --p_out_pred_train ${p_out_dir}unsupported/predictions/pred_train.tsv \
        --p_out_pred_test ${p_out_dir}unsupported/predictions/pred_test.tsv \
        --p_out_model_summary ${p_out_dir}unsupported/predictions/model_summary \
        --p_out_model ${p_out_dir}unsupported/predictions/model.RData \
        --p_out_optimal_lambda ${p_out_dir}unsupported/predictions/optimal_lambda.tsv \
        --p_src_code ${p_src_code} \
        --flag_debug ${flag_debug} \
        --nbr_job ${nbr_job} \
        --p_progress ${p_progress} \
        --flag_slurm ${flag_slurm} \
        --slurm_nbr_tasks ${slurm_nbr_tasks} \
        --flag_intercept ${flag_intercept} \
        --flag_penalize ${flag_penalize} \
        --p_dir_penalize ${p_dir_penalize_unsupported} \
        --penalize_nbr_fold ${penalize_nbr_fold} \
        --flag_singularity ${flag_singularity} \
        --p_singularity_img ${p_singularity_img} \
        --p_singularity_bindpath ${p_singularity_bindpath} &"

    if [ ${flag_debug} == "ON" ]; then printf "${cmd_train_test_unsupported}\n" >> ${p_progress}; fi
    eval ${cmd_train_test_unsupported}
fi

# 2. SUPPORTED: Predict scores for edges that do not have labels (binding events)
# Train on all data, use that model for prediction for these unsupported edges
if [ -d ${p_out_dir}supported ]
then
    echo "- train/test supported edges using 10 CVs.." >> ${p_progress}
    # create necessary directories
    mkdir -p ${p_out_dir}supported/predictions/
    # select training/testing for 10 folds of CV
    # define command
    cmd_select_training="${p_src_code}src/combine_networks/wrapper/select_training_testing_sets_for_cv_folds.sh \
    --p_in_net_binding ${p_out_dir}supported/net_binding.tsv \
    --l_in_name_net ${l_in_name_net} \
    --l_in_path_net $(create_paths ${l_in_name_net} net ${p_out_dir}supported/) \
    --nbr_fold ${nbr_fold} \
    --seed ${seed} \
    --p_out_dir ${p_out_dir}supported/data_cv/ \
    --p_src_code ${p_src_code} \
    --flag_debug ${flag_debug} \
    --p_progress ${p_progress} \
    --flag_slurm ${flag_slurm} \
    --flag_singularity ${flag_singularity} \
    --p_singularity_img ${p_singularity_img} \
    --p_singularity_bindpath ${p_singularity_bindpath}"
    # run command
    if [ ${flag_debug} == "ON" ]; then printf "${cmd_select_training}" >> ${p_progress}; fi
    eval ${cmd_select_training}
    
    # Train/Test using these 10 folds of CV
    for (( f=0; f<${nbr_fold}; f++ ))
    do
        echo "  fold ${f}.." >> ${p_progress}
        
        # Prepare data for penalization: CV data, create directories, etc.     
        p_dir_penalize_supported="NONE"
        if [ ${flag_penalize} == "ON" ]; then
            p_dir_penalize_supported=${p_out_dir}supported/tmp_penalize/
            mkdir -p ${p_dir_penalize_supported}
            # every fold will have penalization, and estimation of optimal lambda
            mkdir -p ${p_dir_penalize_supported}fold${f}/
            mkdir -p ${p_dir_penalize_supported}fold${f}/data_cv/
            mkdir -p ${p_dir_penalize_supported}fold${f}/predictions/
            # define command
            cmd_select_training_penalize="${p_src_code}src/combine_networks/wrapper/select_training_testing_sets_for_cv_folds.sh \
                              --p_in_net_binding ${p_out_dir}supported/data_cv/fold${f}_train_binding.tsv \
                              --l_in_name_net ${l_in_name_net} \
                              --l_in_path_net $(create_paths ${l_in_name_net} fold${f}_train ${p_out_dir}supported/data_cv/) \
                              --nbr_fold ${nbr_fold} \
                              --seed ${seed} \
                              --p_out_dir ${p_dir_penalize_supported}fold${f}/data_cv/ \
                              --p_src_code ${p_src_code} \
                              --flag_debug ${flag_debug} \
                              --p_progress ${p_progress} \
                              --flag_slurm ${flag_slurm} \
                              --flag_singularity ${flag_singularity} \
                              --p_singularity_img ${p_singularity_img} \
                              --p_singularity_bindpath ${p_singularity_bindpath}"
            # run command
            if [ ${flag_debug} == "ON" ]; then printf "${cmd_select_training_penalize}\n"; fi
            eval ${cmd_select_training_penalize}
        fi
        
        # Train/Test for every fold f
        cmd_train_test_supported=""
        if [ ${flag_slurm} == "ON" ]
        then 
            cmd_train_test_supported+="srun --exclusive --nodes 1 --ntasks 1 --cpus-per-task ${slurm_nbr_cpus} --mem ${slurm_mem} "
        fi 
        cmd_train_test_supported+="${p_src_code}src/combine_networks/wrapper/train_test.sh \
            --p_in_binding_train ${p_out_dir}supported/data_cv/fold${f}_train_binding.tsv \
            --l_in_name_net ${l_in_name_net} \
            --l_in_path_net_train $(create_paths ${l_in_name_net} fold${f}_train ${p_out_dir}supported/data_cv/) \
            --l_in_path_net_test $(create_paths ${l_in_name_net} fold${f}_test ${p_out_dir}supported/data_cv/) \
            --in_model_name ${in_model_name} \
            --p_out_pred_train ${p_out_dir}supported/predictions/fold${f}_pred_train.tsv \
            --p_out_pred_test ${p_out_dir}supported/predictions/fold${f}_pred_test.tsv \
            --p_out_model_summary ${p_out_dir}supported/predictions/fold${f}_model_summary.txt \
            --p_out_model ${p_out_dir}supported/predictions/fold${f}_model.RData \
            --p_out_optimal_lambda ${p_out_dir}supported/predictions/fold${f}_optimal_lambda.tsv \
            --p_src_code ${p_src_code} \
            --flag_debug ${flag_debug} \
            --nbr_job ${nbr_job} \
            --p_progress ${p_progress} \
            --flag_intercept ${flag_intercept} \
            --flag_penalize ${flag_penalize} \
            --p_dir_penalize ${p_dir_penalize_supported}fold${f}/ \
            --penalize_nbr_fold ${penalize_nbr_fold} \
            --flag_singularity ${flag_singularity} \
            --p_singularity_img ${p_singularity_img} \
            --p_singularity_bindpath ${p_singularity_bindpath} \
            --flag_slurm ${flag_slurm} \
            --slurm_nbr_tasks ${slurm_nbr_tasks} &"
        
        # parallelization control of running jobs:
        nbr_running_jobs=$(jobs -p | wc -l)
        while (( nbr_running_jobs >= slurm_nbr_nodes ))
        do
            sleep 20
            nbr_running_jobs=$(jobs -p | wc -l)
        done
        
        # run the command
        if [ ${flag_debug} == "ON" ]; then printf "${cmd_train_test_supported}\n" >> ${p_progress}; fi
        eval ${cmd_train_test_supported}
    done
    wait
    
    # concatenate folds of CV networks
    echo "- Concatenate CV networks.." >> ${p_progress}
    cmd_concat_cv_networks="${p_src_code}src/combine_networks/wrapper/concat_networks.sh \
                        --p_in_dir_data_cv ${p_out_dir}supported/data_cv/  \
                        --p_in_dir_pred ${p_out_dir}supported/predictions/ \
                        --p_out_net_np3 ${p_out_dir}supported/net_np3.tsv \
                        --flag_concat concat_cv \
                        --nbr_fold ${nbr_fold} \
                        --flag_slurm ${flag_slurm} \
                        --p_src_code ${p_src_code} \
                        --flag_debug ${flag_debug} \
                        --p_progress ${p_progress} \
                        --flag_singularity ${flag_singularity} \
                        --p_singularity_img ${p_singularity_img} \
                        --p_singularity_bindpath ${p_singularity_bindpath}"

    if [ ${flag_debug} == "ON" ]; then printf "${cmd_concat_cv_networks}" >> ${p_progress}; fi
    eval ${cmd_concat_cv_networks}
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# |     *** Concatenate Supported and Unsupported Networks ***    | #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
cmd_concat_supported_unsupported="${p_src_code}src/combine_networks/wrapper/concat_networks.sh \
                                 --p_in_net_np3_1 ${p_out_dir}supported/net_np3.tsv \
                                 --p_in_net_np3_2 ${p_out_dir}unsupported/predictions/pred_test.tsv \
                                 --p_out_net_np3 ${p_out_dir}net_np3.tsv \
                                 --flag_concat two_networks \
                                 --flag_slurm ${flag_slurm} \
                                 --p_src_code ${p_src_code} \
                                 --p_progress ${p_progress} \
                                 --flag_debug ${flag_debug} \
                                 --flag_singularity ${flag_singularity} \
                                 --p_singularity_img ${p_singularity_img} \
                                 --p_singularity_bindpath ${p_singularity_bindpath}"
                                 
if [ ${flag_debug} == "ON" ]; then printf "${cmd_concat_supported_unsupported}" >> ${p_progress}; fi
eval ${cmd_concat_supported_unsupported}