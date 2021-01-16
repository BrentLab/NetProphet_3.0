#!/bin/bash

p_in_pos_event=${1}
p_in_reg=${2}
p_in_target=${3}
p_out_net=${4}
flag_slurm=${5}
p_src_code=${6}


if (( ${flag_slurm} == "ON" ))
then
  source ${p_src_code}wrapper/helper_load_modules.sh
fi

source activate netprophet
# ls -l /home/dabid/.conda/envs/netprophet/bin 

python ${p_src_code}code/create_binding_network.py \
  --p_in_pos_event ${p_in_pos_event} \
  --p_in_reg ${p_in_reg} \
  --p_in_target ${p_in_target} \
  --p_out_net ${p_out_net}
source deactivate netprophet