#!/bin/bash


while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        h)
            echo "usage"
            exit 2
            ;;
        -)
            case "${OPTARG}" in
                # Input
                p_in_expr_target)
                    p_in_expr_target="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    ;;
                p_in_expr_reg)
                    p_in_expr_reg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                
                # Regression/Optimization
                flag_optimize)
                    flag_optimize="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                nbr_target_optimize)
                    nbr_target_optimize="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                nbr_fold)
                    nbr_fold="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                model_name)
                    model_name="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                df_model_param)
                    df_model_param="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                df_model_param_optimal)
                    df_model_param_optimal="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                    
                # Logistics
                seed)
                    seed="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                    
                # Slurm
                nbr_tasks)
                    nbr_tasks="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
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
                    
                # Output
                p_out_dir)
                    p_out_dir="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                f_out_name)
                    f_out_name="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
            esac;;
    esac
done

echo "build optimized network ${model_name}"
cmd=""
if [ ${flag_singularity} == "ON" ]; then
    if [ ${flag_slurm} == "ON" ]; then source ${p_src_code}src/helper/load_singularity.sh; fi
    export SINGULARITY_BINDPATH=${p_singularity_bindpath}
    cmd+="singularity exec ${p_singularity_img} "
elif [ ${flag_singularity} == "OFF" ]; then
    if [ ${flag_slurm} == "ON" ]; then source ${p_src_code}src/helper/load_modules.sh; fi
fi

echo "${df_model_param}"

cmd+="Rscript --no-save --vanilla ${p_src_code}src/build_optimized_net/code/build_optimized_net.R \
     --p_in_expr_target ${p_in_expr_target} \
     --p_in_expr_reg ${p_in_expr_reg} \
     --flag_optimize ${flag_optimize} \
     --nbr_target_optimize ${nbr_target_optimize} \
     --nbr_fold ${nbr_fold} \
     --model_name ${model_name} \
     --df_model_param '${df_model_param}' \
     --df_model_param_optimal '${df_model_param_optimal}' \
     --nbr_rmpi_slaves ${nbr_tasks} \
     --seed ${seed} \
     --p_out_dir ${p_out_dir} \
     --f_out_name ${f_out_name} \
     --p_src_code ${p_src_code}"

eval ${cmd}