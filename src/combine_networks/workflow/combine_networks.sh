#!/bin/bash
# ##########################################################################
# | This module split the input networks into networks with perturbed TFs| #
# | (having perturbation info), and networks TFs that were not perturbed | #
# | create two different models using each one source of information.    | #
# ##########################################################################


# ======================================================================== #
# |                        *** HELPER FUNCTIONS ***                      | #
# ======================================================================== #
function create_paths(){
    # parameters
    l_name_net=${1}  # name of network separated by comma: 'lasso,de,bart'
    prefix=${2}  # prefix of file name
    p_dir=${3}  # path of directory of files
    
    IFS=',' read -ra l_name <<< "${l_name_net}"  # put ${l_name_net} into an array ${l_name}
    l_path_net="${p_dir}${prefix}_${l_name[0]}.tsv"  # create the first path
    
    # loop over the name of networks for creating the remaining paths
    for (( i=1;i<${#l_name[@]};i++ ))
    do
        l_path_net="${l_path_net},${p_dir}${prefix}_${l_name[i]}.tsv"
    done
    
    # return list of paths
    echo "${l_path_net}"
}

function create_l_name_net_without_de(){
    # parameters
    l_name_net=${1}
    
    IFS=',' read -ra l_name <<< "${l_name_net}"  # put the string ${l_name_net} into an array ${l_name}
    
    # loop over the name of networks to create the names without de
    for (( i=0;i<${#l_name[@]};i++ ))
    do
        if [ ${l_name[i]} != "de" ]; then
            if [ -z "${l_name_net_without_de}" ]; then
                l_name_net_without_de="${l_name[i]}"
            else
                l_name_net_without_de="${l_name_net_without_de},${l_name[i]}"
            fi
        fi
    done
    
    # return list of names without de
    echo "${l_name_net_without_de}"
}
# ======================================================================== #
# |                     *** END HELPER FUNCTIONS ***                     | #
# ======================================================================== #



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
                    p_in_binding_event="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                l_in_path_net)
                   l_in_path_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
                l_in_name_net)
                   l_in_name_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
                in_model_name)
                    in_model_name="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;                
                flag_training)
                   flag_training="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
               nbr_fold)
                   nbr_fold="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
                seed)
                    seed="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                # small subset
                in_nbr_reg)
                    in_nbr_reg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                # default
                l_in_coef)
                    nargs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    if [ ${nargs} == "NONE" ]; then
                        l_in_coef=("NONE" "NONE")
                    else
                        l_in_coef=("")
                        for (( i=1;i<1`expr ${nargs}+1`;i++ ))
                        do
                            arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                            l_in_coef+=("${arg}")
                        done
                    fi
                    ;;
                p_in_model)
                    p_in_model="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                
                # Output
                p_out_dir)
                    p_out_dir="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                
                # Logistics
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_debug)
                    flag_debug="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                nbr_job)
                    nbr_job="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                
                # SLURM
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
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
                   flag_intercept="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
                                
                # penalization
                flag_penalize)
                   flag_penalize="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
                penalize_nbr_fold)
                    penalize_nbr_fold="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                    
            esac;;
        h)
            echo "usage"
            exit 2
            ;;
    esac
done


# ======================================================================== #
# |                         *** DEFINE VARIABLES ***                     | #
# ======================================================================== #
mkdir -p ${p_out_dir}
mkdir -p ${p_out_dir}tmp_combine/
mkdir -p ${p_out_dir}tmp_combine/network_construction/
p_progress=${p_out_dir}tmp_combine/progress.txt
p_reg=${p_out_dir}tmp_combine/reg.tsv
p_target=${p_out_dir}tmp_combine/target.tsv
p_net_binding=${p_out_dir}tmp_combine/net_binding.tsv


# ======================================================================== #
# |                         *** WORKFLOW STARTS ***                      | #
# ======================================================================== #

# ------------------------------------------------------------------------ #
# |                  *** Get the list of Reg & Targets ***               | #
# ------------------------------------------------------------------------ #
echo "- Get the list of regulators & target genes.." > ${p_progress}
cmd_get_lists="${p_src_code}src/combine_networks/wrapper/get_list_reg_targets_from_network.sh \
               --l_in_path_net ${l_in_path_net} \
               --p_out_reg ${p_reg} \
               --p_out_target ${p_target} \
               --flag_slurm ${flag_slurm} \
               --flag_singularity ${flag_singularity} \
               --p_singularity_img ${p_singularity_img} \
               --p_singularity_bindpath ${p_singularity_bindpath} \
               --p_src_code ${p_src_code} \
               --p_progress ${p_progress} \
               --flag_debug ${flag_debug}"
               
if [ ${flag_debug} == "ON" ]; then echo ${cmd_get_lists} >> ${p_progress}; fi
eval ${cmd_get_lists}

# ------------------------------------------------------------------------ #
# |                     *** Create Binding Network ***                   | #
# ------------------------------------------------------------------------ #
if [ ${p_in_binding_event} != "NONE" ] 
then
    echo "- create binding networks from binding events.." >> ${p_progress}
    cmd_create_binding_net="${p_src_code}src/combine_networks/wrapper/create_binding_network.sh \
                              --p_in_binding_event ${p_in_binding_event} \
                              --p_in_reg ${p_reg} \
                              --p_in_target ${p_target} \
                              --p_out_net_binding ${p_net_binding} \
                              --flag_slurm ${flag_slurm} \
                              --flag_singularity ${flag_singularity} \
                              --p_singularity_img ${p_singularity_img} \
                              --p_singularity_bindpath ${p_singularity_bindpath} \
                              --p_src_code ${p_src_code} \
                              --p_progress ${p_progress} \
                              --flag_debug ${flag_debug}"

    if [ ${flag_debug} == "ON" ]; then echo "${cmd_create_binding_net}" >> ${p_progress}; fi
    eval ${cmd_create_binding_net}
fi

# ------------------------------------------------------------------------ #
# |              *** Split Network based on Perturbation ***             | #
# ------------------------------------------------------------------------ #
echo "- exclude autoregulation and flatten networks.." >> ${p_progress}
cmd_exclude_autoregulation="${p_src_code}src/combine_networks/wrapper/exclude_autoregulation_and_flatten_network.sh \
                                --l_in_path_net ${l_in_path_net} \
                                --l_in_name_net ${l_in_name_net} \
                                --p_in_net_binding ${p_net_binding} \
                                --p_out_dir ${p_out_dir}tmp_combine/network_construction/ \
                                --flag_slurm ${flag_slurm} \
                                --flag_singularity ${flag_singularity} \
                                --p_singularity_img ${p_singularity_img} \
                                --p_singularity_bindpath ${p_singularity_bindpath} \
                                --p_src_code ${p_src_code} \
                                --p_progress ${p_progress} \
                                --flag_debug ${flag_debug}"
if [ ${flag_debug} == "ON" ]; then echo "${cmd_exclude_autoregulation}" >> ${p_progress}; fi
eval ${cmd_exclude_autoregulation}


# ------------------------------------------------------------------------ #
# |                       *** Combine networks ***                       | #
# ------------------------------------------------------------------------ #
echo "- combine networks with ${flag_training}" >> ${p_progress}
# define command depending on the combination method: train with 10-CV, small subset, or not training at all
if [ ${flag_training} == "ON-CV" ]; then
    cmd_combine_networks="${p_src_code}src/combine_networks/workflow/combine_with_training_on_cv_folds.sh \
                           --p_in_binding_event ${p_in_binding_event} \
                           --p_in_net_binding ${p_out_dir}tmp_combine/network_construction/net_binding.tsv \
                           --l_in_name_net ${l_in_name_net} \
                           --l_in_path_net $(create_paths ${l_in_name_net} net ${p_out_dir}tmp_combine/network_construction/) \
                           --in_model_name ${in_model_name} \
                           --p_out_dir ${p_out_dir}tmp_combine/network_construction/ \
                           --flag_intercept ${flag_intercept} \
                           --flag_penalize ${flag_penalize} \
                           --nbr_fold ${nbr_fold} \
                           --penalize_nbr_fold ${penalize_nbr_fold} \
                           --seed ${seed} \
                           --flag_slurm ${flag_slurm} \
                           --slurm_nbr_tasks ${slurm_nbr_tasks} \
                           --slurm_nbr_cpus ${slurm_nbr_cpus} \
                           --slurm_nbr_nodes ${slurm_nbr_nodes} \
                           --slurm_mem ${slurm_mem} \
                           --flag_singularity ${flag_singularity} \
                           --p_singularity_img ${p_singularity_img} \
                           --p_singularity_bindpath ${p_singularity_bindpath} \
                           --p_src_code ${p_src_code} \
                           --p_progress ${p_progress} \
                           --flag_debug ${flag_debug} \
                           --nbr_job ${nbr_job}"
elif [ ${flag_training} == "ON-SUB" ]
then
    cmd_combine_networks="${p_src_code}src/combine_networks/workflow/combine_with_training_on_small_subset.sh \
                          --p_in_binding_event ${p_in_binding_event} \
                          --p_in_net_binding ${p_out_dir}tmp_combine/network_construction/net_binding.tsv \
                          --l_in_name_net ${l_in_name_net} \
                          --l_in_path_net $(create_paths ${l_in_name_net} net ${p_out_dir}tmp_combine/network_construction/) \
                          --in_nbr_reg ${in_nbr_reg} \
                          --in_model_name ${in_model_name} \
                          --p_out_dir ${p_out_dir}tmp_combine/network_construction/ \
                          --flag_intercept ${flag_intercept} \
                          --flag_penalize ${flag_penalize} \
                          --penalize_nbr_fold ${penalize_nbr_fold} \
                          --seed ${seed} \
                          --flag_slurm ${flag_slurm} \
                          --slurm_nbr_tasks ${slurm_nbr_tasks} \
                          --slurm_nbr_cpus ${slurm_nbr_cpus} \
                          --slurm_mem ${slurm_mem} \
                          --flag_singularity ${flag_singularity} \
                          --p_singularity_img ${p_singularity_img} \
                          --p_singularity_bindpath ${p_singularity_bindpath} \
                          --p_src_code ${p_src_code} \
                          --p_progress ${p_progress} \
                          --flag_debug ${flag_debug} \
                          --nbr_job ${nbr_job}"

elif [ ${flag_training} == "OFF" ]
then
    cmd_combine_networks="${p_src_code}src/combine_networks/wrapper/no_training_default_coefficients.sh \
                          --l_in_name_net ${_l_in_name_net} \
                          --l_in_path_net $(create_paths ${l_in_name_net} net ${p_out_dir}tmp_combine/network_construction/) \
                          --in_model_name ${in_model_name} \
                          --p_out_dir ${p_out_dir}tmp_combine/network_construction/ \
                          --flag_slurm ${flag_slurm} \
                          --flag_singularity ${flag_singularity} \
                          --p_singularity_img ${p_singularity_img} \
                          --p_singularity_bindpath ${p_singularity_bindpath} \
                          --p_src_code ${p_src_code} \
                          --p_progress ${p_progress} \
                          --flag_debug ${flag_debug} \
                          --in_coef ${l_in_coef[i]} \
                          --p_in_model ${p_in_model}"
fi 

# run command
if [ ${flag_debug} == "ON" ]; then printf "${cmd_combine_networks} for ${l_dir[i]}\n" >> ${p_progress}; fi
eval ${cmd_combine_networks}

# copy network
cp ${p_out_dir}tmp_combine/network_construction/net_np3.tsv  ${p_out_dir}net_np3.tsv