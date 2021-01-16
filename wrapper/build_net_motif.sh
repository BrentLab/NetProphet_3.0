#!/bin/bash

module load anaconda3/4.1.1

p_motif=${1}
p_in_reg=${2}
p_in_target=${3}
p_motifs_score=${4}
t=${5}
v=${6}
p_mn=${7}  # output file
p_src_code=${8}
flag_slurm=${9}

if [[ ${flag_slurm} == "ON" ]]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

source activate netprophet
python ${p_src_code}code/netprophet2/build_motif_network.py \
-i ${p_motif} \
-r ${p_in_reg} \
-g ${p_in_target} \
-f ${p_motifs_score} \
-t ${t} \
-v ${v} \
-o ${p_mn}

# index the network
python ${p_src_code}code/helper_reindex_network.py \
--p_in_net ${p_mn} \
--p_in_reg ${p_in_reg} \
--p_in_target ${p_in_target} \
--p_out_net ${p_mn}

source deactivate netprophet