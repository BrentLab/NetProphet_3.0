#!/bin/bash

# =========================================================================== #
# |                         **** PARSE ARGUMENTS ****                       | #
# =========================================================================== #
p_in_expr_target=${1}
p_in_expr_reg=${2}
p_out_dir=${3}
fname_bart=${4}
bart_ntree=${5}
flag_slurm=${6}
p_src_code=${7}
flag_singularity=${8}
p_singularity_img=${9}
p_singularity_bindpath=${10}
nbr_rmpi_slave=${11}

# =========================================================================== #
# |                        **** BUILD BART ****                             | #
# =========================================================================== #
echo "build BART network.."
cmd=""
if [ ${flag_singularity} == "ON" ]; then
    if [ ${flag_slurm} == "ON" ]; then source ${p_src_code}src/helper/load_singularity.sh; fi
    export SINGULARITY_BINDPATH=${p_singularity_bindpath}
    cmd+="singularity exec ${p_singularity_img} "
elif [ ${flag_singularity} == "OFF" ]; then
    if [ ${flag_slurm} == "ON" ]; then source ${p_src_code}src/helper/load_modules.sh; fi
fi

cmd+="Rscript --no-save --vanilla ${p_src_code}src/build_bart/code/build_net_bart.R \
     --p_in_expr_target ${p_in_expr_target} \
     --p_in_expr_reg ${p_in_expr_reg} \
     --fname_bart ${fname_bart} \
     --ntree ${bart_ntree} \
     --p_out_dir ${p_out_dir} \
     --flag_slurm ${flag_slurm} \
     --p_src_code ${p_src_code} \
     --nbr_rmpi_slave ${nbr_rmpi_slave}"

echo "${cmd}"
eval ${cmd}     