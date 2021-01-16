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
            p_with_de)
                p_with_de="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_without_de)
                p_without_de="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_with_de_feed)
                p_with_de_feed="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_without_de_feed)
                p_without_de_feed="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_out_file_with_de)
                p_out_file_with_de="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_out_file_without_de)
                p_out_file_without_de="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_out_file_with_de_feed)
                p_out_file_with_de_feed="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_out_file_without_de_feed)
                p_out_file_without_de_feed="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_src_code)
                p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            flag_slurm)
                flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
        esac;
    esac
done

if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi
source activate netprophet
ls -la /home/dabid/.conda/envs/netprophet/bin

echo "analyze coefficients.."
mkdir -p ${p_out_net}analysis/
python ${p_src_code}code/combine_networks_analyze_coefficients.py \
--l_p_in_dir ${p_with_de} ${p_without_de} ${p_with_de_feed} ${p_without_de_feed} \
--l_p_out_file ${p_out_file_with_de} ${p_out_file_without_de} ${p_out_file_with_de_feed} ${p_out_file_without_de_feed}
source deactivate netprophet