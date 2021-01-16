#!/bin/bash

echo "generate lasso network..."

# ======================================================================================================= #
# |                                       **** PARSE ARGUMENTS ****                                     | #
# ======================================================================================================= #
p_in_expr_target=${1}
p_in_expr_reg=${2}
flag_global_shrinkage=${3}
flag_local_shrinkage=${4}
p_out_dir=${5}
fname_lasso=${6}
flag_debug=${7}
flag_parallel=${8}
seed=${9}
nbr_cv_fold=${10}
flag_microarray=${11}
p_src_code=${12}

# ======================================================================================================= #
# |                                   *** GENERATE LASSO NETWORK ***                                    | #
# ======================================================================================================= #

if [ ${flag_parallel} == "ON" ]
then
  source ${p_src_code}wrapper/helper_load_modules.sh
  
  mpirun -np ${SLURM_NTASKS} Rscript --no-save ${p_src_code}code/build_net_lasso.R \
    --p_in_expr_target ${p_in_expr_target} \
    --p_in_expr_reg ${p_in_expr_reg} \
    --flag_global_shrinkage ${flag_global_shrinkage} \
    --flag_local_shrinkage ${flag_local_shrinkage} \
    --p_out_dir ${p_out_dir} \
    --fname_lasso ${fname_lasso} \
    --flag_debug ${flag_debug} \
    --flag_parallel ${flag_parallel} \
    --seed ${seed} \
    --nbr_cv_fold ${nbr_cv_fold} \
    --flag_microarray ${flag_microarray} \
    --p_src_code ${p_src_code}
  
elif [ ${flag_parallel} == "OFF" ]
then
  Rscript --no-save \
  ${p_src_code}code/build_net_lasso.R \
  --p_in_expr_target ${p_in_expr_target} \
  --p_in_expr_reg ${p_in_expr_reg} \
  --flag_global_shrinkage ${flag_global_shrinkage} \
  --flag_local_shrinkage ${flag_local_shrinkage} \
  --p_out_dir ${p_out_dir} \
  --fname_lasso ${fname_lasso} \
  --flag_debug ${flag_debug} \
  --flag_parallel ${flag_parallel} \
  --seed ${seed} \
  --nbr_cv_fold ${nbr_cv_fold} \
  --flag_microarray ${flag_microarray}  \
  --p_src_code ${p_src_code}
fi

# ======================================================================================================= #
# |                                 *** END GENERATE LASSO NETWORK ***                                  | #
# ======================================================================================================= #
