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
            p_in_binding_train)
                p_in_binding_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_in_path_net_train)
                l_in_path_net_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_in_path_net_test)
                l_in_path_net_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_in_name_net)
                l_in_name_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            
            # Output
            p_out_pred_train)
                p_out_pred_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_pred_test)
                p_out_pred_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_model_summary)
                p_out_model_summary="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_model)
                p_out_model="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            flag_penalize)
                flag_penalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
#             p_out_dir)
#                 p_out_dir="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
#                 ;;
                
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
    fi
fi

# continue defining command
cmd+="Rscript ${p_src_code}src/combine_networks/code/train_test.R \
             --p_in_binding_train ${p_in_binding_train} \
             --l_in_name_net ${l_in_name_net} \
             --l_in_path_net_train ${l_in_path_net_train} \
             --l_in_path_net_test ${l_in_path_net_test} \
             --p_out_pred_train ${p_out_pred_train} \
             --p_out_pred_test ${p_out_pred_test} \
             --p_out_model_summary ${p_out_model_summary} \
             --p_out_model ${p_out_model} \
             --p_src_code ${p_src_code} \
             --flag_penalize ${flag_penalize}"
             
# ======================================================== #
# |                  *** Run Command ***                 | #
# ======================================================== #
# run command
if [ ${flag_debug} == "ON" ]; then printf "***R CMD***\n${cmd}\n" >> ${p_progress}; fi
eval ${cmd}