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
            p_net_binding)
                p_net_binding="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_lasso)
                p_net_lasso="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_de)
                p_net_de="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_bart)
                p_net_bart="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_pwm)
                p_net_pwm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_new)
                p_net_new="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_dir)
                p_out_dir="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_src_code)
                p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            seed)
                seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
        esac;;
    esac
done
source activate netprophet
ls -l /home/dabid/.conda/envs/netprophet/bin > /dev/null

python ${p_src_code}code/combine_networks_select_write_training_testing_10_fold_cv.py \
    --l_net_name binding lasso de bart pwm new \
    --l_p_net ${p_net_binding} \
                 ${p_net_lasso} \
                 ${p_net_de} \
                 ${p_net_bart} \
                 ${p_net_pwm} \
                 ${p_net_new} \
    --p_out_dir ${p_out_dir} \
    --seed ${seed} \
    --p_src_code ${p_src_code}

source deactivate netprophet
ls -l /home/dabid/.conda/envs/netprophet/bin > /dev/null 
