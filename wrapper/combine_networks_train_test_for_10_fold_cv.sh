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
            p_net_binding)
                p_net_binding="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            flag_slurm)
                flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            p_src_code)
                p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            model_name)
                model_name="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
            l_name_net)
                l_name_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                ;;
            l_path_net)
                l_path_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
  --p_net_binding ${p_net_binding} \
  --l_net_name ${l_name_net} \
  --l_p_net ${l_path_net} \
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
source ${p_src_code}wrapper/helper.sh

echo "   - Train/Test for 10-fold CV.."
for f in {0..9}
do
    l_path_net_train_fold=$(create_paths ${l_name_net} fold${f}_train ${p_out_dir}data_cv/)
    l_path_net_test_fold=$(create_paths ${l_name_net} fold${f}_test ${p_out_dir}data_cv/)
    
    ${p_src_code}wrapper/combine_networks_train_test.sh \
        --p_binding_train ${p_out_dir}data_cv/fold${f}_train_binding.tsv \
        --l_name_net ${l_name_net} \
        --l_path_net_train ${l_path_net_train_fold} \
        --l_path_net_test ${l_path_net_test_fold} \
        --model_name ${model_name} \
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