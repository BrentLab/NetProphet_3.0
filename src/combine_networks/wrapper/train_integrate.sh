#!/bin/bash

# ======================================================== #
# |                *** Parse Arguments ***               | #
# ======================================================== #
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
            p_in_binding)
                p_in_binding="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_in_path_net)
                l_in_path_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_in_name_net)
                l_in_name_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            in_nbr_reg)
                in_nbr_reg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            seed)
                seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            
            # Output
            p_out_pred)
                p_out_pred="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
            slurm_ntasks)
                slurm_ntasks="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
                
            # logistics
            p_src_code)
                p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            flag_debug)
                flag_debug="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_progress)
                p_progress="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
                
        esac;;
    esac
done

# echo "p_in_binding_train: ${p_in_binding_train}"
# echo "l_in_path_net_train: ${l_in_path_net_train}"
# echo "l_in_name_net: ${l_in_name_net}"
# echo "nbr_reg_train: ${nbr_reg_train}"
# echo "p_out_pred_train: ${p_out_pred_train}"
# echo "flag_singularity: ${flag_singularity}"
# echo "p_singularity_img: ${p_singularity_img}"
# echo "p_singlarity_bindpath: ${p_singularity_bindpath}"
# echo "flag_slurm: ${flag_slurm}"
# echo "slurm_ntasks: ${slurm_ntasks}"
# echo "p_src_code: ${p_src_code}"
# echo "flag_debug: ${flag_debug}"
# echo "p_progress: ${p_progress}"

# ======================================================== #
# |                 *** Define Command ***               | #
# ======================================================== #
# check if that's singularity/slurm run
cmd=""
if [ ${flag_singularity} == "ON" ]; then
    if [ ${flag_slurm} == "ON" ]; then source ${p_src_code}src/helper/load_singularity.sh; fi
    export SINGULARITY_BINDPATH=${p_singularity_bindpath}
    cmd+="singularity exec ${p_singularity_img} "
elif [ ${flag_singularity} == "OFF" ]; then
    if [ ${flag_slurm} == "ON" ]; then 
        source ${p_src_code}src/helper/load_modules.sh
        cmd+="mpirun -np 1 "
    fi
fi

# continue defining command
cmd+="Rscript ${p_src_code}src/combine_networks/code/train_integrate.R \
             --p_in_binding ${p_in_binding} \
             --l_in_name_net ${l_in_name_net} \
             --l_in_path_net ${l_in_path_net} \
             --in_nbr_reg ${in_nbr_reg} \
             --p_out_pred ${p_out_pred} \
             --seed ${seed} \
             --slurm_ntasks ${slurm_ntasks}"
             
# ======================================================== #
# |                  *** Run Command ***                 | #
# ======================================================== #
# # run command
if [ ${flag_debug} == "ON" ]; then printf "***R CMD***\n${cmd}\n" >> ${p_progress}; fi
eval ${cmd}