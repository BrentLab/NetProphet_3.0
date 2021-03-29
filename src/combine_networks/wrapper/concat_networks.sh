#!/bin/bash

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                # Input
                p_in_net_np3_1)
                    p_in_net_np3_1="${!OPTIND}"; OPTIND=$(( $OPTIND + 1))
                    ;;
                p_in_net_np3_2)
                    p_in_net_np3_2="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                flag_concat)
                    flag_concat="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                p_in_dir_data_cv)
                    p_in_dir_data_cv="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                p_in_dir_pred)
                    p_in_dir_pred="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
     
                # Output
                p_out_net_np3)
                    p_out_net_np3="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                    
                # SLURM
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
               
                # Singularity
                flag_singularity)
                    flag_singularity="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                p_singularity_img)
                    p_singularity_img="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                p_singularity_bindpath)
                    p_singularity_bindpath="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
            esac;
    esac
done

cmd=""

if [ ${flag_singularity} == "ON" ]; then
    if [ ${flag_slurm} == "ON" ]; then
        source ${p_src_code}src/helper/load_singularity.sh
    fi
    export SINGULARITY_BINDPATH=${p_singularity_bindpath}
    cmd+="singularity exec ${p_singularity_img} "
    
elif [ ${flag_singularity} == "OFF" ]; then
    if [ ${flag_slurm} == "ON" ]; then
        source ${p_src_code}src/helper/load_modules.sh
        source activate np3
        ls -l ${SLURM_SUBMIT_DIR}/np3/bin > /dev/null
    fi
fi

if [ ${flag_concat} == "concat_cv" ]; then
    cmd+="python3 ${p_src_code}src/combine_networks/code/concat_networks.py \
         --p_in_dir_data ${p_in_dir_data_cv} \
         --p_in_dir_pred ${p_in_dir_pred} \
         --p_out_file ${p_out_net_np3}"
    
elif [ ${flag_concat} == "two_networks" ]; then
    cmd+="python3 ${p_src_code}src/combine_networks/code/concat_networks.py \
         --l_p_in_net ${p_in_net_np3_1} ${p_in_net_np3_2} \
         --p_out_file ${p_out_net_np3} \
         --flag_method 'a'"
fi

if [ ${flag_debug} == "ON" ]; then printf "***PYTHON CMD***\n${cmd}\n" >> ${p_progress}; fi
eval ${cmd}

if [ ${flag_singularity} == "OFF" ] && [ ${flag_slurm} == "ON" ]; then source deactivate np3; fi