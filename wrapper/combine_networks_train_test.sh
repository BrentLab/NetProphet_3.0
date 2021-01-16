#!/bin/bash

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
    h)
        usage
        exit 2
        ;;
    -)
        case "${OPTARG}" in
            p_net_train_binding)
                p_net_train_binding="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_train_lasso)
                p_net_train_lasso="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_train_de)
                p_net_train_de="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_train_bart)
                p_net_train_bart="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_train_pwm)
                p_net_train_pwm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_train_new)
                p_net_train_new="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_test_lasso)
                p_net_test_lasso="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_test_de)
                p_net_test_de="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_test_bart)
                p_net_test_bart="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_test_pwm)
                p_net_test_pwm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_test_new)
                p_net_test_new="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            model)
                model="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_pred_train)
                p_out_pred_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_pred_test)
                p_out_pred_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_model_summary)
                p_out_model_summary="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_model)
                p_out_model="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            flag_slurm)
                flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_src_code)
                p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            flag_intercept)
                flag_intercept="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            flag_penalize)
                flag_penalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            fold)
                fold="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            seed)
                seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_optimal_lambda)
                p_out_optimal_lambda="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_tmp_penalize)
                p_tmp_penalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_logs)
                p_out_logs="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_dir)
                p_out_dir="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
        esac;;
    esac
done         
        
if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

if [ ${flag_penalize} == "ON" ] \
    || [ ${flag_penalize} == "L1" ] \
    || [ ${flag_penalize} == "L2" ] \
    || [ ${flag_penalize} == "L1_L2" ]
then
    mkdir -p ${p_tmp_penalize}
    mkdir -p ${p_out_logs}penalize/
    if [ -z ${fold} ]
    then
        p_out_logs_penalize=${p_out_logs}penalize/
    else
        p_out_logs_penalize=${p_out_logs}penalize/fold${fold}/
    fi
    ${p_src_code}wrapper/combine_networks_train_test_penalize_a.sh \
        --p_net_binding_train ${p_net_train_binding} \
        --p_net_lasso_train ${p_net_train_lasso} \
        --p_net_de_train ${p_net_train_de} \
        --p_net_bart_train ${p_net_train_bart} \
        --p_net_pwm_train ${p_net_train_pwm} \
        --p_net_new_train ${p_net_train_new} \
        --p_net_lasso_test ${p_net_test_lasso} \
        --p_net_de_test ${p_net_test_de} \
        --p_net_bart_test ${p_net_test_bart} \
        --p_net_pwm_test ${p_net_test_pwm} \
        --p_net_new_test ${p_net_test_new} \
        --p_out_model ${p_out_model} \
        --p_out_pred_train ${p_out_pred_train} \
        --p_out_pred_test ${p_out_pred_test} \
        --p_out_optimal_lambda ${p_out_optimal_lambda} \
        --p_tmp_penalize ${p_tmp_penalize} \
        --flag_penalize ${flag_penalize} \
        --p_src_code ${p_src_code} \
        --seed ${seed} \
        --model ${model} \
        --p_out_logs ${p_out_logs_penalize} \
        --p_out_dir ${p_out_dir} \
        --fold ${fold}
else
    mkdir -p ${p_out_logs}
    job_train_test_basic=$(sbatch \
                           -o ${p_out_logs}combine_networks_train_test_${fold}_%J.out \
                           -e ${p_out_logs}combine_networks_train_test_${fold}_%J.err \
                           -J combine_networks_${fold} \
                           --mem-per-cpu 20G \
                           ${p_src_code}wrapper/combine_networks_train_test_basic.sh \
                                --p_net_train_binding ${p_net_train_binding} \
                                --p_net_train_lasso ${p_net_train_lasso} \
                                --p_net_train_de ${p_net_train_de} \
                                --p_net_train_bart ${p_net_train_bart} \
                                --p_net_train_pwm ${p_net_train_pwm} \
                                --p_net_train_new ${p_net_train_new} \
                                --p_net_test_lasso ${p_net_test_lasso} \
                                --p_net_test_de ${p_net_test_de} \
                                --p_net_test_bart ${p_net_test_bart} \
                                --p_net_test_pwm ${p_net_test_pwm} \
                                --p_net_test_new ${p_net_test_new} \
                                --model ${model} \
                                --p_out_pred_train ${p_out_pred_train} \
                                --p_out_pred_test ${p_out_pred_test} \
                                --p_out_model_summary ${p_out_model_summary} \
                                --p_out_model ${p_out_model} \
                                --p_src_code ${p_src_code} \
                                --flag_intercept ${flag_intercept} \
                                --flag_slurm ${flag_slurm})
    
    job_id_train_test_basic=$(echo  ${job_train_test_basic} | awk '{split($0, a, " "); print a[4]}')
    echo "   - submit job ${job_id_train_test_basic}: ${fold}.."
    mkdir -p ${p_out_dir}job_ids/
    echo "${job_id_train_test_basic}" > ${p_out_dir}job_ids/train_test${fold}.txt
fi