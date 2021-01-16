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
        esac;;
    esac
done

if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

Rscript ${p_src_code}code/combine_networks_train_test.R \
    --p_in_train_binding ${p_net_train_binding} \
    --p_in_train_lasso ${p_net_train_lasso} \
    --p_in_train_de ${p_net_train_de} \
    --p_in_train_bart ${p_net_train_bart} \
    --p_in_train_pwm ${p_net_train_pwm} \
    --p_in_train_new ${p_net_train_new} \
    --p_in_test_lasso ${p_net_test_lasso} \
    --p_in_test_de ${p_net_test_de} \
    --p_in_test_bart ${p_net_test_bart} \
    --p_in_test_pwm ${p_net_test_pwm} \
    --p_in_test_new ${p_net_test_new}\
    --in_model ${model} \
    --p_out_pred_train ${p_out_pred_train} \
    --p_out_pred_test ${p_out_pred_test} \
    --p_out_model_summary ${p_out_model_summary} \
    --p_out_model ${p_out_model} \
    --p_src_code ${p_src_code} \
    --flag_intercept ${flag_intercept}