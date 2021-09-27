#!/bin/bash

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                p_in_dir)
                    p_in_dir="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    ;;
                nbr_bootstrap)
                    nbr_bootstrap="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                nbr_cv_fold)
                    nbr_cv_fold="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_training)
                    flag_training="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                    
                # slurm
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                    
                # singularity
                flag_singularity)
                    flag_singularity="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_singularity_img)
                    p_singularity_img="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_singularity_bindpath)
                    p_singularity_bindpath="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                    
                # logistic
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
            esac;
        esac   
done

cmd=""

if [ ${flag_singularity} == "ON" ]; then
    if [ ${flag_slurm} == "ON" ]; then
        source ${p_src_code}src/helper/load_singularity.sh
    fi
    export SINGULARITY_BINDPATH=${p_singularity_bindpath}
    cmd+="singularity exec ${p_singularity_img}"
elif [ ${flag_singularity} == "OFF" ]; then
    if [ ${flag_slurm} == "ON" ]; then
        source ${p_src_code}src/helper/load_modules.sh
        source activate np3
        ls -l ${CONDA_PREFIX}/bin >> /dev/null
    fi
fi

cmd+="python3 ${p_src_code}src/combine_networks/extra_modules/bootstrap/code/create_bootstrap_sets_for_training.py \
        --p_in_dir ${p_in_dir} \
        --nbr_bootstrap ${nbr_bootstrap} \
        --nbr_cv_fold ${nbr_cv_fold} \
        --flag_training ${flag_training}"

eval ${cmd}

if [ ${flag_singularity} == "OFF" ] && [ ${flag_slurm} == "ON" ]; then
    source deactivate np3
fi