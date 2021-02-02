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
            l_name_net)
                l_name_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_path_net)
                l_path_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
    --l_net_name ${l_name_net} \
    --l_p_net ${l_path_net} \
    --p_out_dir ${p_out_dir} \
    --p_net_binding ${p_net_binding} \
    --seed ${seed} \
    --p_src_code ${p_src_code}

source deactivate netprophet
ls -l /home/dabid/.conda/envs/netprophet/bin > /dev/null 
