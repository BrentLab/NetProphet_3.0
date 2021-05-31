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
                l_p_in_model)
                    nargs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    if [ ${nargs} == "NONE" ]; then
                        l_p_in_model=("NONE" "NONE")
                    else
                        l_p_in_model=()
                        for (( i=1;i<`expr ${nargs}+1`;i++ ))
                        do
                            arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                            l_p_in_model+=("${arg}")
                        done
                    fi
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


# ------------------------------------------------------------------------ #
# |              *** Split Network based on Perturbation ***             | #
# ------------------------------------------------------------------------ #
echo "- split networks based on perturbations with/without DE network.." >> ${p_progress}
cmd_split_networks_based_on_de="${p_src_code}src/combine_networks/wrapper/split_networks_based_on_perturbed_reg.sh \
                                --l_in_path_net ${l_in_path_net} \
                                --l_in_name_net ${l_in_name_net} \
                                --p_in_net_binding ${p_net_binding} \
                                --p_out_dir ${p_out_dir}tmp_combine/ \
                                --flag_slurm ${flag_slurm} \
                                --flag_singularity ${flag_singularity} \
                                --p_singularity_img ${p_singularity_img} \
                                --p_singularity_bindpath ${p_singularity_bindpath} \
                                --p_src_code ${p_src_code} \
                                --p_progress ${p_progress} \
                                --flag_debug ${flag_debug}"
if [ ${flag_debug} == "ON" ]; then echo "${cmd_split_networks_based_on_de}" >> ${p_progress}; fi
eval ${cmd_split_networks_based_on_de}


# ------------------------------------------------------------------------ #
# |                       *** Combine networks ***                       | #
# | combine networks, two sets of networks: (1) networks with DE info,   | #
# | and (2) networks without DE info                                     | #
# ------------------------------------------------------------------------ #
# set the list of inputs for with_de/without_de runs
l_l_in_name_net=(${l_in_name_net} $(create_l_name_net_without_de ${l_in_name_net}))
l_l_in_path_net=($(create_paths ${l_in_name_net} net ${p_out_dir}tmp_combine/with_de/) \
              $(create_paths ${l_l_in_name_net[1]} net ${p_out_dir}tmp_combine/without_de/))
l_p_in_net_binding=(${p_out_dir}tmp_combine/with_de/net_binding.tsv ${p_out_dir}tmp_combine/without_de/net_binding.tsv)
l_dir=(with_de without_de)

# loop over with/without DE directories, and create separate models for each data
for (( i=0;i<${#l_dir[@]};i++ ))
do
    if [ -d ${p_out_dir}tmp_combine/${l_dir[i]}/ ]; then
        echo "- combine networks for ${l_dir[i]}, with ${flag_training}" >> ${p_progress}
        # define command depending on the combination method: train with 10-CV, small subset, or not training at all
        if [ ${flag_training} == "ON-CV" ]; then
            cmd_combine_networks="${p_src_code}src/combine_networks/workflow/combine_with_training_on_cv_folds.sh \
                                   --p_in_binding_event ${p_in_binding_event} \
                                   --p_in_net_binding ${l_p_in_net_binding[i]} \
                                   --l_in_name_net ${l_l_in_name_net[i]} \
                                   --l_in_path_net ${l_l_in_path_net[i]} \
                                   --in_model_name ${in_model_name} \
                                   --p_out_dir ${p_out_dir}tmp_combine/${l_dir[i]}/ \
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
                                  --p_in_net_binding ${l_p_in_net_binding[i]} \
                                  --l_in_name_net ${l_l_in_name_net[i]} \
                                  --l_in_path_net ${l_l_in_path_net[i]} \
                                  --in_nbr_reg ${in_nbr_reg} \
                                  --in_model_name ${in_model_name} \
                                  --p_out_dir ${p_out_dir}tmp_combine/${l_dir[i]}/ \
                                  --flag_intercept ${flag_intercept} \
                                  --flag_penalize ${flag_penalize} \
                                  --penalize_nbr_fold ${penalize_nbr_fold} \
                                  --seed ${seed} \
                                  --flag_slurm ${flag_slurm} \
                                  --slurm_nbr_tasks ${slurm_nbr_tasks} \
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
                                  --l_in_name_net ${l_l_in_name_net[i]} \
                                  --l_in_path_net ${l_l_in_path_net[i]} \
                                  --in_model_name ${in_model_name} \
                                  --p_out_dir ${p_out_dir}tmp_combine/${l_dir[i]}/ \
                                  --flag_slurm ${flag_slurm} \
                                  --flag_singularity ${flag_singularity} \
                                  --p_singularity_img ${p_singularity_img} \
                                  --p_singularity_bindpath ${p_singularity_bindpath} \
                                  --p_src_code ${p_src_code} \
                                  --p_progress ${p_progress} \
                                  --flag_debug ${flag_debug} \
                                  --in_coef ${l_in_coef[i]} \
                                  --p_in_model ${l_p_in_model[i]}"
        fi 

        # run command
        if [ ${flag_debug} == "ON" ]; then printf "${cmd_combine_networks} for ${l_dir[i]}\n" >> ${p_progress}; fi
        eval ${cmd_combine_networks}
    fi
done


# ------------------------------------------------------------------------ #
# |                    *** Concatenate networks ***                      | #
# |                Concatenate networks with & without DE                | #
# ------------------------------------------------------------------------ #
if [ -d ${p_out_dir}tmp_combine/${l_dir[0]}/ ] && [ -d ${p_out_dir}tmp_combine/${l_dir[1]}/ ]; then
    # define command
    cmd_concat_networks="${p_src_code}src/combine_networks/wrapper/concat_networks.sh \
                         --p_in_net_np3_1 ${p_out_dir}tmp_combine/${l_dir[0]}/net_np3.tsv \
                         --p_in_net_np3_2 ${p_out_dir}tmp_combine/${l_dir[1]}/net_np3.tsv  \
                         --p_out_net_np3 ${p_out_dir}net_np3.tsv \
                         --flag_concat 'with_and_without_de' \
                         --flag_slurm ${flag_slurm} \
                         --flag_singularity ${flag_singularity} \
                         --p_singularity_img ${p_singularity_img} \
                         --p_singularity_bindpath ${p_singularity_bindpath} \
                         --p_src_code ${p_src_code} \
                         --p_progress ${p_progress} \
                         --flag_debug ${flag_debug}"

    # run concat networks
    if [ ${flag_debug} == "ON" ]; then echo "${cmd_concat_networks}" >> ${p_progress}; fi
    eval ${cmd_concat_networks}
    
elif [ -d ${p_out_dir}tmp_combine/${l_dir[0]}/ ]; then
    cp ${p_out_dir}tmp_combine/${l_dir[0]}/net_np3.tsv  ${p_out_dir}net_np3.tsv
    
elif [ -d ${p_out_dir}tmp_combine/${l_dir[1]}/ ]; then
    cp ${p_out_dir}tmp_combine/${l_dir[1]}/net_np3.tsv ${p_out_dir}net_np3.tsv
fi