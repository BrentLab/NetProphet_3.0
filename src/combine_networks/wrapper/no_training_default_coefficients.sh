#!/bin/bash

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                # Input
                l_in_name_net)
                    l_in_name_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                l_in_path_net)
                    l_in_path_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                in_model_name)
                    in_model_name="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                in_coef)
                    in_coef="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_in_model)
                    p_in_model="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                
                # Output
                p_out_dir)
                    p_out_dir="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                    
                # Logistics
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_progress)
                    p_progress="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_debug)
                    flag_debug="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                
                # SLURM
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                
                # Singularity
                flag_singularity)
                    flag_singularity="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_singularity_img)
                    p_singularity_img="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_singularity_bindpath)
                    p_singularity_bindpath="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
            esac;;
        h)
            echo "usage"
            exit 2
            ;;
    esac
done
                                  
                                  
echo "combine with no training, default model/coeffients.." >> ${p_progress}
cmd=""
if [ ${flag_singularity} == "ON" ]; then
    if [ ${flag_slurm} == "ON" ]; then source ${p_src_code}src/helper/load_singularity.sh; fi
    export SINGULARITY_BINDPATH=${p_singularity_bindpath}
    cmd+="singularity exec ${p_singularity_img} "
elif [ ${flag_singularity} == "OFF" ]; then
    if [ ${flag_slurm} == "ON" ]; then
        source ${p_src_code}src/helper/load_modules.sh
    fi
fi

cmd+="Rscript ${p_src_code}src/combine_networks/code/no_training_default_coefficients.R \
        --l_in_name_net ${l_in_name_net} \
        --l_in_path_net ${l_in_path_net} \
        --in_model_name ${in_model_name} \
        --in_coef ${in_coef} \
        --p_in_model ${p_in_model} \
        --p_out_net_np3 ${p_out_dir}net_np3.tsv \
        --p_src_code ${p_src_code}"
        
if [ ${flag_debug} == "ON" ]; then printf "***R CMD***\n${cmd}\n" >> ${p_progress}; fi
eval ${cmd}
    
