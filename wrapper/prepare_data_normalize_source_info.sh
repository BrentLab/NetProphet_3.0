#!/bin/bash

#!/bin/bash

p_net_lasso="NONE"
p_net_de="NONE"
p_net_bart="NONE"
p_net_pwm="NONE"

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        h)
            echo "help"
            ;;
        -)
            case "${OPTARG}" in
                p_net_lasso_ref)
                    p_net_lasso_ref="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_de_ref)
                    p_net_de_ref="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_bart_ref)
                    p_net_bart_ref="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_pwm_ref)
                    p_net_pwm_ref="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
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
                p_out_dir)
                    p_out_dir="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                method)
                    method="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
            esac;;
    esac
    
done

if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

source activate netprophet
ls -la /home/dabid/.conda/envs/netprophet/bin > /dev/null
python ${p_src_code}code/prepare_data_normalize_source_of_information.py \
    --p_net_lasso_ref ${p_net_lasso_ref} \
    --p_net_de_ref ${p_net_de_ref} \
    --p_net_bart_ref ${p_net_bart_ref} \
    --p_net_pwm_ref ${p_net_pwm_ref} \
    --p_net_lasso ${p_net_lasso} \
    --p_net_de ${p_net_de} \
    --p_net_bart ${p_net_bart} \
    --p_net_pwm ${p_net_pwm} \
    --method ${method} \
    --p_out_dir ${p_out_dir}
    
source deactivate netprophet    