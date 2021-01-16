#!/bin/bash

echo "generate netprophet1 network.."

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                p_net_lasso)
                    p_net_lasso="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_de)
                    p_net_de="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_np1)
                    p_net_np1="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                esac;;
        h)
            echo "usage"
            exit 2
            ;;
    esac
done

if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

Rscript ${p_src_code}code/build_net_np1.R \
    --p_in_net_lasso ${p_net_lasso} \
    --p_in_net_de ${p_net_de} \
    --p_out_net_np1 ${p_net_np1} \
    --p_src_code ${p_src_code}
