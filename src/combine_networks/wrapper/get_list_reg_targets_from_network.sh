#!/bin/bash

# ======================================================================== #
# |                        *** HELPER FUNCTIONS ***                      | #
# ======================================================================== #
while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                # Input
                l_in_path_net)
                    l_in_path_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                    
                # Output
                p_out_reg)
                    p_out_reg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                p_out_target)
                    p_out_target="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
                
                # SLURM
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                    
                # Logistics
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                flag_debug)
                    flag_debug="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                p_progress)
                    p_progress="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
            esac;
    esac
done

# ======================================================================== #
# |                          *** DEFINE COMMAND ***                      | #
# ======================================================================== #
# check if that's a singularity/slurm run
cmd=""
if [ ${flag_singularity} == "ON" ]; then
    if [ ${flag_slurm} == "ON" ]; then source ${p_src_code}src/helper/load_singularity.sh; fi
    export SINGULARITY_BINDPATH=${p_singularity_bindpath}
    cmd+="singularity exec ${p_singularity_img} "
elif [ ${flag_singularity} == "OFF" ]; then
    if [ ${flag_slurm} == "ON" ]; then
    source ${p_src_code}src/helper/load_modules.sh
    source activate np3
    ls -l ${CONDA_PREFIX}/bin >> /dev/null
    fi
fi

# continue defining command
cmd+="python3 ${p_src_code}src/combine_networks/code/get_list_reg_targets_from_networks.py \
    --l_in_path_net ${l_in_path_net} \
    --p_out_reg ${p_out_reg} \
    --p_out_target ${p_out_target}"

# run command
if [ ${flag_debug} == "ON" ]; then printf "***PYTHON CMD***\n${cmd}\n" >> ${p_progress}; fi
eval ${cmd}

if [ ${flag_singularity} == "OFF" ] && [ ${flag_slurm} == "ON" ]; then source deactivate np3; fi