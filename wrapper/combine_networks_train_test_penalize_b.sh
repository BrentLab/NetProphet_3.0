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
            p_binding_train)
                p_binding_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_name_net)
                l_name_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_path_net_train)
                l_path_net_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_path_net_test)
                l_path_net_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
            model_name)
                model_name="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
source ${p_src_code}wrapper/helper.sh

if [ ${flag_step} == "train_and_write_model_with_all_training" ]
then
    Rscript ${p_src_code}code/combine_networks_train_test_penalize.R \
        --p_binding_train ${p_binding_train} \
        --l_name_net ${l_name_net} \
        --l_path_net_train ${l_path_net_train} \
        --model_name ${model_name} \
        --p_model ${p_out_model} \
        --flag_step ${flag_step} \
        --flag_penalize ${flag_penalize} \
        --p_src_code ${p_src_code}

elif [ ${flag_step} == "train_and_write_model_with_fold_training" ]
then
    l_path_net_train_cv=$(create_paths ${l_name_net} fold${SLURM_ARRAY_TASK_ID}_train ${p_tmp_penalize}data_cv/)
    
    Rscript ${p_src_code}code/combine_networks_train_test_penalize.R \
        --p_binding_train ${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_train_binding.tsv \
        --l_name_net ${l_name_net} \
        --l_path_net_train ${l_path_net_train_cv} \
        --model_name ${model_name} \
        --p_model ${p_tmp_penalize}data_pred/fold${SLURM_ARRAY_TASK_ID}_model.RData \
        --flag_step ${flag_step} \
        --flag_penalize ${flag_penalize} \
        --p_src_code ${p_src_code}

elif [ ${flag_step} == "test_and_write_sum_log_likelihood" ]
then
    l_path_net_test_cv=$(create_paths ${l_name_net} fold${SLURM_ARRAY_TASK_ID}_test ${p_tmp_penalize}data_cv/)
    l_path_net_train_cv=$(create_paths ${l_name_net} fold${SLURM_ARRAY_TASK_ID}_train ${p_tmp_penalize}data_cv/)
    
    Rscript ${p_src_code}code/combine_networks_train_test_penalize.R \
        --p_in_model_lambda ${p_out_model} \
        --p_model ${p_tmp_penalize}data_pred/fold${SLURM_ARRAY_TASK_ID}_model.RData \
        --model_name ${model_name} \
        --p_binding_test ${p_tmp_penalize}data_cv/fold${SLURM_ARRAY_TASK_ID}_test_binding.tsv  \
        --l_name_net ${l_name_net} \
        --l_path_net_train ${l_path_net_train_cv} \
        --l_path_net_test ${l_path_net_test_cv} \
        --p_out_log_likelihood ${p_tmp_penalize}data_pred/fold${SLURM_ARRAY_TASK_ID}_log_likelihood.tsv \
        --flag_step ${flag_step} \
        --p_src_code ${p_src_code}
        
elif [ ${flag_step} == "select_optimal_lambda_and_predict" ]
then
    Rscript ${p_src_code}code/combine_networks_train_test_penalize.R \
        --p_binding_train ${p_binding_train} \
        --l_name_net ${l_name_net} \
        --l_path_net_train ${l_path_net_train} \
        --l_path_net_test ${l_path_net_test} \
        --p_in_model_lambda ${p_out_model} \
        --model_name ${model_name} \
        --p_dir_log_likelihood ${p_tmp_penalize}data_pred/ \
        --p_out_pred_train ${p_out_pred_train} \
        --p_out_pred_test ${p_out_pred_test} \
        --p_out_optimal_lambda ${p_out_optimal_lambda} \
        --flag_step ${flag_step} \
        --p_src_code ${p_src_code}
fi
    
    
    