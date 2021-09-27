#!/bin/bash

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        -)
        case "${OPTARG}" in 
            p_in_dir)
                p_in_dir="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            in_model_name)
                in_model_name="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            l_in_name_net)
                l_in_name_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            nbr_bootstrap)
                nbr_bootstrap="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            nbr_cv_fold)
                nbr_cv_fold="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            flag_training)
                flag_training="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            # logistic
            p_src_code)
                p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_out_dir_logs)
                p_out_dir_logs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            data)
                data="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
                
            # singularity
            flag_singularity)
                flag_singularity="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_singularity_img)
                p_singularity_img="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_singularity_bindpath)
                p_singularity_bindpath="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
                
            # slurm
            flag_slurm)
                flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            bootstrap_slurm_nodes)
                bootstrap_slurm_nodes="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
        esac;;
    esac
done


# create files for bootrap
cmd_select_data=""
if [ ${flag_slurm} == "ON" ]; then
    cmd_select_data="sbatch \
                            -o ${p_out_dir}select_data_%J.out \
                            -e ${p_out_dir}select_data_%J.err \
                            -J ${data}_select_data \
                            -N 1 \
                            -n 1 \
                            --mem=5GB "
fi
cmd_select_data+="${p_src_code}src/combine_networks/extra_modules/bootstrap/wrapper/bootstrap_training.sh \
                        --p_in_dir ${p_in_dir} \
                        --flag_training ${flag_training} \
                        --nbr_bootstrap ${nbr_bootstrap} \
                        --nbr_cv_fold ${nbr_cv_fold} \
                        --flag_singularity ${flag_singularity} \
                        --flag_slurm ${flag_slurm} \
                        --p_src_code ${p_src_code}"
job_id_select_data=$(echo $(eval ${cmd_select_data}) | awk '{split($0, a, " "); print a[4]}')

# loop over bootstrappped files and run
for ((i=0;i<${nbr_bootstrap};i++))
do
    echo "bootstrap: ${i}"
    cmd_train_bootstrap=""
    if [ ${flag_slurm} == "ON" ]; then
        cmd_train_bootstrap+="sbatch \
                              -o ${p_out_dir_logs}train_bootstrap_${i}_%J.out \
                              -e ${p_out_dir_logs}train_bootstrap_${i}_%J.err \
                              -J ${data}_bootstrap_${i} \
                              -N ${bootstrap_slurm_nodes} \
                              --mem=30GB \
                              --dependency=afterok:${job_id_select_data} "
    fi

    if [ ${flag_training} == "ON-CV" ]; then
        cmd_train_bootstrap+="${p_src_code}src/combine_networks/extra_modules/bootstrap/workflow/train_test_for_cv.sh \
                  --p_in_dir ${p_in_dir} \
                  --bootstrap_idx ${i} \
                  --in_model_name ${in_model_name} \
                  --l_in_name_net ${l_in_name_net} \
                  --nbr_cv_fold ${nbr_cv_fold} \
                  --p_src_code ${p_src_code} \
                  --flag_singularity ${flag_singularity} \
                  --p_singularity_img ${p_singularity_img} \
                  --p_singularity_bindpath ${p_singularity_bindpath} \
                  --flag_slurm ${flag_slurm}"
    fi
    eval ${cmd_train_bootstrap}
    
done