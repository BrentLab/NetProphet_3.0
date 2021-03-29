#!/bin/bash

# =========================================================================== #
# |                         **** PARSE ARGUMENTS ****                       | #
# =========================================================================== #
p_in_expr_target=${1}
p_in_expr_reg=${2}
flag_global_shrinkage=${3}
flag_local_shrinkage=${4}
p_out_dir=${5}
fname_lasso=${6}
flag_debug=${7}
flag_slurm=${8}
seed=${9}
nbr_cv_fold=${10}
flag_microarray=${11}
p_src_code=${12}
flag_singularity=${13}
p_singularity_img=${14}
p_singularity_bindpath=${15}
p_progress=${16}


# =========================================================================== #
# |                           *** BUILD LASSO ***                           | #
# =========================================================================== #

echo "build LASSO network..."
# define the command
cmd=""
if [ ${flag_singularity} == "ON" ]; then
    if [ ${flag_slurm} == "ON" ]; then 
        source ${p_src_code}src/helper/load_singularity.sh
        cmd+="mpirun -np ${SLURM_NTASKS} "
    fi
    export SINGULARITY_BINDPATH=${p_singularity_bindpath}
    cmd+="singularity exec ${p_singularity_img} "
elif [ ${flag_singularity} == "OFF" ]; then
    if [ ${flag_slurm} == "ON" ]; then 
    source ${p_src_code}src/helper/load_modules.sh
    cmd+="mpirun -np ${SLURM_NTASKS} "
    fi
fi

cmd+="Rscript --no-save ${p_src_code}src/build_lasso/code/build_net_lasso.R \
      --p_in_expr_target ${p_in_expr_target} \
      --p_in_expr_reg ${p_in_expr_reg} \
      --flag_global_shrinkage ${flag_global_shrinkage} \
      --flag_local_shrinkage ${flag_local_shrinkage} \
      --p_out_dir ${p_out_dir} \
      --fname_lasso ${fname_lasso} \
      --flag_parallel ${flag_slurm} \
      --seed ${seed} \
      --nbr_cv_fold ${nbr_cv_fold} \
      --flag_microarray ${flag_microarray} \
      --p_src_code ${p_src_code}"

# run the command
if [ ${flag_debug} == "ON" ]; then printf "*** CMD R ***\n${cmd}\n"; fi
eval ${cmd}      