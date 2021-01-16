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
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
               flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                l_p_dir_combine)
                    narg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1))
                    l_p_dir_combine=("${narg}")
                    for (( i=1;i<`expr ${narg}+1`;i++ ))
                    do
                        arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                        l_p_dir_combine+=("${arg}")
                    done
                    ;;
                l_p_dir_analysis)
                    narg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    l_p_dir_analysis=("${narg}")
                    for (( i=1;i<`expr ${narg}+1`;i++ ))
                    do
                        arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                        l_p_dir_analysis+=("${arg}")
                    done
                    ;;
            esac;
    esac
done


if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

for (( i=1;i<${#l_p_dir_combine[@]};i++ ))
do
    echo "${l_p_dir_combine[${i}]}"
    echo "${l_p_dir_analysis[${i}]}"
    Rscript ${p_src_code}code/analyze_predictors.R \
        --p_dir_combine ${l_p_dir_combine[${i}]} \
        --p_out_file_analysis ${l_p_dir_analysis[${i}]}
done
