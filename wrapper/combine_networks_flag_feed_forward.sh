#!/bin/bash

# ======================================================================== #
# |                   *** SET UP NETWORKS TO NONE ***                    | #
# | by default the networks of LASSO, DE, BART, and PWM are not provided | #
# | and hence are setp up to NONE, this value will change to network     | #
# | path  if the user provide it                                         | #
# ======================================================================== #

p_net_lasso="NONE"
p_net_de="NONE"
p_net_bart="NONE"
p_net_pwm="NONE"

p_net_lasso_exclude="NONE"
p_net_de_exclude="NONE"
p_net_bart_exclude="NONE"
p_net_pwm_exclude="NONE"

p_net_lasso_top="NONE"
p_net_de_top="NONE"
p_net_bart_top="NONE"
p_net_pwm_top="NONE"

# ======================================================================== #
# |                         *** PARSE ARGUMENTS ***                      | #
# ======================================================================== #
while getopts ":h-:" OPTION
do
  case "${OPTION}" in
    -)
      case "${OPTARG}" in
      p_out_tmp)
        p_out_tmp="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_out_net)
        p_out_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_net_lasso)
        p_net_lasso="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_net_bart)
        p_net_bart="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_net_de)
        p_net_de="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_net_pwm)
        p_net_pwm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_in_binding_event)
        p_in_binding_event="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      model)
        model="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_src_code)
        p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_net_np3)
        p_net_np3="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      flag_slurm)
        flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      seed)
        seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_in_reg)
        p_in_reg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_in_target)
        p_in_target="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      l_count_top)
        l_count_top=()
        arg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        i=1
        while [ -n "${arg}" ]
        do
          l_count_top+=(${arg})
          ((i+=1))
          arg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        done
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
echo "combine_network started, feed: ${l_count_top[@]}"

# load modules in case of slurm
if (( ${flag_slurm} == "ON" ))
then
  source ${p_src_code}wrapper/load_modules.sh
fi

# -------------------------------------------------------------- #
# |               *** Create binding network ***               | # 
# | create binding network from binding events, a matrix of 0s | #
# | and 1s: 1 when there is support, 0 when there isn't        | #
# -------------------------------------------------------------- #
echo "    - create binding network from binding events.."  # create binding network (matrix) from binding events
p_net_binding=${p_out_tmp}net_binding.tsv

${p_src_code}wrapper/create_binding_network.sh \
  ${p_in_binding_event} \
  ${p_in_reg} \
  ${p_in_target} \
  ${p_net_binding} \
  ${flag_slurm} \
  ${p_src_code}

# ---------------------------------------------------------------- #
# |          *** Exclude edges from Training/Testing ***         | #
# | exclude edges of regulators or targets that do not exist in  | #
# | in the binding data. We are not going to 10-fold CV on these | #
# | edges.                                                       | #
# ---------------------------------------------------------------- #
echo "    - exclude edges with no reg/target support in 10-fold CV.."
mkdir -p ${p_out_tmp}exclude/  # we put the remaining edges in exclude directory
${p_src_code}wrapper/exclude_edges_with_no_reg_target_support.sh \
  ${p_in_binding_event} \
  ${p_net_lasso} \
  ${p_net_bart} \
  ${p_net_de} \
  ${p_net_pwm} \
  ${p_net_binding} \
  ${p_in_target} \
  ${p_in_reg} \
  ${p_out_tmp}exclude/ \
  ${flag_slurm} \
  ${p_src_code}


# ------------------------------------------------------------------ #
# |                  *** Combine networks ***                      | # 
# | without the feed forward option, which mean combine the entire | #
# | edges of the universe.                                         | #
# ------------------------------------------------------------------ #
echo "    - combine networks.."

# create path for exclude networks
# LASSO
if [ ${p_net_lasso} != "NONE" ]
then
    p_net_lasso_exclude=${p_out_tmp}exclude/net_lasso.tsv
fi
# DE
if [ ${p_net_de} != "NONE" ]
then
    p_net_de_exclude=${p_out_tmp}exclude/net_de.tsv
fi
# BART
if [ ${p_net_bart} != "NONE" ]
then
    p_net_bart_exclude=${p_out_tmp}exclude/net_bart.tsv
fi
# PWM
if [ ${p_net_pwm} != "NONE" ]
then
    p_net_pwm_exclude=${p_out_tmp}exclude/net_pwm.tsv
fi

# combine these networks
${p_src_code}wrapper/combine_networks.sh \
    ${p_out_tmp} \
    ${p_net_lasso_exclude} \
    ${p_net_bart_exclude} \
    ${p_net_de_exclude} \
    ${p_net_pwm_exclude} \
    ${p_out_tmp}exclude/net_binding.tsv \
    ${model} \
    ${p_src_code} \
    ${p_net_np3} \
    ${flag_slurm} \
    ${seed} \
    ${p_in_reg} \
    ${p_in_target} \
    "ON"  # flag_matrix for output networks

# ------------------------------------------------------------------ #
# |         *** Combine network with feed forward option ***       | #
# ------------------------------------------------------------------ #
echo "    - Start feed forward training/testing.."
if (( ${l_count_top} != "NONE" ))
then
    p_in_top_net=${p_net_np3} 
    for (( i=0; i<${#l_count_top[@]}; i++ ))  # loop over the number of edges
    do
        count_top=${l_count_top[i]}
        mkdir -p ${p_out_tmp}top_${count_top}/

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
        # |           *** Select Top k edges ***              | #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
        echo "        - select top ${count_top} edges.."
        source activate netprophet
        ls -la /home/dabid/.conda/envs/netprophet/bin > /dev/null
        
        python ${p_src_code}code/select_top_k_edges.py \
            --p_in_top_net ${p_in_top_net} \
            --l_net_name binding lasso de bart pwm \
            --l_p_in_net ${p_net_binding} ${p_net_lasso} ${p_net_de} ${p_net_bart} ${p_net_pwm} \
            --p_out_dir ${p_out_tmp}top_${count_top}/ \
            --l_out_fname_net net_binding.tsv net_lasso.tsv net_de.tsv net_bart.tsv net_pwm.tsv\
            --top ${count_top} \
            --p_reg ${p_in_reg} \
            --p_target ${p_in_target}
        source deactivate netprophet
        
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
        # |         *** Combine networks for top k ***        | #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
        echo "        - combine networks for top ${count_top} edges.."
        # LASSO
        if [ ${p_net_lasso} != "NONE" ]
        then
            p_net_lasso_top=${p_out_tmp}top_${count_top}/net_lasso.tsv
        fi
        # DE
        if [ ${p_net_de} != "NONE" ]
        then
            p_net_de_top=${p_out_tmp}top_${count_top}/net_de.tsv
        fi
        # BART
        if [ ${p_net_bart} != "NONE" ]
        then
            p_net_bart_top=${p_out_tmp}top_${count_top}/net_bart.tsv
        fi
        # PWM
        if [ ${p_net_pwm} != "NONE" ]
        then
            p_net_pwm_tope=${p_out_tmp}top_${count_top}/net_pwm.tsv
        fi
        ${p_src_code}wrapper/combine_networks.sh \
            ${p_out_tmp}top_${count_top}/ \
            ${p_out_tmp}top_${count_top}/net_lasso.tsv \
            ${p_out_tmp}top_${count_top}/net_bart.tsv \
            ${p_out_tmp}top_${count_top}/net_de.tsv \
            ${p_out_tmp}top_${count_top}/net_pwm.tsv \
            ${p_out_tmp}top_${count_top}/net_binding.tsv \
            ${model} \
            ${p_src_code} \
            ${p_out_net}net_np3_${count_top}.tsv \
            ${flag_slurm} \
            ${seed} \
            ${p_in_reg} \
            ${p_in_target} \
            "OFF"  #flag matrix for output networks
        
        p_in_top_net=${p_out_net}net_np3_${count_top}.tsv 
    done
fi