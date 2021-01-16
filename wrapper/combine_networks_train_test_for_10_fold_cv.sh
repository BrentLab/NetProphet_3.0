#!/bin/bash
# ##########################################################################
# | This module implements the 10-fold CV combination method             | #
# | It can support these source of information: LASSO, DE, BART, PWM     | #
# ##########################################################################

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
    h)
        usage
        exit 2
        ;;
    -)
        case "${OPTARG}" in
            p_net_lasso)
                p_net_lasso="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_de)
                p_net_de="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_bart)
                p_net_bart="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_pwm)
                p_net_pwm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_new)
                p_net_new="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_binding)
                p_net_binding="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            flag_slurm)
                flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_src_code)
                p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            model)
                model="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_dir)
                p_out_dir="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_np3)
                p_net_np3="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            seed)
                seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_logs)
                p_out_logs="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            flag_penalize)
                flag_penalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            flag_intercept)
                flag_intercept="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
        esac;;
    esac
done

# ======================================================================================================= #
# |                            *** SELECT 10-CV TRAINING/TESTING SETS ***                               | #
# ======================================================================================================= #

if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

mkdir -p ${p_out_dir}data_cv/
mkdir -p ${p_out_dir}data_pred/

echo "   - Select and write 10-fold cv in data_cv folder.."
source activate netprophet
if [ ${flag_slurm} == "ON" ]
then
    ls -l /home/dabid/.conda/envs/netprophet/bin >> ${p_out_logs}tmp.txt
fi

python ${p_src_code}code/combine_networks_select_write_training_testing_10_fold_cv.py \
  --l_net_name binding lasso de bart pwm new \
  --l_p_net ${p_net_binding} \
            ${p_net_lasso} \
            ${p_net_de} \
            ${p_net_bart} \
            ${p_net_pwm} \
            ${p_net_new} \
  --p_out_dir ${p_out_dir}data_cv/ \
  --seed ${seed} \
  --p_src_code ${p_src_code}

source deactivate netprophet
if [ ${flag_slurm} == "ON" ]
then
    ls -l /home/dabid/.conda/envs/netprophet/bin >> ${p_out_logs}tmp.txt
fi  

# ======================================================================================================= #
# |                                *** TRAIN/TEST FOR COMBINING NETWORKS ***                            | #
# ======================================================================================================= #  
echo "   - Train/Test for 10-fold CV.."
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
    
    # BART
    if [ ${p_net_bart} != "NONE" ]
    then
        p_net_bart_train=${p_out_dir}data_cv/fold${f}_train_bart.tsv
        p_net_bart_test=${p_out_dir}data_cv/fold${f}_test_bart.tsv
    else
        p_net_bart_train="NONE"
        p_net_bart_test="NONE"
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

    # NEW
    if [ ${p_net_new} != "NONE" ]
    then
        p_net_new_train=${p_out_dir}data_cv/fold${f}_train_new.tsv
        p_net_new_test=${p_out_dir}data_cv/fold${f}_test_new.tsv
    else
        p_net_new_train="NONE"
        p_net_new_test="NONE"
    fi
    
    ${p_src_code}wrapper/combine_networks_train_test.sh \
        --p_net_train_binding ${p_out_dir}data_cv/fold${f}_train_binding.tsv \
        --p_net_train_lasso ${p_net_lasso_train} \
        --p_net_train_de ${p_net_de_train} \
        --p_net_train_pwm ${p_net_pwm_train} \
        --p_net_train_new ${p_net_new_train} \
        --p_net_train_bart ${p_net_bart_train} \
        --p_net_test_lasso ${p_net_lasso_test} \
        --p_net_test_de ${p_net_de_test} \
        --p_net_test_bart ${p_net_bart_test} \
        --p_net_test_pwm ${p_net_pwm_test} \
        --p_net_test_new ${p_net_new_test} \
        --model ${model} \
        --p_out_pred_train ${p_out_dir}data_pred/fold${f}_pred_train.tsv \
        --p_out_optimal_lambda ${p_out_dir}data_pred/fold${f}_lambda.tsv \
        --p_tmp_penalize ${p_out_dir}tmp_penalize/fold${f}/ \
        --p_out_pred_test ${p_out_dir}data_pred/fold${f}_pred_test.tsv \
        --p_out_model_summary ${p_out_dir}data_pred/fold${f}_model_summary \
        --p_out_model ${p_out_dir}data_pred/fold${f}_model.RData \
        --flag_slurm ${flag_slurm} \
        --p_src_code ${p_src_code} \
        --seed ${seed} \
        --p_out_dir ${p_out_dir} \
        --flag_penalize ${flag_penalize} \
        --p_out_logs ${p_out_logs} \
        --flag_intercept ${flag_intercept} \
        --fold ${f}      
done

# ======================================================================================================= #
# |                              *** CONCATENATE THE 10 TESTING NETWORKS ***                            | #
# ======================================================================================================= #
if [ ${flag_slurm} == "ON" ]
then
    declare -a job_id_train_test_cv_array
    for f in {0..9}
    do
        while [ ! -f ${p_out_dir}job_ids/train_test${f}.txt ]
        do
            sleep 10
        done
        job_id_train_test_cv_array[${f}]=$(<${p_out_dir}job_ids/train_test${f}.txt)
    done
    
    job_concat_networks_cv=$(sbatch \
                        -o ${p_out_logs}concat_net_networks_10_fold_cv_%J.out \
                        -e ${p_out_logs}concat_net_networks_10_fold_cv_%J.err \
                        -J concat_net_10_cv \
                        --dependency=afterok:${job_id_train_test_cv_array[0]}:${job_id_train_test_cv_array[1]}:${job_id_train_test_cv_array[2]}:${job_id_train_test_cv_array[3]}:${job_id_train_test_cv_array[4]}:${job_id_train_test_cv_array[5]}:${job_id_train_test_cv_array[6]}:${job_id_train_test_cv_array[7]}:${job_id_train_test_cv_array[8]}:${job_id_train_test_cv_array[9]} \
                        ${p_src_code}wrapper/combine_networks_concatenate_networks.sh \
                            --p_in_dir_data ${p_out_dir}data_cv/ \
                            --p_in_dir_pred ${p_out_dir}data_pred/ \
                            --p_net_np3 ${p_net_np3} \
                            --flag_concat "concat_cv" \
                            --flag_slurm ${flag_slurm} \
                            --p_src_code ${p_src_code})
                            
    job_id_concat_networks_cv=$(echo ${job_concat_networks_cv} | awk '{split($0, a, " "); print a[4]}')
    echo "   - submit job ${job_id_concat_networks_cv}: concatenate networks for 10-fold of cv.."
    mkdir -p ${p_out_dir}job_ids/
    echo "${job_id_concat_networks_cv}" > ${p_out_dir}job_ids/concat_cv.txt
else
    echo "   - concatenate networks of 10-fold CV.."
    source activate netprophet
    
    python ${p_src_code}code/combine_networks_concat_networks.py \
        --p_in_dir_data ${p_out_dir}data_cv/ \
        --p_in_dir_pred ${p_out_dir}data_pred/ \
        --p_out_file ${p_net_np3}
    source deactivate netprophet
fi