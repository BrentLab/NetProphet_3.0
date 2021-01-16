#!/bin/bash

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
    h)
        usage
        exit 2
        ;;
    -)
        case "${OPTARG}" in
            p_net_binding_train)
                p_net_binding_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_lasso_train)
                p_net_lasso_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_de_train)
                p_net_de_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_bart_train)
                p_net_bart_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_pwm_train)
                p_net_pwm_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_new_train)
                p_net_new_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_lasso_test)
                p_net_lasso_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_de_test)
                p_net_de_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_bart_test)
                p_net_bart_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_pwm_test)
                p_net_pwm_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_net_new_test)
                p_net_new_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_model)
                p_out_model="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_pred_train)
                p_out_pred_train="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_pred_test)
                p_out_pred_test="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_optimal_lambda)
                p_out_optimal_lambda="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_src_code)
                p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            seed)
                seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            model)
                model="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_logs)
                p_out_logs="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_tmp_penalize)
                p_tmp_penalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_out_dir)
                p_out_dir="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            fold)
                fold="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            flag_penalize)
                flag_penalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
        esac;;
    esac
done

mkdir -p ${p_tmp_penalize}data_cv/
mkdir -p ${p_tmp_penalize}data_pred/
mkdir -p ${p_out_logs}
# ======================================================================= #
# |        *** Train & Write model with all Training data ***           | #
# |                   *** To get list Lambdas ***                       | # 
# ======================================================================= #
job_train_and_write_model_with_all_training=$(sbatch \
                  -o ${p_out_logs}step1_train_and_write_model_with_all_training_%J.out \
                  -e ${p_out_logs}step1_train_and_write_model_with_all_training_%J.err \
                  -J train_model_all \
                  --mem-per-cpu 10G \
                  ${p_src_code}wrapper/combine_networks_train_test_penalize_b.sh \
                      --p_net_binding_train ${p_net_binding_train} \
                      --p_net_lasso_train ${p_net_lasso_train} \
                      --p_net_de_train ${p_net_de_train} \
                      --p_net_bart_train ${p_net_bart_train} \
                      --p_net_pwm_train ${p_net_pwm_train} \
                      --p_net_new_train ${p_net_new_train} \
                      --model ${model} \
                      --p_out_model ${p_out_model} \
                      --flag_step "train_and_write_model_with_all_training" \
                      --p_src_code ${p_src_code} \
                      --flag_penalize ${flag_penalize})
job_id_train_and_write_model_with_all_training=$(echo ${job_train_and_write_model_with_all_training} | awk '{split($0, a, " "); print a[4]}')
echo "- submit job ${job_id_train_and_write_model_with_all_training}: train and write model for all training data to get list of lambdas.."


# ======================================================================= #
# |       *** Select & Write Training/Test data for 10-fold cv ***      | #
# ======================================================================= #
echo "- Select and Write Training/Test for 10-fold cv in data_cv.."

job_select_write_10_fold_cv=$(sbatch \
                              -o ${p_out_logs}step2_select_write_10_fold_cv_%J.out \
                              -e ${p_out_logs}step2_select_write_10_fold_cv_%J.err \
                              -J select_write_10_fold_cv \
                              ${p_src_code}wrapper/combine_networks_select_write_training_testing_10_fold_cv.sh \
                                  --p_net_binding ${p_net_binding_train} \
                                  --p_net_lasso ${p_net_lasso_train} \
                                  --p_net_de ${p_net_de_train} \
                                  --p_net_bart ${p_net_bart_train} \
                                  --p_net_pwm ${p_net_pwm_train} \
                                  --p_net_new ${p_net_new_train} \
                                  --p_out_dir ${p_tmp_penalize}/data_cv/ \
                                  --seed ${seed} \
                                  --p_src_code ${p_src_code})
job_id_select_write_10_fold_cv=$(echo ${job_select_write_10_fold_cv} | awk '{split($0, a, " "); print a[4]}')
echo "- submit array job ${job_id_select_write_10_fold_cv}: Select and Write 10-fold CV of Training/Testing.."                     

# ======================================================================= #
# |          *** Train & Write 10-fold CV of Training/Testing ***       | #
# ======================================================================= #
job_train_and_write_model_with_fold_training=$(sbatch \
                  -o ${p_out_logs}step3_train_and_write_model_with_fold_training_%A_%a.out \
                  -e ${p_out_logs}step3_train_and_write_model_with_fold_training_%A_%a.err \
                  -J train_model_1_fold \
                  --array=0-9 \
                  --mem-per-cpu 10G \
                  --dependency=afterok:${job_id_select_write_10_fold_cv} \
                  ${p_src_code}wrapper/combine_networks_train_test_penalize_b.sh \
                      --p_net_binding_train ${p_net_binding_train} \
                      --p_net_lasso_train ${p_net_lasso_train} \
                      --p_net_de_train ${p_net_de_train} \
                      --p_net_bart_train ${p_net_bart_train} \
                      --p_net_pwm_train ${p_net_pwm_train} \
                      --p_net_new_train ${p_net_new_train} \
                      --p_tmp_penalize ${p_tmp_penalize} \
                      --model ${model} \
                      --p_src_code ${p_src_code} \
                      --flag_step "train_and_write_model_with_fold_training" \
                      --flag_penalize ${flag_penalize})
                      
job_id_train_and_write_model_with_fold_training=$(echo ${job_train_and_write_model_with_fold_training} | awk '{split($0, a, " "); print a[4]}')
echo "- submit array job ${job_id_train_and_write_model_with_fold_training}: Train & Write 10-fold CV of Training/Testing.."


# ======================================================================= #
# |                *** Test & Write sum log likelihood ***              | #
# ======================================================================= #
job_test_and_write_sum_log_likelihood=$(sbatch \
                          -o ${p_out_logs}step4_test_and_write_sum_log_likelihood_%A_%a.out \
                          -e ${p_out_logs}step4_test_and_write_sum_log_likelihood_%A_%a.err \
                          -J sum_log_likelihood \
                          --mem-per-cpu 10G \
                          --array=0-9 \
                          --dependency=afterok:${job_id_train_and_write_model_with_fold_training}:${job_id_train_and_write_model_with_all_training} \
                          ${p_src_code}wrapper/combine_networks_train_test_penalize_b.sh \
                              --p_net_binding_train ${p_net_binding_train} \
                              --p_net_lasso_train ${p_net_lasso_train} \
                              --p_net_de_train ${p_net_de_train} \
                              --p_net_bart_train ${p_net_bart_train} \
                              --p_net_pwm_train ${p_net_pwm_train} \
                              --p_net_new_train ${p_net_new_train} \
                              --model ${model} \
                              --p_out_model ${p_out_model} \
                              --p_tmp_penalize ${p_tmp_penalize} \
                              --p_src_code ${p_src_code} \
                              --flag_step "test_and_write_sum_log_likelihood")
job_id_test_and_write_sum_log_likelihood=$(echo ${job_test_and_write_sum_log_likelihood} | awk '{split($0, a, " "); print a[4]}')
echo "- submit array job ${job_id_test_and_write_sum_log_likelihood}: Test and write sum of log likelihood.."

# ======================================================================= #
# |               *** Select Optimal Lambda and predict ***             | #
# ======================================================================= #

job_select_optimal_lambda_and_predict=$(sbatch \
                                   -o ${p_out_logs}step5_select_optimal_lambda_and_predict_%J.out \
                                   -e ${p_out_logs}step5_select_optimal_lambda_and_predict_%J.err \
                                   -J select_optimal_lambda \
                                   --dependency=afterok:${job_id_test_and_write_sum_log_likelihood} \
                                   --mem-per-cpu 10G \
                                   ${p_src_code}wrapper/combine_networks_train_test_penalize_b.sh \
                                       --p_net_binding_train ${p_net_binding_train} \
                                       --p_net_lasso_train ${p_net_lasso_train} \
                                       --p_net_de_train ${p_net_de_train} \
                                       --p_net_bart_train ${p_net_bart_train} \
                                       --p_net_pwm_train ${p_net_pwm_train} \
                                       --p_net_new_train ${p_net_new_train} \
                                       --p_net_lasso_test ${p_net_lasso_test} \
                                       --p_net_de_test ${p_net_de_test} \
                                       --p_net_bart_test ${p_net_bart_test} \
                                       --p_net_pwm_test ${p_net_pwm_test} \
                                       --p_net_new_test ${p_net_new_test} \
                                       --model ${model} \
                                       --p_out_model ${p_out_model} \
                                       --flag_step "select_optimal_lambda_and_predict" \
                                       --p_tmp_penalize ${p_tmp_penalize} \
                                       --p_src_code ${p_src_code} \
                                       --p_out_pred_train ${p_out_pred_train} \
                                       --p_out_pred_test ${p_out_pred_test} \
                                       --p_out_optimal_lambda ${p_out_optimal_lambda})
                                       
job_id_select_optimal_lambda_and_predict=$(echo ${job_select_optimal_lambda_and_predict} | awk '{split($0, a, " "); print a[4]}')
echo "- submit job ${job_id_select_optimal_lambda_and_predict}: Select optimal Lambda and predict.."
mkdir -p ${p_out_dir}job_ids/
echo "${job_id_select_optimal_lambda_and_predict}" > ${p_out_dir}job_ids/train_test${fold}.txt