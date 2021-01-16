#!/bin/bash

p_out_dir=${1}
p_net_lasso=${2}
p_net_bart=${3}
p_net_de=${4}
p_net_pwm=${5}
p_net_binding=${6}
model=${7}
p_src_code=${8}
p_net_np3=${9}
flag_slurm=${10}
seed=${11}
p_in_reg=${12}
p_in_target=${13}
flag_matrix=${14}

# ======================================================================================================= #
# |                            *** SELECT 10-CV TRAINING/TESTING SETS ***                               | #
# ======================================================================================================= #

mkdir -p ${p_out_dir}data_cv/
mkdir -p ${p_out_dir}data_pred/


echo "            - select 10-fold cv.."
source activate netprophet
ls -la /home/dabid/.conda/envs/netprophet/bin

python ${p_src_code}code/combine_networks_select_write_training_testing_10_fold_cv.py \
  --l_net_name binding lasso de bart pwm \
  --l_p_net ${p_net_binding} \
            ${p_net_lasso} \
            ${p_net_de} \
            ${p_net_bart} \
            ${p_net_pwm} \
  --p_out_dir ${p_out_dir}data_cv/ \
  --seed ${seed} \
  --p_reg ${p_in_reg} \
  --p_target ${p_in_target} \
  --p_src_code ${p_src_code}
  
source deactivate netprophet
  

# ======================================================================================================= #
# |                                *** TRAIN/TEST FOR COMBINING NETWORKS ***                            | #
# ======================================================================================================= #  
echo "            - train/test.."

for f in {0..9}
do
    # LASSO
    if [ ${p_net_lasso} != "NONE" ]
    then
        p_net_lasso_train=${p_out_dir}data_cv/fold${f}_train_lasso.tsv
        p_net_lasso_test=${p_out_dir}data_cv/fold${f}_test_lasso.tsv
    else
        p_net_lasso_train="NONE"
        p_net_lasso_test="NONE"
    fi
    # DE
    if [ ${p_net_de} != "NONE" ]
    then
        p_net_de_train=${p_out_dir}data_cv/fold${f}_train_de.tsv
        p_net_de_test=${p_out_dir}data_cv/fold${f}_test_de.tsv
    else
        p_net_de_train="NONE"
        p_net_de_test="NONE"
    fi
    # PWM
    if [ ${p_net_pwm} != "NONE" ]
    then
        p_net_pwm_train=${p_out_dir}data_cv/fold${f}_train_pwm.tsv
        p_net_pwm_test=${p_out_dir}data_cv/fold${f}_test_pwm.tsv
    else
        p_net_pwm_train="NONE"
        p_net_pwm_test="NONE"
    fi
    # BART
    if [ ${p_net_bart} != "NONE" ]
    then
        p_net_bart_train=${p_out_dir}data_cv/fold${f}_train_bart.tsv
        p_net_bart_test=${p_out_dir}data_cv/fold${f}_test_bart.tsv
    else
        p_net_bart_train="NONE"
        p_net_bart_test="NONE"
    fi
  
    Rscript ${p_src_code}code/combine_networks_train_test.R \
        --p_in_train_binding ${p_out_dir}data_cv/fold${f}_train_binding.tsv \
        --p_in_train_lasso ${p_net_lasso_train} \
        --p_in_train_de ${p_net_de_train} \
        --p_in_train_pwm ${p_net_pwm_train} \
        --p_in_train_bart ${p_net_bart_train} \
        --p_in_test_lasso ${p_net_lasso_test} \
        --p_in_test_de ${p_net_de_test} \
        --p_in_test_bart ${p_net_bart_test} \
        --p_in_test_pwm ${p_net_pwm_test} \
        --in_model ${model} \
        --p_out_pred_train ${p_out_dir}data_pred/fold${f}_pred_train.tsv \
        --p_out_pred_test ${p_out_dir}data_pred/fold${f}_pred_test.tsv \
        --p_out_model_summary ${p_out_dir}data_pred/fold${f}_model_summary
done


# ======================================================================================================= #
# |                              *** CONCATENATE THE 10 TESTING NETWORKS ***                            | #
# ======================================================================================================= #
echo "            - concatenate networks.."

source activate netprophet
ls -la /home/dabid/.conda/envs/netprophet/bin
python ${p_src_code}code/combine_networks_concat_networks.py \
--p_in_dir_data ${p_out_dir}data_cv/ \
--p_in_dir_pred ${p_out_dir}data_pred/ \
--p_out_file ${p_net_np3} \
--flag_matrix ${flag_matrix} \
--p_in_reg ${p_in_reg} \
--p_in_target ${p_in_target}
source deactivate netprophet