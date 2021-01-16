#!/bin/bash

p_in_net=${1}
p_reg=${2}
p_target=${3}
p_out_net=${4}
flag_slurm=${5}
p_src_code=${6}

if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

source activate netprophet
ls -la /home/dabid/.conda/envs/netprophet/bin > /dev/null

python ${p_src_code}code/helper_unmelt_net.py \
    --p_in_net ${p_in_net} \
    --p_in_reg ${p_reg} \
    --p_in_target ${p_target} \
    --p_out_net ${p_out_net}
source deactivate netprophet
