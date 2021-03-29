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
            # Input
            p_in_net_binding)
                p_in_net_binding="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_in_name_net)
                l_in_name_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_in_path_net)
                l_in_path_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            seed)
                seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
                
            # Output
            p_out_dir)
                p_out_dir="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
                
            # Logistics
            p_src_code)
                p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_progress)
                p_progress="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            flag_debug)
                flag_debug="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            
            # Singularity
            flag_singularity)
                flag_singularity="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_singularity_img)
                p_singularity_img="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_singularity_bindpath)
                p_singularity_bindpath="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
                
            # SLURM
            flag_slurm)
                flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
        esac;;
    esac
done

    
cmd=""
if [ ${flag_singularity} == "ON" ]; then
    if [ ${flag_slurm} == "ON" ]; then source ${p_src_code}src/helper/load_singularity.sh; fi
    export SINGULARITY_BINDPATH=${p_singularity_bindpath}
    cmd+="singularity exec ${p_singularity_img} "
elif [ ${flag_singularity} == "OFF" ]; then
    if [ ${flag_slurm} == "ON" ]; then
        source ${p_src_code}src/helper/load_modules.sh
        source activate np3
        ls -l ${SLURM_SUBMIT_DIR}/np3/bin > /dev/null
    fi
fi

cmd+="python3 ${p_src_code}src/combine_networks/code/select_training_testing_sets_for_cv_folds.py \
    --l_in_name_net ${l_in_name_net} \
    --l_in_path_net ${l_in_path_net} \
    --p_in_net_binding ${p_in_net_binding} \
    --seed ${seed} \
    --p_out_dir ${p_out_dir}"

if [ ${flag_debug} == "ON" ]; then printf "***PYTHON CMD***\n${cmd}\n" >> ${p_progress}; fi
eval ${cmd}

if [ ${flag_singularity} == "OFF" ] && [ ${flag_slurm} == "ON" ]; then source deactivate np3; fi