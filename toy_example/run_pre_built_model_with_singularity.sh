#!/bin/bash

p_wd=/scratch/mblab/dabid/proj_net/
p_src_code=${p_wd}code/NetProphet_3.0/
p_out_dir=${p_wd}code/NetProphet_3.0/toy_example/res/

${p_src_code}np3 -c \
    --l_in_name_net "lasso,de,bart,pwm" \
    --l_in_path_net "${p_out_dir}features/net_lasso.tsv,${p_src_code}toy_example/data_zev_de_shrunken_50_500_indexed,${p_out_dir}features/net_bart.tsv,${p_out_dir}features/net_pwm.tsv" \
    --flag_training OFF \
    --p_in_model ${p_src_code}models/kem_ldbp.RData \
    --p_out_dir ${p_out_dir}pre_built_model/ \
    --flag_singularity ON \
    --p_singularity_img ${p_src_code}singularity/s_np3.sif \
    --p_singularity_bindpath ${p_src_code} \
    --flag_slurm ON \
    --p_out_dir_logs ${p_out_dir}log/ \
    --data toy_example_yeast_model \
