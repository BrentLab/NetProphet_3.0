#!/bin/bash

p_wd=/scratch/mblab/dabid/proj_net/
p_src_code=${p_wd}code/NetProphet_3.0/
p_out_dir=${p_wd}code/NetProphet_3.0/toy_example/res/

${p_src_code}np3 -c \
    --p_in_binding_event ${p_src_code}toy_example/data_binding_reg_target.tsv \
    --l_in_name_net "lasso,de,bart,pwm" \
    --l_in_path_net "${p_out_dir}features/net_lasso.tsv,${p_src_code}toy_example/data_zev_de_shrunken_50_500_indexed,${p_out_dir}features/net_bart.tsv,${p_out_dir}features/net_pwm.tsv" \
    --flag_training ON-CV \
    --combine_cv_nbr_fold 10 \
    --p_out_dir ${p_out_dir}10cv_new/ \
    --flag_singularity OFF \
    --flag_slurm ON \
    --p_out_dir_logs ${p_out_dir}log/ \
    --data toy_example_10cv \
