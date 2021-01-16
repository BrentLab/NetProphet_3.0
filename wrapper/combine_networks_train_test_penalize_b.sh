#!/bin/bash
p_net_binding_train="NONE"
p_net_lasso_train="NONE"
p_net_de_train="NONE"
p_net_bart_train="NONE"
p_net_pwm_train="NONE"
p_net_binding_test="NONE"
p_net_lasso_test="NONE"
p_net_de_test="NONE"
p_net_bart_test="NONE"
p_net_pwm_test="NONE"

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
    h)
        usage
        exit 2
        ;;
    -)
        case "${OPTARG}" in
            p_net_binding_train)
                p_net_binding_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_lasso_train)
                p_net_lasso_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_de_train)
                p_net_de_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_bart_train)
                p_net_bart_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_pwm_train)
                p_net_pwm_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_new_train)
                p_net_new_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_binding_test)
                p_net_binding_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_lasso_test)
                p_net_lasso_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_de_test)
                p_net_de_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_bart_test)
                p_net_bart_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_pwm_test)
                p_net_pwm_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_new_test)
                p_net_new_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_tmp_penalize)
                p_tmp_penalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_src_code)
                p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            seed)
                seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            model)
                model="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_logs)
                p_out_logs="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            flag_step)
                flag_step="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            flag_penalize)
                flag_penalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_pred_train)
                p_out_pred_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_pred_test)
                p_out_pred_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_optimal_lambda)
                p_out_optimal_lambda="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_model)
                p_out_model="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
        esac;;
    esac
done

source ${p_src_code}wrapper/helper_load_modules.sh


if [ ${flag_step} == "train_and_write_model_with_all_training" ]
then
    Rscript ${p_src_code}code/combine_networks_train_test_penalize.R \
        --p_in_train_binding ${p_net_binding_train} \
        --p_in_train_lasso ${p_net_lasso_train} \
        --p_in_train_de ${p_net_de_train} \
        --p_in_train_bart ${p_net_bart_train} \
        --p_in_train_pwm ${p_net_pwm_train} \
        --p_in_train_new ${p_net_new_train} \
        --in_model ${model} \
        --p_model ${p_out_model} \
        --flag_step ${flag_step} \
        --flag_penalize ${flag_penalize} \
        --p_src_code ${p_src_code}

elif [ ${flag_step} == "train_and_write_model_with_fold_training" ]
then
    # BINDIDNG
    if [ ${p_net_binding_train} != "NONE" ]
    then
        p_net_binding_train_sub=${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_train_binding.tsv
    else
        p_net_binding_train_sub="NONE"
    fi

    # LASSO
    if [ ${p_net_lasso_train} != "NONE" ]
    then
        p_net_lasso_train_sub=${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_train_lasso.tsv
    else
        p_net_lasso_train_sub="NONE"
    fi

    # DE
    if [ ${p_net_de_train} != "NONE" ]
    then
        p_net_de_train_sub=${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_train_de.tsv
    else
        p_net_de_train_sub="NONE"
    fi

    # BART
    if [ ${p_net_bart_train} != "NONE" ]
    then
        p_net_bart_train_sub=${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_train_bart.tsv
    else
        p_net_bart_train_sub="NONE"
    fi

    # PWM
    if [ ${p_net_pwm_train} != "NONE" ]
    then
        p_net_pwm_train_sub=${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_train_pwm.tsv
    else
        p_net_pwm_train_sub="NONE"
    fi
    
    # NEW
    if [ ${p_net_new_train} != "NONE" ]
    then
        p_net_new_train_sub=${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_train_new.tsv
    else
        p_net_new_train_sub="NONE"
    fi
    
    Rscript ${p_src_code}code/combine_networks_train_test_penalize.R \
        --p_in_train_binding ${p_net_binding_train_sub} \
        --p_in_train_lasso ${p_net_lasso_train_sub} \
        --p_in_train_de ${p_net_de_train_sub} \
        --p_in_train_bart ${p_net_bart_train_sub} \
        --p_in_train_pwm ${p_net_pwm_train_sub} \
        --p_in_train_new ${p_net_new_train_sub} \
        --in_model ${model} \
        --p_model ${p_tmp_penalize}data_pred/fold${SLURM_ARRAY_TASK_ID}_model.RData \
        --flag_step ${flag_step} \
        --flag_penalize ${flag_penalize} \
        --p_src_code ${p_src_code}

elif [ ${flag_step} == "test_and_write_sum_log_likelihood" ]
then
    # BINDIDNG
    if [ ${p_net_binding_train} != "NONE" ]
    then
        p_net_binding_test_sub=${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_test_binding.tsv
    else
        p_net_binding_test_sub="NONE"
    fi

    # LASSO
    if [ ${p_net_lasso_train} != "NONE" ]
    then
        p_net_lasso_test_sub=${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_test_lasso.tsv
    else
        p_net_lasso_test_sub="NONE"
    fi

    # DE
    if [ ${p_net_de_train} != "NONE" ]
    then
        p_net_de_test_sub=${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_test_de.tsv
    else
        p_net_de_test_sub="NONE"
    fi

    # BART
    if [ ${p_net_bart_train} != "NONE" ]
    then
        p_net_bart_test_sub=${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_test_bart.tsv
    else
        p_net_bart_test_sub="NONE"
    fi

    # PWM
    if [ ${p_net_pwm_train} != "NONE" ]
    then
        p_net_pwm_test_sub=${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_test_pwm.tsv
    else
        p_net_pwm_test_sub="NONE"
    fi
    
    # NEW
    if [ ${p_net_new_train} != "NONE" ]
    then
        p_net_new_test_sub=${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_test_new.tsv
    else
        p_net_new_test_sub="NONE"
    fi
    
    Rscript ${p_src_code}code/combine_networks_train_test_penalize.R \
        --p_in_model_lambda ${p_out_model} \
        --p_model ${p_tmp_penalize}data_pred/fold${SLURM_ARRAY_TASK_ID}_model.RData \
        --in_model ${model} \
        --p_in_test_binding  ${p_net_binding_test_sub} \
        --p_in_test_lasso ${p_net_lasso_test_sub} \
        --p_in_test_de ${p_net_de_test_sub} \
        --p_in_test_bart ${p_net_bart_test_sub} \
        --p_in_test_pwm ${p_net_pwm_test_sub} \
        --p_in_test_new ${p_net_new_test_sub} \
        --p_out_log_likelihood ${p_tmp_penalize}data_pred/fold${SLURM_ARRAY_TASK_ID}_log_likelihood.tsv \
        --flag_step ${flag_step} \
        --p_src_code ${p_src_code}
        
elif [ ${flag_step} == "select_optimal_lambda_and_predict" ]
then
    Rscript ${p_src_code}code/combine_networks_train_test_penalize.R \
        --p_in_train_binding ${p_net_binding_train} \
        --p_in_train_lasso ${p_net_lasso_train} \
        --p_in_train_de ${p_net_de_train} \
        --p_in_train_bart ${p_net_bart_train} \
        --p_in_train_pwm ${p_net_pwm_train} \
        --p_in_train_new ${p_net_new_train} \
        --p_in_test_lasso ${p_net_lasso_test} \
        --p_in_test_de ${p_net_de_test} \
        --p_in_test_bart ${p_net_bart_test} \
        --p_in_test_pwm ${p_net_pwm_test} \
        --p_in_test_new ${p_net_new_test} \
        --p_in_model_lambda ${p_out_model} \
        --in_model ${model} \
        --p_dir_log_likelihood ${p_tmp_penalize}data_pred/ \
        --p_out_pred_train ${p_out_pred_train} \
        --p_out_pred_test ${p_out_pred_test} \
        --p_out_optimal_lambda ${p_out_optimal_lambda} \
        --flag_step ${flag_step} \
        --p_src_code ${p_src_code}
fi
    
    
    