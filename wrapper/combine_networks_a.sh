#!/bin/bash
# ##########################################################################
# | This module split the input networks into networks with perturbed TFs| #
# | (having perturbation info), and networks TFs that were not perturbed | #
# | create two different models using each one source of information.    | #
# ##########################################################################

# ======================================================================== #
# |                  *** DEFINE DEFAULT PARAMETERS ***                   | #
# ======================================================================== #
p_net_lasso="NONE"
p_net_de="NONE"
p_net_bart="NONE"
p_net_pwm="NONE"
p_net_binding="NONE"
l_top_edges_1="NONE"
l_top_edges_2="NONE"
p_net_np3_with_de="NONE"
p_net_np3_without_de="NONE"

# ======================================================================== #
# |                         *** PARSE ARGUMENTS ***                      | #
# ======================================================================== #
while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                p_reg)
                    p_reg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_target)
                    p_target="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_lasso)
                    p_net_lasso="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_de)
                    p_net_de="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_bart)
                    p_net_bart="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_pwm)
                    p_net_pwm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_new)
                    p_net_new="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_binding)
                    p_net_binding="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_binding_event)
                    p_binding_event="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                model_1)
                    model_1="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                model_2)
                    model_2="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_out_tmp)
                    p_out_tmp="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_out_net)
                    p_out_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_np3)
                    p_net_np3="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_out_logs)
                    p_out_logs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                data)
                    data="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                l_top_edges_1)
                    nargs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    l_top_edges_1=${nargs}
                    if [ ${nargs} != "NONE" ]
                    then
                        for (( i=1; i<`expr ${nargs}+1`;i++ ))
                        do
                            arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                            l_top_edges_1+=("${arg}")
                        done
                    fi
                    ;;
                l_top_edges_2)
                    nargs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    l_top_edges_2=${nargs}
                    if [ ${nargs} != "NONE" ]
                    then
                        for (( i=1; i<`expr ${nargs} + 1`; i++ ))
                        do
                            arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                            l_top_edges_2+=("${arg}")
                        done
                    fi
                    ;;
                seed)
                    seed="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
               flag_analysis)
                   flag_analysis="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
               flag_penalize)
                   flag_penalize="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
               flag_training)
                   flag_training="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
               l_coef_1)
                   l_coef_1="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
               l_coef_2)
                   l_coef_2="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
               p_model_1)
                   p_model_1="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
               p_model_2)
                   p_model_2="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
               nbr_reg)
                   nbr_reg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
               flag_intercept)
                   flag_intercept="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
            esac;;
        h)
            echo "usage"
            exit 2
            ;;
    esac
done
# ======================================================================== #
# |                       *** END PARSE ARGUMENTS ***                    | #
# ======================================================================== #


# ======================================================================== #
# |                        *** COMBINE NETWORKS ***                      | #
# ======================================================================== #

# ------------------------------------------------------------------------ #
# |                     *** Load Modules for Slurm ***                   | #
# ------------------------------------------------------------------------ #
if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

# ------------------------------------------------------------------------ #
# |                      *** 10-fold-cv or 1-fold ***                    | #
# ------------------------------------------------------------------------ #
if [ ${flag_training} == "10-fold-cv" ] || [ ${flag_training} == "1-fold" ]
then

    source activate netprophet
    
    if [ ${flag_slurm} == "ON" ]
    then
        ls -l /home/dabid/.conda/envs/netprophet/bin >> ${p_out_logs}tmp.txt
    fi
    
    echo "Combine Networks LASSO, DE, BART, etc.."
    # ------------------------------------------------------------------------ #
    # |                     *** Create Binding Network ***                   | #
    # ------------------------------------------------------------------------ #
    echo " - Create binding network from binding support events.."
    p_net_binding=${p_out_tmp}net_binding.tsv
    python ${p_src_code}code/combine_networks_create_binding_network.py \
        --p_in_pos_event ${p_binding_event} \
        --p_in_reg ${p_reg} \
        --p_in_target ${p_target} \
        --p_out_net ${p_net_binding}

    # ------------------------------------------------------------------------ #
    # |             *** Split networks based on perturbation ***             | #
    # ------------------------------------------------------------------------ #    
    echo " - split networks: networks with DE and without DE.."
    python ${p_src_code}code/combine_networks_split_networks_based_on_perturbed_reg.py \
        --p_net_lasso ${p_net_lasso} \
        --p_net_de ${p_net_de} \
        --p_net_bart ${p_net_bart} \
        --p_net_pwm ${p_net_pwm} \
        --p_net_new ${p_net_new} \
        --p_net_binding ${p_net_binding} \
        --p_out_dir ${p_out_tmp}

    source deactivate netprophet
    if [ ${flag_slurm} == "ON" ]
    then
        ls -l /home/dabid/.conda/envs/netprophet/bin >> ${p_out_logs}tmp.txt
    fi

    # ------------------------------------------------------------------------ #
    # |              *** Combine networks having perturbation ***            | # 
    # | here DE network is used as a source of information in the training/  | #
    # | and testing.                                                         | #
    # ------------------------------------------------------------------------ #
    if [ -d ${p_out_tmp}with_de ]
    then
    
        if [ ${p_net_lasso} != "NONE" ]
        then
            p_net_lasso_1=${p_out_tmp}with_de/net_lasso.tsv
        else
            p_net_lasso_1="NONE"
        fi

        if [ ${p_net_de} != "NONE" ]
        then
            p_net_de_1=${p_out_tmp}with_de/net_de.tsv
        else
            p_net_de_1="NONE"
        fi

        if [ ${p_net_bart} != "NONE" ]
        then
            p_net_bart_1=${p_out_tmp}with_de/net_bart.tsv
        else
            p_net_bart_1="NONE"
        fi

        if [ ${p_net_binding} != "NONE" ]
        then
            p_net_binding_1=${p_out_tmp}with_de/net_binding.tsv
        else
            p_net_binding_1="NONE"
        fi

        if [ ${p_net_pwm} != "NONE" ]
        then
            p_net_pwm_1=${p_out_tmp}with_de/net_pwm.tsv
        else
            p_net_pwm_1="NONE"
        fi
        
        if [ ${p_net_new} != "NONE" ]
        then
            p_net_new_1=${p_out_tmp}with_de/net_new.tsv
        else
            p_net_new_1="NONE"
        fi
        
        p_net_np3_with_de=${p_out_tmp}with_de/net_np3.tsv
        
        if [ ${flag_slurm} == "ON" ]
        then
            mkdir -p ${p_out_logs}with_de/
            job_combine_net_with_de=$(sbatch \
                                    -J ${data}_combine_net_with_de \
                                    -o ${p_out_logs}with_de/combine_net_with_de_%J.out \
                                    -e ${p_out_logs}with_de/combine_net_with_de_%J.err \
                                    ${p_src_code}wrapper/combine_networks_b.sh \
                                        --p_net_lasso ${p_net_lasso_1} \
                                        --p_net_de ${p_net_de_1} \
                                        --p_net_bart ${p_net_bart_1} \
                                        --p_net_pwm ${p_net_pwm_1} \
                                        --p_net_new ${p_net_new_1} \
                                        --p_net_binding ${p_net_binding_1} \
                                        --p_binding_event ${p_binding_event} \
                                        --p_out_dir ${p_out_tmp}with_de/ \
                                        --p_out_net ${p_net_np3_with_de} \
                                        --model ${model_1} \
                                        --flag_slurm ${flag_slurm} \
                                        --l_top_edges ${l_top_edges_1[@]} \
                                        --p_src_code ${p_src_code} \
                                        --seed ${seed} \
                                        --p_reg ${p_reg} \
                                        --p_target ${p_target} \
                                        --p_out_logs ${p_out_logs}with_de/ \
                                        --flag_penalize ${flag_penalize} \
                                        --flag_training ${flag_training} \
                                        --nbr_reg ${nbr_reg} \
                                        --flag_intercept ${flag_intercept})
            job_id_combine_net_with_de=$(echo ${job_combine_net_with_de} | awk '{split($0, a, " "); print a[4]}')
            echo " - submit job ${job_id_combine_net_with_de}: combine networks with DE: LASSO, DE, BART, etc.."
            printf " ${job_id_combine_net_with_de}" >> ${p_out_tmp}scancel.txt
        else
            echo " - combine LASSO, DE, BART, etc.."
            ${p_src_code}wrapper/combine_networks_b.sh \
                --p_net_lasso ${p_net_lasso_1} \
                --p_net_de ${p_net_de_1} \
                --p_net_bart ${p_net_bart_1} \
                --p_net_pwm ${p_net_pwm_1} \
                --p_net_binding ${p_net_binding_1} \
                --p_binding_event ${p_binding_event} \
                --p_out_dir ${p_out_tmp}with_de/ \
                --p_out_net ${p_net_np3_with_de} \
                --model ${model_1} \
                --flag_slurm ${flag_slurm} \
                --l_top_edges ${l_top_edges_1[@]} \
                --p_src_code ${p_src_code} \
                --seed ${seed} \
                --p_reg ${p_reg} \
                --p_target ${p_target} \
                --flag_penalize ${flag_penalize}
        fi
    fi


    # ------------------------------------------------------------------------ #
    # |            *** Combine networks not having perturbation ***          | # 
    # | here DE network is not availble, all other source of information are | #
    # | used.                                                                | #
    # ------------------------------------------------------------------------ #
    if [ -d ${p_out_tmp}without_de ]
    then

        if [ ${p_net_lasso} != "NONE" ]
        then
            p_net_lasso_2=${p_out_tmp}without_de/net_lasso.tsv
        else
            p_net_lasso_2="NONE"
        fi

        if [ ${p_net_bart} != "NONE" ]
        then
            p_net_bart_2=${p_out_tmp}without_de/net_bart.tsv
        else
            p_net_bart_2="NONE"
        fi

        if [ ${p_net_binding} != "NONE" ]
        then
            p_net_binding_2=${p_out_tmp}without_de/net_binding.tsv
        else
            p_net_binding_2="NONE"
        fi

        if [ ${p_net_pwm} != "NONE" ]
        then
            p_net_pwm_2=${p_out_tmp}without_de/net_pwm.tsv
        else
            p_net_pwm_2="NONE"
        fi
        
        if [ ${p_net_new} != "NONE" ]
        then
            p_net_new_2=${p_out_tmp}without_de/net_new.tsv
        else
            p_net_new_2="NONE"
        fi
        
        p_net_np3_without_de=${p_out_tmp}without_de/net_np3.tsv
    
        if [ ${flag_slurm} == "ON" ]
        then
            mkdir -p ${p_out_logs}without_de/
            job_combine_net_without_de=$(sbatch \
                                        -J ${data}_combine_net_without_de \
                                        -o ${p_out_logs}without_de/combine_net_without_de_%J.out \
                                        -e ${p_out_logs}without_de/combine_net_without_de_%J.err \
                                        ${p_src_code}wrapper/combine_networks_b.sh \
                                            --p_net_lasso ${p_net_lasso_2} \
                                            --p_net_bart ${p_net_bart_2} \
                                            --p_net_pwm ${p_net_pwm_2} \
                                            --p_net_new ${p_net_new_2} \
                                            --p_net_binding ${p_net_binding_2} \
                                            --p_binding_event ${p_binding_event} \
                                            --p_out_dir ${p_out_tmp}without_de/ \
                                            --p_out_net ${p_net_np3_without_de} \
                                            --model ${model_2} \
                                            --flag_slurm ${flag_slurm} \
                                            --l_top_edges ${l_top_edges_2[@]} \
                                            --p_src_code ${p_src_code} \
                                            --seed ${seed} \
                                            --p_reg ${p_reg} \
                                            --p_target ${p_target} \
                                            --p_out_logs ${p_out_logs}without_de/ \
                                            --flag_penalize ${flag_penalize} \
                                            --flag_training ${flag_training} \
                                            --nbr_reg ${nbr_reg} \
                                            --flag_intercept ${flag_intercept})
            job_id_combine_net_without_de=$(echo ${job_combine_net_without_de} | awk '{split($0, a, " "); print a[4]}')
            echo " - submit job ${job_id_combine_net_without_de}: combine networks without DE: LASSO, BART, etc.."
            printf " ${job_id_combine_net_without_de}" >> ${p_out_tmp}scancel.txt
        else
            echo " - combine LASSO, DE, BART, etc."
            ${p_src_code}wrapper/combine_networks_b.sh \
                --p_net_lasso ${p_net_lasso_2} \
                --p_net_bart ${p_net_bart_2} \
                --p_net_pwm ${p_net_pwm_2} \
                --p_net_binding ${p_net_binding_2} \
                --p_binding_event ${p_binding_event} \
                --p_out_dir ${p_out_tmp}without_de/ \
                --p_out_net ${p_net_np3_without_de} \
                --model ${model_2} \
                --flag_slurm ${flag_slurm} \
                --l_top_edges ${l_top_edges_2[@]} \
                --p_src_code ${p_src_code} \
                --seed ${seed} \
                --p_reg ${p_reg} \
                --p_target ${p_target} \
                --flag_penalize ${flag_penalize}
        fi
    fi

    # ------------------------------------------------------------------------ #
    # |         *** Concatenate networks with/without perturbation ***       | #
    # ------------------------------------------------------------------------ #
    if [ ${flag_slurm} == "ON" ]
    then
        job_concatenate_net=$(sbatch \
                          -J ${data}_concat_net_with_without_de \
                          -o ${p_out_logs}concat_net_with_without_de_%J.out \
                          -e ${p_out_logs}concat_net_with_without_de_%J.err \
                          ${p_src_code}wrapper/combine_networks_concatenate_networks.sh \
                              --p_net_np3_with_de ${p_net_np3_with_de} \
                              --p_net_np3_without_de ${p_net_np3_without_de} \
                              --p_net_np3 ${p_net_np3} \
                              --l_top_edges_1 ${l_top_edges_1[@]} \
                              --l_top_edges_2 ${l_top_edges_2[@]} \
                              --p_src_code ${p_src_code} \
                              --p_out_tmp ${p_out_tmp} \
                              --p_out_net ${p_out_net} \
                              --flag_slurm ${flag_slurm} \
                              --flag_concat "concat_with_without_de")
        job_id_concatenate_net=$(echo ${job_concatenate_net} | awk '{split($0, a, " "); print a[4]}')
        echo " - submit job ${job_id_concatenate_net}: concatenate networks with and without DE.." 
        echo ${job_id_concatenate_net} > ${p_out_tmp}job_id_concat_with_without_de.txt
            printf " ${job_id_concatenate_net}" >> ${p_out_tmp}scancel.txt
    else
        ${p_src_code}wrapper/combine_networks_concatenate_networks.sh \
                                  --p_net_np3_with_de ${p_net_np3_with_de} \
                                  --p_net_np3_without_de ${p_net_np3_without_de} \
                                  --p_net_np3 ${p_net_np3} \
                                  --l_top_edges_1 ${l_top_edges_1[@]} \
                                  --l_top_edges_2 ${l_top_edges_2[@]} \
                                  --p_src_code ${p_src_code} \
                                  --p_out_tmp ${p_out_tmp} \
                                  --p_out_net ${p_out_net} \
                                  --flag_slurm ${flag_slurm}
    fi

    # ======================================================================== #
    # |                      *** END COMBINE NETWORKS ***                    | #
    # ======================================================================== #
# -------------------------------------------------------------------------- #
# |                      *** Use Default coefficient ***                   | #
# -------------------------------------------------------------------------- #
else
    ${p_src_code}wrapper/combine_networks_default_coefficients.sh \
        --p_net_lasso ${p_net_lasso} \
        --p_net_de ${p_net_de} \
        --p_net_bart ${p_net_bart} \
        --p_net_pwm ${p_net_pwm} \
        --model_1 ${model_1} \
        --model_2 ${model_2} \
        --p_out_tmp ${p_out_tmp} \
        --p_net_np3 ${p_net_np3} \
        --p_src_code ${p_src_code} \
        --flag_slurm ${flag_slurm} \
        --l_coef_1 ${l_coef_1} \
        --l_coef_2 ${l_coef_2} \
        --p_model_1 ${p_model_1} \
        --p_model_2 ${p_model_2}
        
fi