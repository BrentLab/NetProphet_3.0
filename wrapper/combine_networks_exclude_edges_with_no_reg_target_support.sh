#!/bin/bash

p_binding_event=${1}
p_net_lasso=${2}
p_net_bart=${3}
p_net_de=${4}
p_net_motif=${5}
p_net_binding=${6}
p_target=${7}
p_reg=${8}
p_out_dir=${9}
flag_slurm=${10}
p_src_code=${11}

if (( ${flag_slurm} == "ON" ))
then
  source ${p_src_code}wrapper/load_modules.sh
fi

source activate netprophet
ls -la /home/dabid/.conda/envs/netprophet/bin

python ${p_src_code}code/exclude_edges_with_no_reg_target_support.py \
  --p_binding_event ${p_binding_event} \
  --l_net_name binding lasso bart de pwm \
  --l_p_net ${p_net_binding} ${p_net_lasso} ${p_net_bart} ${p_net_de} ${p_net_motif} \
  --p_target ${p_target} \
  --p_reg ${p_reg} \
  --p_out_dir ${p_out_dir}

source deactivate netprophet
