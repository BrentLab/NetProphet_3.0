#!/bin/bash

#SBATCH -J bootstrap_training
#SBATCH -o bootstrap_training.out
#SBATCH -e bootstrap_training.err

p_wd=/scratch/mblab/dabid/netprophet/

./bootstrap_training.sh \
        --p_in_dir ${p_wd}net_out/yeast/both_with_without_perturbed_tfs/claim2/res_kem_ldbp_atomic_10cv_tf313_target6112/ \
    --flag_training "ON-CV" \
    --nbr_bootstrap 3 \
    --nbr_cv_fold 10 \
    --flag_singularity "OFF" \
    --flag_slurm "ON" \
    --p_src_code ${p_wd}NetProphet_3.0/
    
