#!/bin/bash
# ##########################################################################
# | This module divides the intented training networks into networks     | #
# | of TFs having evidence for binding  experiments, and networks of TFs | #
# | that do no have any evidence for binding experiments. The first set  | #
# | of networks are trained into 10-fold of CV, and the second set of    | #
# | networks are trained with single-fold, all thedata of the first set  | #
# | is for training networks                                             | #
# ##########################################################################


# ======================================================================== #
# |                  *** DEFINE DEFAULT PARAMETERS ***                   | #
# ======================================================================== #
p_net_np3_support="NONE"
p_net_np3_unsupport="NONE"

# ======================================================================== #
# |                         *** PARSE ARGUMENTS ***                      | #
# ======================================================================== #
while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                model)
                    model="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_out_net)
                    p_out_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_out_dir)
                    p_out_dir="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                seed)
                    seed="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
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
                p_out_logs)
                    p_out_logs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_penalize)
                    flag_penalize="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_training)
                    flag_training="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                nbr_reg)
                    nbr_reg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_intercept)
                    flag_intercept="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                l_top_edges)
                    nargs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    if [ ${nargs} == "NONE" ]
                    then
                        l_top_edges="NONE"
                    else
                        l_top_edges=()
                        for ((i=1;i<`expr ${nargs} + 1`;i++))
                        do
                            arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                            l_top_edges+=("${arg}")
                        done
                    fi
                    ;;
             esac;;
        h)
            echo "usage"
            exit 2
           ;;
    esac
done

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
# |                 *** Combine networks LASSO, DE, ETC ***              | #  
# ------------------------------------------------------------------------ #


# ------------------------------------------------------------------------ #
# |                       *** 1-fold of Training ***                     | #  
# ------------------------------------------------------------------------ #
if [ ${flag_training} == "1-fold" ]
then

    source activate netprophet
    if [ ${flag_slurm} == "ON" ]
    then
        ls -l /home/dabid/.conda/envs/netprophet/bin >> ${p_out_logs}tmp.txt
    fi
    
    echo "- select and write training/testing for one fold.."
    mkdir -p ${p_out_dir}data_1_fold/
    python ${p_src_code}code/combine_networks_select_write_training_testing_1_fold.py \
        --p_net_binding ${p_net_binding} \
        --l_net_name lasso de bart pwm new \
        --l_p_net ${p_net_lasso} ${p_net_de} ${p_net_bart} ${p_net_pwm} ${p_net_new} \
        --seed ${seed} \
        --p_out_dir ${p_out_dir}data_1_fold/ \
        --nbr_reg ${nbr_reg}
   
    source deactivate netprophet
    if [ ${flag_slurm} == "ON" ]
    then
        ls -l /home/dabid/.conda/envs/netprophet/bin >> ${p_out_logs}tmp.txt
    fi
    
    # LASSO
    if [ ${p_net_lasso} != "NONE" ]
    then
        p_net_lasso_train=${p_out_dir}data_1_fold/train_lasso.tsv
        p_net_lasso_test=${p_out_dir}data_1_fold/test_lasso.tsv
    else
        p_net_lasso_train="NONE"
        p_net_lasso_test="NONE"
    fi

    # DE
    if [ ${p_net_de} != "NONE" ]
    then
        p_net_de_train=${p_out_dir}data_1_fold/train_de.tsv
        p_net_de_test=${p_out_dir}data_1_fold/test_de.tsv
    else
        p_net_de_train="NONE"
        p_net_de_test="NONE"
    fi

    # BART
    if [ ${p_net_bart} != "NONE" ]
    then
        p_net_bart_train=${p_out_dir}data_1_fold/train_bart.tsv
        p_net_bart_test=${p_out_dir}data_1_fold/test_bart.tsv
    else
        p_net_bart_train="NONE"
        p_net_bart_test="NONE"
    fi
    
    # PWM
    if [ ${p_net_pwm} != "NONE" ]
    then
        p_net_pwm_train=${p_out_dir}data_1_fold/train_pwm.tsv
        p_net_pwm_test=${p_out_dir}data_1_fold/test_pwm.tsv
    else
        p_net_pwm_train="NONE"
        p_net_pwm_test="NONE"
    fi
    
    # NEW
    if [ ${p_net_new} != "NONE" ]
    then
        p_net_new_train=${p_out_dir}data_1_fold/train_new.tsv
        p_net_new_test=${p_out_dir}data_1_fold/test_new.tsv
    else
        p_net_new_train="NONE"
        p_net_new_test="NONE"
    fi

    mkdir -p ${p_out_dir}data_pred/
    
    ${p_src_code}wrapper/combine_networks_train_test.sh \
            --p_net_train_binding ${p_out_dir}data_1_fold/train_binding.tsv \
            --p_net_train_lasso ${p_net_lasso_train} \
            --p_net_train_de ${p_net_de_train} \
            --p_net_train_bart ${p_net_bart_train} \
            --p_net_train_pwm ${p_net_pwm_train} \
            --p_net_train_new ${p_net_new_train} \
            --p_net_test_lasso ${p_net_lasso_test} \
            --p_net_test_de ${p_net_de_test} \
            --p_net_test_bart ${p_net_bart_test} \
            --p_net_test_pwm ${p_net_pwm_test} \
            --p_net_test_new ${p_net_new_test} \
            --model ${model} \
            --p_out_pred_train ${p_out_dir}data_pred/pred_train.tsv \
            --p_out_pred_test ${p_out_net} \
            --p_out_optimal_lambda ${p_out_dir}data_pred/lambda.tsv \
            --p_tmp_penalize ${p_out_dir}tmp_penalize/ \
            --p_out_model_summary ${p_out_dir}data_pred/model_summary.txt \
            --p_out_model ${p_out_dir}data_pred/model.RData \
            --p_src_code ${p_src_code} \
            --seed ${seed} \
            --flag_slurm ${flag_slurm} \
            --flag_intercept ${flag_intercept} \
            --p_out_dir ${p_out_dir} \
            --flag_penalize ${flag_penalize} \
            --p_out_logs ${p_out_logs} \
            --fold ""
    # feed forward...
    
    echo "***FEED-FORWARD*** started for top edges: ${l_top_edges[@]}.."
    p_in_top_net=${p_out_dir}data_pred/pred_train.tsv
    
    for (( i=0;i<${#l_top_edges[@]};i++ ))
    do
        # wait if the netprophet network file is not ready 
        # from previous iteration
        while [ ! -f ${p_in_top_net} ]
        do
            sleep 10
        done
        sleep 120  # to wait for the p_in_top_net file to complete writing..
        
        # initialize nbre of top edges and corresponding output dir
        top_edges=${l_top_edges[i]}
        mkdir -p ${p_out_dir}top_${top_edges}/
        mkdir -p ${p_out_dir}top_${top_edges}/data_1_fold/
        mkdir -p ${p_out_dir}top_${top_edges}/data_pred/
        mkdir -p ${p_out_logs}top_${top_edges}/
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
        # |                 *** select top edges ***                  | #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
        echo ""
        echo "select top edges: ${top_edges}.."
        source activate netprophet
        if [ ${flag_slurm} == "ON" ]
        then
            ls -l /home/dabid/.conda/envs/netprophet/bin >> ${p_out_logs}tmp.txt
        fi

        python ${p_src_code}code/combine_networks_select_top_k_edges.py \
            --p_in_top_net ${p_in_top_net} \
            --l_net_name binding lasso de bart pwm new \
            --l_p_in_net ${p_net_binding} ${p_net_lasso} ${p_net_de} ${p_net_bart} ${p_net_pwm} ${p_net_new} \
            --p_out_dir ${p_out_dir}top_${top_edges}/data_1_fold/ \
            --l_out_fname_net net_binding.tsv net_lasso.tsv net_de.tsv net_bart.tsv net_pwm.tsv net_new.tsv \
            --top ${top_edges}
            
        source deactivate netprophet
        if [ ${flag_slurm} == "ON" ]
        then
            ls -l /home/dabid/.conda/envs/netprophet/bin >> ${p_out_logs}tmp.txt
        fi

        if [ ${p_net_lasso} != "NONE" ]
        then
            p_net_lasso_top=${p_out_dir}top_${top_edges}/data_1_fold/net_lasso.tsv
        else
            p_net_lasso_top="NONE"
        fi
        
        if [ ${p_net_de} != "NONE" ]
        then
            p_net_de_top=${p_out_dir}top_${top_edges}/data_1_fold/net_de.tsv
        else
            p_net_de_top="NONE"
        fi
        
        if [ ${p_net_bart} != "NONE" ]
        then
            p_net_bart_top=${p_out_dir}top_${top_edges}/data_1_fold/net_bart.tsv
        else
            p_net_bart_top="NONE"
        fi
        
        if [ ${p_net_binding} != "NONE" ]
        then
            p_net_binding_top=${p_out_dir}top_${top_edges}/data_1_fold/net_binding.tsv
        else
            p_net_binding_top="NONE"
        fi
        
        if [ ${p_net_pwm} != "NONE" ]
        then
            p_net_pwm_top=${p_out_dir}top_${top_edges}/data_1_fold/net_pwm.tsv
        else
            p_net_pwm_top="NONE"
        fi
        
        if [ ${p_net_new} != "NONE" ]
        then
            p_net_new_top=${p_out_dir}top_${top_edges}/data_1_fold/net_new.tsv
        else
            p_net_new_top="NONE"
        fi
        ${p_src_code}wrapper/combine_networks_train_test.sh \
            --p_net_train_binding ${p_net_binding_top} \
            --p_net_train_lasso ${p_net_lasso_top} \
            --p_net_train_de ${p_net_de_top} \
            --p_net_train_bart ${p_net_bart_top} \
            --p_net_train_pwm ${p_net_pwm_top} \
            --p_net_train_new ${p_net_new_top} \
            --p_net_test_lasso ${p_net_lasso_test} \
            --p_net_test_de ${p_net_de_test} \
            --p_net_test_bart ${p_net_bart_test} \
            --p_net_test_pwm ${p_net_pwm_test} \
            --p_net_test_new ${p_net_new_test} \
            --model ${model} \
            --p_out_pred_train ${p_out_dir}top_${top_edges}/data_pred/pred_train.tsv \
            --p_out_pred_test ${p_out_dir}top_${top_edges}/net_np3_${top_edges}.tsv \
            --p_out_optimal_lambda ${p_out_dir}top_${top_edges}/data_pred/lambda.tsv \
            --p_tmp_penalize ${p_out_dir}top_${top_edges}/tmp_penalize/ \
            --p_out_model_summary ${p_out_dir}top_${top_edges}/data_pred/model_summary.txt \
            --p_out_model ${p_out_dir}top_${top_edges}/data_pred/model.RData \
            --p_src_code ${p_src_code} \
            --seed ${seed} \
            --flag_slurm ${flag_slurm} \
            --flag_intercept ${flag_intercept} \
            --p_out_dir ${p_out_dir}top_${top_edges}/ \
            --flag_penalize ${flag_penalize} \
            --p_out_logs ${p_out_logs}top_${top_edges}/ \
            --fold ""
        
        p_in_top_net=${p_out_dir}top_${top_edges}/data_pred/pred_train.tsv
    done

# ------------------------------------------------------------------------ #
# |                           *** 10-fold CV ***                         | #  
# ------------------------------------------------------------------------ #
elif [ ${flag_training} == "10-fold-cv" ]
then
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    # |      *** Split networks based on binding support ***      | #
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    echo " - split networks by support/unsupport binding events.."
    source activate netprophet

    if [ ${flag_slurm} == "ON" ]
    then
        ls -l /home/dabid/.conda/envs/netprophet/bin >> ${p_out_logs}tmp.txt
    fi

    python ${p_src_code}code/combine_networks_split_networks_based_on_binding_support.py \
        --p_net_lasso ${p_net_lasso} \
        --p_net_de ${p_net_de} \
        --p_net_bart ${p_net_bart} \
        --p_net_pwm ${p_net_pwm} \
        --p_net_new ${p_net_new} \
        --p_net_binding ${p_net_binding} \
        --p_binding_event ${p_binding_event} \
        --p_out_dir ${p_out_dir}
    source deactivate netprophet
    if [ ${flag_slurm} == "ON" ]
    then
        ls -l /home/dabid/.conda/envs/netprophet/bin >> ${p_out_logs}tmp.txt
    fi
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    # |      *** Combine networks (Train/Test) by 10-fold CV ***      | #
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    if [ -d ${p_out_dir}support ]
    then
        if [ ${p_net_lasso} != "NONE" ]
        then
            p_net_lasso_1=${p_out_dir}support/net_lasso.tsv
        else
            p_net_lasso_1="NONE"
        fi

        if [ ${p_net_de} != "NONE" ]
        then
            p_net_de_1=${p_out_dir}support/net_de.tsv
        else
            p_net_de_1="NONE"
        fi

        if [ ${p_net_bart} != "NONE" ]
        then
            p_net_bart_1=${p_out_dir}support/net_bart.tsv
        else
            p_net_bart_1="NONE"
        fi

        if [ ${p_net_binding} != "NONE" ]
        then
            p_net_binding_1=${p_out_dir}support/net_binding.tsv
        else
            p_net_binding_1="NONE"
        fi

        if [ ${p_net_pwm} != "NONE" ]
        then
            p_net_pwm_1=${p_out_dir}support/net_pwm.tsv
        else
            p_net_pwm_1="NONE"
        fi

        if [ ${p_net_new} != "NONE" ]
        then
            p_net_new_1=${p_out_dir}support/net_new.tsv
        else
            p_net_new_1="NONE"
        fi
        
        p_net_np3_support=${p_out_dir}support/net_np3.tsv

        if [ ${flag_slurm} == "ON" ]
        then
            mkdir -p ${p_out_logs}support/
            echo " - support: submit 10 jobs for training 10-fold cv.."  
            ${p_src_code}wrapper/combine_networks_train_test_for_10_fold_cv.sh \
                --p_net_lasso ${p_net_lasso_1} \
                --p_net_de ${p_net_de_1} \
                --p_net_bart ${p_net_bart_1} \
                --p_net_pwm ${p_net_pwm_1} \
                --p_net_new ${p_net_new_1} \
                --p_net_binding ${p_net_binding_1} \
                --flag_slurm ${flag_slurm} \
                --p_src_code ${p_src_code} \
                --model ${model} \
                --p_out_dir ${p_out_dir}support/ \
                --p_net_np3 ${p_out_dir}support/net_np3.tsv \
                --seed  ${seed} \
                --p_out_logs ${p_out_logs}support/ \
                --flag_penalize ${flag_penalize} \
                --flag_intercept ${flag_intercept}
            

        else
            ${p_src_code}wrapper/combine_networks_train_test_for_10_fold_cv.sh \
               --p_net_lasso ${p_net_lasso_1} \
               --p_net_de ${p_net_de_1} \
               --p_net_bart ${p_net_bart_1} \
               --p_net_pwm ${p_net_pwm_1} \
               --p_net_binding ${p_net_binding_1} \
               --flag_slurm ${flag_slurm} \
               --p_src_code ${p_src_code} \
               --model ${model} \
               --p_out_dir ${p_out_dir}support/ \
               --p_net_np3 ${p_out_dir}support/net_np3.tsv \
               --seed  ${seed} \
               --p_out_logs ${p_out_logs}support/ \
               --flag_penalize ${flag_penalize}
        fi

    fi



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    # |      *** Combine networks (Train/Test) by One Single fold ***      | #
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    if [ -d ${p_out_dir}unsupport ]
    then
        if [ ${p_net_lasso} != "NONE" ]
        then
            p_net_lasso_2=${p_out_dir}unsupport/net_lasso.tsv
        else
            p_net_lasso_2="NONE"
        fi

        if [ ${p_net_de} != "NONE" ]
        then
            p_net_de_2=${p_out_dir}unsupport/net_de.tsv
        else
            p_net_de_2="NONE"
        fi

        if [ ${p_net_bart} != "NONE" ]
        then
            p_net_bart_2=${p_out_dir}unsupport/net_bart.tsv
        else
            p_net_bart_2="NONE"
        fi

        if [ ${p_net_binding} != "NONE" ]
        then
            p_net_binding_2=${p_out_dir}unsupport/net_binding.tsv
        else
            p_net_binding_2="NONE"
        fi

        if [ ${p_net_pwm} != "NONE" ]
        then
            p_net_pwm_2=${p_out_dir}unsupport/net_pwm.tsv
        else
            p_net_pwm_2="NONE"
        fi

        if [ ${p_net_new} != "NONE" ]
        then
            p_net_new_2=${p_out_dir}unsupport/net_new.tsv
        else
            p_net_new_2="NONE"
        fi
        
        mkdir -p ${p_out_dir}unsupport/data_pred/
        p_net_np3_unsupport=${p_out_dir}unsupport/data_pred/net_np3.tsv
        mkdir -p ${p_out_logs}unsupport/
        ${p_src_code}wrapper/combine_networks_train_test.sh \
             --p_net_train_binding  ${p_net_binding_1} \
             --p_net_train_lasso ${p_net_lasso_1} \
             --p_net_train_de ${p_net_de_1} \
             --p_net_train_bart ${p_net_bart_1} \
             --p_net_train_pwm ${p_net_pwm_1} \
             --p_net_train_new ${p_net_new_1} \
             --p_net_test_lasso ${p_net_lasso_2} \
             --p_net_test_de ${p_net_de_2} \
             --p_net_test_bart ${p_net_bart_2} \
             --p_net_test_pwm ${p_net_pwm_2} \
             --p_net_test_new ${p_net_new_2} \
             --p_out_model ${p_out_dir}unsupport/data_pred/model.RData \
             --p_out_model_summary ${p_out_dir}unsupport/data_pred/model_summary \
             --p_out_pred_train ${p_out_dir}unsupport/data_pred/pred_train.tsv \
             --p_out_pred_test ${p_out_dir}unsupport/data_pred/net_np3.tsv \
             --p_out_optimal_lambda ${p_out_dir}unsupport/data_pred/lambda.tsv \
             --p_tmp_penalize ${p_out_dir}unsupport/penalize/ \
             --p_src_code ${p_src_code} \
             --flag_slurm ${flag_slurm} \
             --seed ${seed} \
             --model ${model} \
             --p_out_logs ${p_out_logs}unsupport/ \
             --p_out_dir ${p_out_dir}unsupport/ \
             --flag_intercept ${flag_intercept} \
             --flag_penalize ${flag_penalize} \
             --fold ""
                 
    while [ ! -f ${p_out_dir}unsupport/job_ids/train_test.txt ]
    do
        sleep 10
    done
    job_id_train_test_all_training=$(<${p_out_dir}unsupport/job_ids/train_test.txt)
    echo " - unsupport: submit job ${job_id_train_test_all_training} for traininig one fold.."
            
    fi

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    # |     *** Concatenate networks with/without binding data ***    | #
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

    if [ ${flag_slurm} == "ON" ]
    then
        while [[ ! -f ${p_out_dir}support/job_ids/concat_cv.txt ]]
        do
            sleep 10
        done

        job_id_train_test_cv=$(<${p_out_dir}support/job_ids/concat_cv.txt)
        job_concat_networks=$(sbatch \
                            -o ${p_out_logs}concat_net_with_without_support_%J.out \
                            -e ${p_out_logs}concat_net_with_without_support_%J.err \
                            -J concat_net_with_without_support \
                            --dependency=afterok:${job_id_train_test_cv}:${job_id_train_test_all_training} \
                            ${p_src_code}wrapper/combine_networks_concatenate_networks.sh \
                                --p_net_np3_with_support ${p_net_np3_support} \
                                --p_net_np3_without_support ${p_net_np3_unsupport} \
                                --p_net_np3 ${p_out_net} \
                                --flag_concat "concat_with_without_support" \
                                --p_src_code ${p_src_code} \
                                --flag_slurm ${flag_slurm})
        job_id_concat_networks=$(echo ${job_concat_networks} | awk '{split($0, a, " "); print a[4]}')
        echo " - concatenate support & unsupport networks: submit job ${job_id_concat_networks}.."
    else
        source activate netprophet
        python ${p_src_code}code/combine_networks_concat_networks.py \
            --l_p_in_net ${p_net_np3_support} ${p_net_np3_unsupport} \
            --p_out_file ${p_out_net} \
            --flag_method "a"
        source deactivate netprophet
    fi
fi

