#!/bin/bash

p_wd=/scratch/mblab/dabid/proj_net/
code_path=${p_wd}code/NetProphet_3.0_new/
p_out_dir=${p_wd}code/NetProphet_3.0_new/toy_example/res_s_np3/
p_singularity_img=${code_path}/singularity/s_np3
p_singularity_bindpath=${code_path}  # see below section for more info

${code_path}np3 -m \
    --p_in_binding_event ${code_path}toy_example/binding_reg_target.tsv \
    --flag_global_shrinkage ON \
    --l_in_name_net "lasso,bart" \
    --l_in_path_net "${p_out_dir}net_lasso.tsv,${p_out_dir}net_bart.tsv" \
    --p_in_expr_target ${code_path}toy_example/zev_expr_500_100_indexed \
    --p_in_expr_reg ${code_path}toy_example/zev_expr_reg_50_100_indexed \
    --p_in_promoter ${code_path}toy_example/promoter.scer.fasta \
    --p_in_net_bart ${p_out_dir}net_bart.tsv \
    --flag_training ON-INT \
    --p_out_dir ${p_out_dir} \
    --flag_singularity ON \
    --p_singularity_img ${p_singularity_img} \
    --p_singularity_bindpath ${p_singularity_bindpath} \
    --flag_slurm ON \
    --p_out_dir_logs ${p_out_dir}log/ \
    --data toy_example \
    --in_nbr_reg 1
