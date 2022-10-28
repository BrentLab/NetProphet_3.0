#!/bin/bash

p_wd=/scratch/mblab/dabid/proj_net/
p_src_code=${p_wd}code/NetProphet_3.0/
p_out_dir=${p_wd}code/NetProphet_3.0/toy_example/res/features/
p_singularity_img=${p_src_code}/singularity/s_np3.sif
p_singularity_bindpath=${p_src_code}

${p_src_code}np3 -m \
    --p_in_promoter ${p_src_code}toy_example/data_promoter.scer.fasta \
    --p_in_net_bart ${p_out_dir}net_bart.tsv \
    --p_out_dir ${p_out_dir} \
    --flag_singularity ON \
    --p_singularity_img ${p_singularity_img} \
    --p_singularity_bindpath ${p_singularity_bindpath} \
    --flag_slurm ON \
    --p_out_dir_logs ${p_out_dir}log/ \
    --data toy_example
