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
            in_model_name)
                in_model_name="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
            p_out_optimal_lambda)
                p_out_optimal_lambda="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_dir)
                p_out_dir="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
            nbr_job)
                nbr_job="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
                
            # logistic regression
            flag_intercept)
                flag_intercept="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
                
            # regularization
            flag_penalize)
                flag_penalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_dir_penalize)
                p_dir_penalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            penalize_nbr_fold)
                penalize_nbr_fold="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
        esac;;
    esac
done         

echo "p_in_binding_train ${p_in_binding_train}"
echo "l_in_path_net_train ${l_in_path_net_train}"
echo "l_in_path_net_test ${l_in_path_net_test}"
echo "l_in_name_net ${l_in_name_net}"
echo "in_model_name ${in_model_name}"
echo "p_out_pred_train ${p_out_pred_train}"
echo "p_out_pred_test ${p_out_pred_test}"
echo "p_out_model_summary ${p_out_model_summary}"
echo "p_out_model ${p_out_model}"
echo "p_out_optimal_lambda ${p_out_optimal_lambda}"
echo "p_src_code ${p_src_code}"
echo "flag_slurm ${flag_slurm}"
echo "flag_intercept ${flag_intercept}"
echo "flag_penalize ${flag_penalize}"
echo "p_dir_penalize ${p_dir_penalize}"
echo "penalize_nbr_fold ${penalize_nbr_fold}"
echo "flag_singularity ${flag_singularity}"
echo "p_singularity_img ${p_singularity_img}"
echo "p_singularity_bindpath ${p_singularity_bindpath}"

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
    if [ ${flag_slurm} == "ON" ]; then source ${p_src_code}src/helper/load_modules.sh; fi
fi

# continue defining command
cmd+="Rscript ${p_src_code}src/combine_networks/code/train_test.R \
             --p_in_binding_train ${p_in_binding_train} \
             --l_in_name_net ${l_in_name_net} \
             --l_in_path_net_train ${l_in_path_net_train} \
             --l_in_path_net_test ${l_in_path_net_test} \
             --in_model_name ${in_model_name} \
             --p_out_pred_train ${p_out_pred_train} \
             --p_out_pred_test ${p_out_pred_test} \
             --p_out_model_summary ${p_out_model_summary} \
             --p_out_model ${p_out_model} \
             --p_out_optimal_lambda ${p_out_optimal_lambda} \
             --p_src_code ${p_src_code} \
             --nbr_job ${nbr_job} \
             --flag_intercept ${flag_intercept} \
             --flag_penalize ${flag_penalize} \
             --p_dir_penalize ${p_dir_penalize} \
             --penalize_nbr_fold ${penalize_nbr_fold}"
             
# ======================================================== #
# |                  *** Run Command ***                 | #
# ======================================================== #
# run command
if [ ${flag_debug} == "ON" ]; then printf "***R CMD***\n${cmd}\n" >> ${p_progress}; fi
eval ${cmd}