#!/bin/bash

p_wd=/scratch/mblab/dabid/proj_net/
p_src_code=${p_wd}code/NetProphet_3.0/
p_out_dir=${p_wd}code/NetProphet_3.0/toy_example/res/features/

${p_src_code}np3 -l \
    --flag_global_shrinkage ON \
    --p_in_expr_target ${p_src_code}toy_example/data_zev_expr_500_100_indexed \
    --p_in_expr_reg ${p_src_code}toy_example/data_zev_expr_reg_50_100_indexed \
    --p_out_dir ${p_out_dir} \
    --flag_singularity ON \
    --p_singularity_img ${p_src_code}singularity/s_np3.sif \
    --p_singularity_bindpath ${p_src_code} \
    --flag_slurm ON \
    --p_out_dir_logs ${p_out_dir}log/ \
    --data toy_example
