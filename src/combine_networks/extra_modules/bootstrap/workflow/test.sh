#!/bin/bash

p_wd=/scratch/mblab/dabid/netprophet/
p_in_dir=${p_wd}net_out/yeast/both_with_without_perturbed_tfs/claim2/res_kem_ldbp_atomic_10cv_tf313_target6112/
in_model_name=atomic
l_in_name_net="lasso,de,bart,pwm"
nbr_bootstrap=2
nbr_cv_fold=10
flag_training="ON-CV"
p_src_code=${p_wd}NetProphet_3.0/
flag_singularity=OFF
p_singularity_img=NONE
p_singularity_bindpath=NONE
flag_slurm=ON
p_out_dir_logs=${p_wd}net_logs/yeast/both_with_without_perturbed_tfs/claim2/kem_ldbp_atomic_10cv_tf313_target6112/bootstrap/
data=test
bootstrap_slurm_nodes=11

mkdir -p ${p_out_dir_logs}

${p_src_code}src/combine_networks/extra_modules/bootstrap/workflow/train_test_for_bootstrap.sh \
    --p_in_dir ${p_in_dir} \
    --in_model_name ${in_model_name} \
    --l_in_name_net ${l_in_name_net} \
    --nbr_bootstrap ${nbr_bootstrap} \
    --nbr_cv_fold ${nbr_cv_fold} \
    --flag_training ${flag_training} \
    --p_src_code ${p_src_code} \
    --flag_singularity ${flag_singularity} \
    --p_singularity_img ${p_singularity_img} \
    --p_singularity_bindpath ${p_singularity_bindpath} \
    --flag_slurm ${flag_slurm} \
    --p_out_dir_logs ${p_out_dir_logs} \
    --data ${data} \
    --bootstrap_slurm_nodes ${bootstrap_slurm_nodes}
    