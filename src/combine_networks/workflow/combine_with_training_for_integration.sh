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
                in_nbr_reg)
                    in_nbr_reg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                flag_penalize)
                    flag_penalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
                
                # SLURM
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                slurm_ntasks)
                  slurm_ntasks="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
                
                # method
                seed)
                    seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# |      *** Combine networks: integration of evidence scores and binding data ***      | #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# 1. UNSUPPORTED: Predict scores for edges of TFs that do not have labels (binding events)
# Train on all data, use that model for prediction for these unsupported edges
if [ -d ${p_out_dir}unsupported ]
then
    echo "- train/test unsupported edges by training all data.." >> ${p_progress}
    # create necessary directories for output
    mkdir -p ${p_out_dir}unsupported/predictions/
    
    # Train using all data & Predict for unsupported edges
    cmd_train_test_unsupported=" ${p_src_code}src/combine_networks/wrapper/train_test.sh \
        --p_in_binding_train ${p_out_dir}supported/net_binding.tsv \
        --l_in_path_net_train $(create_paths ${l_in_name_net} net ${p_out_dir}supported/) \
        --l_in_path_net_test $(create_paths ${l_in_name_net} net ${p_out_dir}unsupported/) \
        --flag_penalize ${flag_penalize} \
        --l_in_name_net ${l_in_name_net} \
        --p_out_pred_train ${p_out_dir}unsupported/predictions/pred_train.tsv \
        --p_out_pred_test ${p_out_dir}unsupported/predictions/pred_test.tsv \
        --p_out_model_summary ${p_out_dir}unsupported/predictions/model_summary \
        --p_out_model ${p_out_dir}unsupported/predictions/model.RData \
        --p_src_code ${p_src_code} \
        --flag_debug ${flag_debug} \
        --p_progress ${p_progress} \
        --flag_slurm ${flag_slurm} \
        --flag_singularity ${flag_singularity} \
        --p_singularity_img ${p_singularity_img} \
        --p_singularity_bindpath ${p_singularity_bindpath}"

    if [ ${flag_debug} == "ON" ]; then printf "${cmd_train_test_unsupported}\n" >> ${p_progress}; fi
    eval ${cmd_train_test_unsupported}
fi

# 2. SUPPORTED: Predict scores for edges that have labels (binding events)
# Train on the specific number of regulators ${in_nbr_reg}, then the trained model is used 
# to predict scores for the same edges that trained it.
if [ -d ${p_out_dir}supported ]
then
    echo "- train/integrate supported edges.." >> ${p_progress}
    # create necessary directories
    mkdir -p ${p_out_dir}supported/predictions/
    # Train/Integrate for every TF
    cmd_train_integrate_supported="${p_src_code}src/combine_networks/wrapper/train_integrate.sh \
                                        --p_in_binding ${p_out_dir}supported/net_binding.tsv \
                                        --l_in_name_net ${l_in_name_net} \
                                        --l_in_path_net $(create_paths ${l_in_name_net} net ${p_out_dir}supported/) \
                                        --in_nbr_reg ${in_nbr_reg} \
                                        --seed ${seed} \
                                        --p_out_pred ${p_out_dir}supported/net_np3.tsv \
                                        --p_src_code ${p_src_code} \
                                        --flag_debug ${flag_debug} \
                                        --p_progress ${p_progress} \
                                        --flag_singularity ${flag_singularity} \
                                        --p_singularity_img ${p_singularity_img} \
                                        --p_singularity_bindpath ${p_singularity_bindpath} \
                                        --flag_slurm ${flag_slurm} \
                                        --slurm_ntasks ${slurm_ntasks}"
    # run the command
    if [ ${flag_debug} == "ON" ]; then printf "${cmd_train_integrate_supported}\n" >> ${p_progress}; fi
    eval ${cmd_train_integrate_supported}
    
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