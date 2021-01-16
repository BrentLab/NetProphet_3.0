#!/bin/bash
# ##########################################################################
# | This module implements the feed-forward implementation: general idea:| #
# | in every iteration select the top edges of the previous netprophet3  | #
# | run                                                                  | #
# ##########################################################################


# ======================================================================== #
# |                  *** DEFINE DEFAULT PARAMETERS ***                   | #
# ======================================================================== #
p_net_lasso="NONE"
p_net_de="NONE"
p_net_bart="NONE"
p_net_pwm="NONE"
p_net_binding="NONE"
l_top_edges="NONE"

# ======================================================================== #
# |                         *** PARSE ARGUMENTS ***                      | #
# ======================================================================== #
while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                p_reg)
                    p_reg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_target)
                    p_target="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
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
                p_net_new)
                    p_net_new="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_net_binding)
                    p_net_binding="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_binding_event)
                    p_binding_event="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_out_dir)
                    p_out_dir="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_out_net)
                    p_out_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                model)
                    model="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                l_top_edges)
                    nargs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    if [ ${nargs} == "NONE" ]
                    then
                        l_top_edges="NONE"
                    else
                        l_top_edges=${nargs}
                        for ((i=1;i<`expr ${nargs} + 1`;i++))
                        do
                            arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                            l_top_edges+=("${arg}")
                        done
                    fi
                    ;;
                seed)
                    seed="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_out_logs)
                    p_out_logs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_penalize)
                    flag_penalize="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_training)
                    flag_training="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                nbr_reg)
                    nbr_reg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_intercept)
                    flag_intercept="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
            esac;;
        h)
            echo "usage"
            exit 2
           ;;
    esac
done
# ======================================================================== #
# |                       *** END PARSE ARGUMENTS ***                    | #
# ======================================================================== #

# ======================================================================== #
# |                        *** COMBINE NETWORKS ***                      | #
# ======================================================================== #

# ------------------------------------------------------------------------ #
# |                     *** Load Modules for Slurm ***                   | #
# ------------------------------------------------------------------------ #

if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

# ------------------------------------------------------------------------ #
# |                 *** Combine networks LASSO, DE, ETC ***              | #  
# ------------------------------------------------------------------------ #
echo "all edges"
${p_src_code}wrapper/combine_networks_c.sh \
    --model ${model} \
    --flag_slurm ${flag_slurm} \
    --p_src_code ${p_src_code} \
    --p_out_net ${p_out_net} \
    --p_out_dir ${p_out_dir} \
    --seed ${seed} \
    --p_net_lasso ${p_net_lasso} \
    --p_net_de ${p_net_de} \
    --p_net_bart ${p_net_bart} \
    --p_net_pwm ${p_net_pwm} \
    --p_net_new ${p_net_new} \
    --p_net_binding ${p_net_binding} \
    --p_binding_event ${p_binding_event} \
    --p_out_logs ${p_out_logs} \
    --flag_penalize ${flag_penalize} \
    --flag_training ${flag_training} \
    --nbr_reg ${nbr_reg} \
    --flag_intercept ${flag_intercept} \
    --l_top_edges ${l_top_edges[@]}
    
# ------------------------------------------------------------------------ #
# |                 *** Combine networks LASSO, DE, ETC ***              | # 
# |                      *** Feed-forward for loop ***                   | #
# ------------------------------------------------------------------------ #

if [ ${l_top_edges} != "NONE" ] && [ ${flag_training} == "10-fold-cv" ]
then
    echo ""
    echo "***FEED-FORWARD*** started for top edges: ${l_top_edges[@]}.."
    p_in_top_net=${p_out_net}
    for (( i=1;i<${#l_top_edges[@]};i++ ))
    do
        # wait if the netprophet network file is not ready 
        # from previous iteration
        while [ ! -f ${p_in_top_net} ]
        do
            sleep 10
        done
        sleep 120  # to wait for the p_in_top_net file to complete writing..
        
        # initialize nbre of top edges and corresponding output dir
        top_edges=${l_top_edges[i]}
        mkdir -p ${p_out_dir}top_${top_edges}
        
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
        # |                 *** select top edges ***                  | #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
        echo ""
        echo "select top edges: ${top_edges}.."
        source activate netprophet
        if [ ${flag_slurm} == "ON" ]
        then
            ls -l /home/dabid/.conda/envs/netprophet/bin >> ${p_out_logs}tmp.txt
        fi
        
        python ${p_src_code}code/combine_networks_select_top_k_edges.py \
            --p_in_top_net ${p_in_top_net} \
            --l_net_name binding lasso de bart pwm new \
            --l_p_in_net ${p_net_binding} ${p_net_lasso} ${p_net_de} ${p_net_bart} ${p_net_pwm} ${p_net_new} \
            --p_out_dir ${p_out_dir}top_${top_edges}/ \
            --l_out_fname_net net_binding.tsv net_lasso.tsv net_de.tsv net_bart.tsv net_pwm.tsv net_new.tsv \
            --top ${top_edges} \
            --p_reg ${p_reg} \
            --p_target ${p_target}
        source deactivate netprophet
        if [ ${flag_slurm} == "ON" ]
        then
            ls -l /home/dabid/.conda/envs/netprophet/bin >> ${p_out_logs}tmp.txt
        fi
    
        if [ ${p_net_lasso} != "NONE" ]
        then
            p_net_lasso_top=${p_out_dir}top_${top_edges}/net_lasso.tsv
        else
            p_net_lasso_top="NONE"
        fi
        
        if [ ${p_net_de} != "NONE" ]
        then
            p_net_de_top=${p_out_dir}top_${top_edges}/net_de.tsv
        else
            p_net_de_top="NONE"
        fi
        
        if [ ${p_net_bart} != "NONE" ]
        then
            p_net_bart_top=${p_out_dir}top_${top_edges}/net_bart.tsv
        else
            p_net_bart_top="NONE"
        fi
        
        if [ ${p_net_binding} != "NONE" ]
        then
            p_net_binding_top=${p_out_dir}top_${top_edges}/net_binding.tsv
        else
            p_net_binding_top="NONE"
        fi
        
        if [ ${p_net_pwm} != "NONE" ]
        then
            p_net_pwm_top=${p_out_dir}top_${top_edges}/net_pwm.tsv
        else
            p_net_pwm_top="NONE"
        fi
        
        if [ ${p_net_new} != "NONE" ]
        then
            p_net_new_top=${p_out_dir}top_${top_edges}/net_new.tsv
        else
            p_net_new_top="NONE"
        fi
        
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
        # |      *** combine networks for top selected edges ***      | #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
        mkdir -p ${p_out_logs}top_${top_edges}/
        ${p_src_code}wrapper/combine_networks_c.sh \
            --model ${model} \
            --flag_slurm ${flag_slurm} \
            --p_src_code ${p_src_code} \
            --p_out_net ${p_out_dir}top_${top_edges}/net_np3_${top_edges}.tsv \
            --p_out_dir ${p_out_dir}top_${top_edges}/ \
            --seed ${seed} \
            --p_net_lasso ${p_net_lasso_top} \
            --p_net_de ${p_net_de_top} \
            --p_net_bart ${p_net_bart_top} \
            --p_net_pwm ${p_net_pwm_top} \
            --p_net_new ${p_net_new_top} \
            --p_net_binding ${p_net_binding_top} \
            --p_binding_event ${p_binding_event} \
            --p_out_logs ${p_out_logs}top_${top_edges}/ \
            --flag_penalize ${flag_penalize} \
            --flag_training ${flag_training} \
            --nbr_reg ${nbr_reg} \
            --flag_intercept ${flag_intercept}
        
        p_in_top_net=${p_out_dir}top_${top_edges}/net_np3_${top_edges}.tsv
        
    done
    
    
fi

