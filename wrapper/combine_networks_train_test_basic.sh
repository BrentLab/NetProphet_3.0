#!/bin/bash

flag_intercept="ON"

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
            model_name)
                model_name="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
            l_name_net)
                l_name_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_path_net_train)
                l_path_net_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_path_net_test)
                l_path_net_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
        esac;;
    esac
done

if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

Rscript ${p_src_code}code/combine_networks_train_test.R \
    --p_binding_train ${p_binding_train} \
    --l_name_net ${l_name_net} \
    --l_path_net_train ${l_path_net_train} \
    --l_path_net_test ${l_path_net_test} \
    --model_name ${model_name} \
    --p_out_pred_train ${p_out_pred_train} \
    --p_out_pred_test ${p_out_pred_test} \
    --p_out_model_summary ${p_out_model_summary} \
    --p_out_model ${p_out_model} \
    --p_src_code ${p_src_code} \
    --flag_intercept ${flag_intercept}