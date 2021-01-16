#!/bin/bash

p_net_lasso="NONE"
p_net_de="NONE"
p_net_bart="NONE"
p_net_pwm="NONE"

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                p_net_lasso)
                    p_net_lasso="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_de)
                    p_net_de="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_bart)
                    p_net_bart="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;  
                p_net_pwm)
                    p_net_pwm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                model_1)
                    model_1="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                model_2)
                    model_2="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_out_tmp)
                    p_out_tmp="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_np3)
                    p_net_np3="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                l_coef_1)
                    l_coef_1="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                l_coef_2)
                    l_coef_2="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_model_1)
                    p_model_1="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_model_2)
                    p_model_2="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
            esac;;
        h)
            echo "usage"
            exit 2
            ;;
    esac
done

if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

echo " - split networks: networks with DE and without DE"
source activate netprophet
ls -la /home/dabid/.conda/envs/netprophet/bin

python ${p_src_code}code/combine_networks_split_networks_based_on_perturbed_reg.py \
    --p_net_lasso ${p_net_lasso} \
    --p_net_de ${p_net_de} \
    --p_net_bart ${p_net_bart} \
    --p_net_pwm ${p_net_pwm} \
    --p_out_dir ${p_out_tmp}
source deactivate netprophet

if [ -d ${p_out_tmp}with_de ]
then
    if [ ${p_net_lasso} != "NONE" ]
    then
        p_net_lasso_1=${p_out_tmp}with_de/net_lasso.tsv
    else
        p_net_lasso_1="NONE"
    fi

    if [ ${p_net_de} != "NONE" ]
    then
        p_net_de_1=${p_out_tmp}with_de/net_de.tsv
    else
        p_net_de_1="NONE"
    fi

    if [ ${p_net_bart} != "NONE" ]
    then
        p_net_bart_1=${p_out_tmp}with_de/net_bart.tsv
    else
        p_net_bart_1="NONE"
    fi

    if [ ${p_net_pwm} != "NONE" ]
    then
        p_net_pwm_1=${p_out_tmp}with_de/net_pwm.tsv
    else
        p_net_pwm_1="NONE"
    fi
    
    p_net_np3_with_de=${p_out_tmp}with_de/net_np3.tsv
    Rscript ${p_src_code}code/combine_networks_default_coefficients.R \
        --p_in_lasso ${p_net_lasso_1} \
        --p_in_de ${p_net_de_1} \
        --p_in_bart ${p_net_bart_1} \
        --p_in_pwm ${p_net_pwm_1} \
        --model ${model_1} \
        --p_src_code ${p_src_code} \
        --l_coef ${l_coef_1} \
        --p_model ${p_model_1} \
        --p_out_net ${p_net_np3_with_de}
fi

if [ -d ${p_out_tmp}without_de ]
then
    if [ ${p_net_lasso} != "NONE" ]
    then
        p_net_lasso_2=${p_out_tmp}without_de/net_lasso.tsv
    else
        p_net_lasso_2="NONE"
    fi

    if [ ${p_net_bart} != "NONE" ]
    then
        p_net_bart_2=${p_out_tmp}without_de/net_bart.tsv
    else
        p_net_bart_2="NONE"
    fi

    if [ ${p_net_pwm} != "NONE" ]
    then
        p_net_pwm_2=${p_out_tmp}without_de/net_pwm.tsv
    else
        p_net_pwm_2="NONE"
    fi
    
    p_net_np3_without_de=${p_out_tmp}without_de/net_np3.tsv
    Rscript ${p_src_code}code/combine_networks_default_coefficients.R \
        --p_in_lasso ${p_net_lasso_2} \
        --p_in_bart ${p_net_bart_2} \
        --p_in_pwm ${p_net_pwm_2} \
        --model ${model_2} \
        --p_src_code ${p_src_code} \
        --l_coef ${l_coef_2} \
        --p_model ${p_model_2} \
        --p_out_net ${p_net_np3_without_de} 
fi
source activate netprophet
ls -la /home/dabid/.conda/envs/netprophet/bin >> tmp.txt

python ${p_src_code}code/combine_networks_concat_networks.py \
    --l_p_in_net ${p_net_np3_with_de} ${p_net_np3_without_de} \
    --p_out_file ${p_net_np3} \
    --flag_method 'a'
source deactivate netprophet

sleep 10  # to be sure that the file p_net_np3 has finished writing.