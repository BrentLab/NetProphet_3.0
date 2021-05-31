#!/bin/bash

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                # Input
                p_in_expr_target)
                    p_in_expr_target="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                p_in_expr_reg)
                    p_in_expr_reg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                flag_lasso_ridge)
                    flag_lasso_ridge="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                nbr_rmpi_slave)
                    nbr_rmpi_slave="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                
                # Input for optimization
                nbr_lambda)
                    nbr_lambda="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                nbr_target_optimize)
                    nbr_target_optimize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                nbr_fold)
                    nbr_fold="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                
                # Output
                p_out_dir)
                    p_out_dir="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                f_out_name)
                    f_out_name="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                
                # Logistics
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                seed)
                    seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                
                # slurm
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                
                # singularity
                flag_singularity)
                    flag_singularity="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                p_singularity_img)
                    p_singularity_img="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                p_singularity_bindpath)
                    p_singularity_bindpath="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                
                # debug
                p_progress)
                    p_progress="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                flag_debug)
                    flag_debug="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
            esac;;
    esac
done

echo "p_in_expr_target ${p_in_expr_target}"
echo "p_in_expr_reg ${p_in_expr_reg}"
echo "flag_lasso_ridge ${flag_lasso_ridge}"
echo "nbr_target_optimize ${nbr_target_optimize}"
echo "nbr_fold ${nbr_fold}"
echo "nbr_lambda ${nbr_lambda}"
echo "nbr_rmpi_slave ${nbr_rmpi_slave}"
echo "seed ${seed}"
echo "p_src_code ${p_src_code}"
echo "flag_slurm ${flag_slurm}"
echo "flag_singularity ${flag_singularity}"
echo "p_singularity_img ${p_singularity_img}"
echo "p_singularity_bindpath ${p_singularity_bindpath}"
echo "p_out_dir ${p_out_dir}"
echo "f_out_name ${f_out_name}"
    
    
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
    fi
fi

cmd+="Rscript ${p_src_code}src/build_lasso_ridge/code/build_lasso_ridge.R \
              --p_in_expr_target ${p_in_expr_target} \
              --p_in_expr_reg ${p_in_expr_reg} \
              --flag_lasso_ridge ${flag_lasso_ridge} \
              --nbr_lambda ${nbr_lambda} \
              --nbr_fold ${nbr_fold} \
              --nbr_target_optimize ${nbr_target_optimize} \
              --nbr_rmpi_slave ${nbr_rmpi_slave} \
              --seed ${seed} \
              --p_src_code ${p_src_code} \
              --p_out_dir ${p_out_dir} \
              --f_out_name ${f_out_name}"
              
# if [ ${flag_debug} == "ON" ]; then printf "***R CMD***\n${cmd}\n" >> ${p_progress}; fi
echo "${cmd}"
eval ${cmd}
