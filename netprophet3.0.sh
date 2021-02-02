#!/bin/bash

# ============================================================================= #
# |                    **** USAGE OF NETPROPHET 3.0 ****                      | #
# ============================================================================= #
usage(){
cat << EOF
    netprophet3.0 [options]
    
    INPUT arguments:
    --p_in_target            : input file for list of target genes
    --p_in_reg               : input file for list of regulators
    --p_in_sample            : input file for list of sample (condition) ids
    --p_in_expr_target       : input file for expression of target genes (target x sample)
    --p_in_expr_reg          : input file for expression of regulators (reg x sample)
    --p_in_net_de            : input file for network of differential expression
    --p_in_binding_event     : input file for binding events |REGULATOR|TARGET|
    --seed                   : seed for generating the fold cross valition (default 747)
    --p_src_code             : path for source of code
    
    LASSO arguments:
    --flag_local_shrinkage   : "ON" for estimating a shrinkage parameter for every target gene, "OFF" otherwise (default "ON")
    --flag_global_shrinkage  : "ON" for estimating a shrinkage parameter for all target genes, "OFF" otherwise (default "OFF")
    --flag_microarray        : "MICROARRAY" for microarray expression data, "RNA-SEQ" for RNA-Seq data
    --fname_net_lasso        : name of generated network for lasso (optional)
    --p_net_lasso            : path of LASSO network (use this argument only if you have already generated LASSO) 
        
    BART arguments:
    --fname_net_bart         : name of generated network for bart
    --p_net_bart             : path of BART network (use this argument only if you have already generated BART)
    
    PWM arguments:
    --fname_net_pwm        : name of generated network for motif
    --p_in_net_pwm            : path of MOTIF network (use this argument only if you have already generated MOTIF network)
    --p_in_promoter          : 
    
    COMBINE arguments:
    --nbr_cv_fold            : number of fold cross validation (default 10)
    --model_1a               : name of the model for combining networks without PWM for networks combined with DE network
    --model_2b               : name of the model for combining networks without PWM for networks combined without DE network
    --model_1b               : name of model for combining networks with PWM network for networks combined with DE network
    --model_2b               : name of model for combining networks with PWM network for networks combined without DE network
    --l_top_edges_1          : array for feed forward run such (3000 2000 1000) having perturbation
    --l_top_edges_2          : array for feed forward run such (300 200 100) not having perturbation
    --flag_penalize          : "ON" for penalization, and "OFF" without penalization (default is "ON")
    --flag_training          : "ON" for combining for training, and "OFF" for using default parameters instead (default is "ON").
    
    OUTPUT arguments:
    --fname_net_np3          : name of generated network for netprophet
    
    SLURM arguments:
    --flag_slurm             : "ON" for parallel (slurm) run, "OFF" for sequential run
    --p_out_logs             : output file for logs (.out & .err) for slurm runs
    --mail_user              : mail address of the user for slurm run logs
    --mail_type              : when to send an email to the user (default FAIL)
    --data                   : prefix of job names for slurm jobs      
    
    -h                       : display usage for netprophet3.0 commandline
    -a                       : run ALL components
    -l                       : run only the LASSO component
    -b                       : run only the BART component
    -c                       : run only the COMBINE component
    -e                       : run only the EVALUATION component 
    
EOF
}

# ======================================================================================================= #
# |                                   **** PARSE ARGUMENTS ****                                         | #
# ======================================================================================================= #

# ------------------------------------------------------------------------------------- #
# |         *** Read default arguments: these arguments are not mandatory ***         | #
# ------------------------------------------------------------------------------------- #

p_src_code=/scratch/mblab/dabid/netprophet/code_netprophet3.0/
flag_debug="OFF"

# INPUT arguments
seed=747

# LASSO arguments
flag_local_shrinkage="ON"
flag_global_shrinkage="OFF"
flag_microarray="MICROARRAY"
fname_net_lasso=net_lasso.tsv
p_net_lasso="NONE"

# BART arguments
fname_net_bart=net_bart.tsv
p_net_bart="NONE"

# New Source of information
fname_net_new=net_new.tsv
p_net_new="NONE"

# netprophet1 arguments
fname_net_np1=net_np1.tsv
p_net_np1="NONE"

# NORMALIZATION arguments
flag_normalize="OFF"
normalize_method="NONE"
p_net_lasso_ref="NONE"
p_net_de_ref="NONE"
p_net_bart_ref="NONE"
p_net_pwm_ref="NONE"

# COMBINATION arguments
nbr_cv_fold=10
l_count_top="NONE"
model_1="NONE"
model_2="NONE"
l_top_edges_1="NONE"
l_top_edges_2="NONE"
flag_penalize="ON"
flag_training="10-fold-cv"
nbr_reg=50
model_1b="NONE"
model_2b="NONE"
l_coef_1a="NULL"
l_coef_2a="NULL"
l_coef_1b="NULL"
l_coef_2b="NULL"
p_model_1a="NONE"
p_model_2a="NONE"
p_model_1b="NONE"
p_model_2b="NONE"
flag_intercept="ON"
p_in_net_de="NONE"

# OUTPUT argunments
fname_net_np3_a=net_np3_a.tsv
fname_net_np3_a_unmelt=tmp_net_np3_a_unmelt.tsv
fname_net_np3_b=net_np3_b.tsv

# pwm arguments
fname_net_pwm=net_pwm.tsv
p_in_net_pwm="NONE"

# SLURM arguments
mail_type=FAIL
mail_user=dabid@wustl.edu
flag_slurm="OFF"

# RUN arguments
flag_run_all="ON"
flag_run_lasso="OFF"
flag_run_bart="OFF"
flag_run_combine="OFF"
flag_run_eval="OFF"
flag_run_pwm="OFF"
flag_run_combine_pwm="OFF"
flag_analyze_predictors="OFF"
flag_run_np1="OFF"

# ------------------------------------------------------------------------------------- #
# |                   *** Read arguments provided by the user ***                     | #
# ------------------------------------------------------------------------------------- #
while getopts ":hlbckmea-:" OPTION
do
  case "${OPTION}" in
    l)
      flag_run_lasso="ON"
      flag_run_all="OFF"
      ;;
    b)
      flag_run_bart="ON"
      flag_run_all="OFF"
      ;;
    c)
      flag_run_combine="ON"
      flag_run_all="OFF"
      ;;
    k)
      flag_run_combine_pwm="ON"
      flag_run_all="OFF"
      ;;
    m)
      flag_run_pwm="ON"
      flag_run_all="OFF"
      ;;
    e)
      flag_run_eval="ON"
      flag_run_all="OFF"
      ;;
    a)
      flag_analyze_predictors="ON"
      flag_run_all="OFF"
      ;;
    h)
      usage
      exit 2
      ;;
    -)
      case "${OPTARG}" in
        p_in_target)
          p_in_target="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_reg)
          p_in_reg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_sample)
          p_in_sample="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_expr_target)
          p_in_expr_target="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_expr_reg)
          p_in_expr_reg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        flag_local_shrinkage)
          flag_local_shrinkage="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        flag_global_shrinkage)
          flag_global_shrinkage="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        flag_slurm)
          flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        flag_microarray)
          flag_microarray="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        seed)
          seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        nbr_cv_fold)
          nbr_cv_fold="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_out_dir)
          p_out_dir="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        fname_net_np3)
          fname_net_np3="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        fname_net_lasso)
          fname_net_lasso="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_net_lasso)
          p_net_lasso="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        fname_net_bart)
          fname_net_bart="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_net_bart)
          p_net_bart="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_net_de)
          p_in_net_de="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        fname_net_pwm)
          fname_net_pwm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_net_pwm)
          p_in_net_pwm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        fname_net_new)
          fname_net_new="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_net_new)
          p_net_new="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_promoter)
          p_in_promoter="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_binding_event)
          p_in_binding_event="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        model_ldb)
          model_1a="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        model_lb)
          model_2a="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        model_ldbp)
          model_1b="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        model_lbp)
          model_2b="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_src_code)
          p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_out_logs)
          p_out_logs="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        mail_type)
          mail_type="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        mail_user)
          mail_user="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        l_top_edges_1)
          narg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
          l_top_edges_1=("${narg}")
          for (( i=1;i<`expr ${narg}+1`;i++ ))
          do
            arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
            l_top_edges_1+=("${arg}")
          done
          ;;
        l_top_edges_2)
          narg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
          l_top_edges_2=("${narg}")
          for (( i=1;i<`expr ${narg}+1`;i++ ))
          do
            arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
            l_top_edges_2+=("${arg}")
          done
          ;;
        data)
          data="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        flag_penalize)
          flag_penalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        flag_training)
          flag_training="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        l_coef_1a)
          l_coef_1a="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        l_coef_2a)
          l_coef_2a="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        l_coef_1b)
          l_coef_1b="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        l_coef_2b)
          l_coef_2b="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_model_1a)
          p_model_1a="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_model_2a)
          p_model_2a="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_model_1b)
          p_model_1b="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_model_2b)
          p_model_2b="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        nbr_reg)
          nbr_reg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        flag_normalize)
          flag_normalize="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        normalize_method)
          normalize_method="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_net_lasso_ref)
          p_net_lasso_ref="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_net_de_ref)
          p_net_de_ref="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_net_bart_ref)
          p_net_bart_ref="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_net_pwm_ref)
          p_net_pwm_ref="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        flag_intercept)
          flag_intercept="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        flag_run_np1)
          flag_run_np1="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          flag_run_all="OFF"
          ;;
        l_path_net_1)
          l_path_net_1="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        l_name_net_1)
          l_name_net_1="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        l_path_net_2)
          l_path_net_2="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        l_name_net_2)
          l_name_net_2="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
      esac;;
    

    esac
done

# ======================================================================================================= #
# |                                    **** END PARSE ARGUMENTS ****                                    | #
# ======================================================================================================= #

# create the output directory if it doesn't exist
# if [ -d ${p_out_dir} ]
# then
#     rm -r ${p_out_dir}
# fi
mkdir -p ${p_out_dir}

p_out_tmp=${p_out_dir}tmp/
mkdir -p ${p_out_tmp}

p_out_net=${p_out_dir}net/
mkdir -p ${p_out_net}

if [ ${p_in_net_pwm} == "NONE" ]
then
    p_in_net_pwm=${p_out_net}${fname_net_pwm}
fi

if [ ${p_net_lasso} == "NONE" ]
then
    p_net_lasso=${p_out_net}${fname_net_lasso}
fi

if [ ${p_net_bart} == "NONE" ]
then
    p_net_bart=${p_out_net}${fname_net_bart}
fi

# if [ ${p_net_new} == "NONE" ]
# then
#     p_net_new=${p_out_net}${fname_net_new}
# fi

if [ ${p_net_np1} == "NONE" ]
then
    p_net_np1=${p_out_net}${fname_net_np1}
fi

printf "scancel" >> ${p_out_tmp}scancel.txt
# ======================================================================================================= #
# |                                   *** GENERATE LASSO NETWORK ***                                    | #
# ======================================================================================================= #
job_id_lasso=1
if [ ${flag_run_lasso} == "ON" ] || [ ${flag_run_all} == "ON" ]
then
    p_net_lasso=${p_out_net}${fname_net_lasso}
    if (( ${flag_slurm} == "ON" ))
    then
    mkdir -p ${p_out_logs}
    mkdir -p ${p_out_logs}${data}
    job_lasso=$(sbatch \
      --mail-type=${mail_type} \
      --mail-user=${mail_user} \
      -J ${data}_lasso \
      -o ${p_out_logs}${data}/lasso_%J.out \
      -e ${p_out_logs}${data}/lasso_%J.err \
      -n 11 \
      -D ${p_src_code}code/netprophet1/ \
      --mem-per-cpu=10GB \
      --cpus-per-task=2 \
      ${p_src_code}wrapper/build_net_lasso.sh \
        ${p_in_expr_target} \
        ${p_in_expr_reg} \
        ${flag_global_shrinkage} \
        ${flag_local_shrinkage} \
        ${p_out_net} \
        ${fname_net_lasso} \
        ${flag_debug} \
        ${flag_slurm} \
        ${seed} \
        ${nbr_cv_fold} \
        ${flag_microarray} \
        ${p_src_code})

    job_id_lasso=$(echo ${job_lasso} | awk '{split($0, a, " "); print a[4]}')
    printf " ${job_id_lasso}" >> ${p_out_tmp}scancel.txt
    elif (( ${flag_slurm} == "OFF" ))
    then
    ${p_src_code}wrapper/build_net_lasso.sh \
      ${p_in_expr_target} \
      ${p_in_expr_reg} \
      ${flag_global_shrinkage} \
      ${flag_local_shrinkage} \
      ${p_out_net} \
      ${fname_net_lasso} \
      ${flag_debug} \
      ${flag_slurm} \
      ${seed} \
      ${nbr_cv_fold} \
      ${flag_microarray} \
      ${p_src_code}
    fi
fi
# ======================================================================================================= #
# |                                 *** END GENERATE LASSO NETWORK ***                                  | #
# ======================================================================================================= #

if [ ${flag_run_np1} == "ON" ]
then
    if [ ${flag_slurm} == "ON" ]
    then
    mkdir -p ${p_out_logs}
    mkdir -p ${p_out_logs}${data}
    mkdir -p ${p_out_logs}${data}/np1/
    echo "lasso: ${p_net_lasso}"
    echo "de: ${p_in_net_de}"
    echo "p_src_code: ${p_src_code}"
    echo "p_net_np1: ${p_net_np1}"
    job_np1=$(sbatch \
      --mail-type=${mail_type} \
      --mail-user=${mail_user} \
      -J ${data}_np1 \
      -o ${p_out_logs}${data}/np1/np1_%J.out \
      -e ${p_out_logs}${data}/np1/np1_%J.err \
      --mem-per-cpu 40G \
      ${p_src_code}wrapper/build_net_np1.sh \
        --p_net_lasso ${p_net_lasso} \
        --p_net_de ${p_in_net_de} \
        --p_src_code ${p_src_code} \
        --p_net_np1 ${p_net_np1} \
        --flag_slurm ${flag_slurm})
    fi
fi

 
# ======================================================================================================= #
# |                                    *** GENERATE BART NETWORK ***                                    | #
# ======================================================================================================= #
job_id_bart=1


if [ ${flag_run_bart} == "ON" ] || [ ${flag_run_all} == "ON" ]
then
    p_net_bart=${p_out_net}${fname_net_bart}
    if (( ${flag_slurm} == "ON" ))
    then
    
    job_bart=$(sbatch \
      --mail-type=${mail_type} \
      --mail-user=${mail_user} \
      -J ${data}_bart \
      -o ${p_out_logs}${data}_bart_%J.out \
      -e ${p_out_logs}${data}_bart_%J.err \
      -n 32 \
      --mem=20GB \
      ${p_src_code}wrapper/build_net_bart.sh \
      ${p_in_expr_target} \
      ${p_in_expr_reg} \
      ${p_out_net}\
      ${fname_net_bart} \
      ${flag_slurm} \
      ${p_src_code})
    job_id_bart=$(echo ${job_bart} | awk '{split($0, a, " "); print a[4]}')
    printf " ${job_id_bart}" >> ${p_out_tmp}scancel.txt
    
    elif ((${flag_slurm} == "OFF"))
    then
    ${p_src_code}wrapper/build_net_bart.sh \
      ${p_in_target} \
      ${p_in_reg} \
      ${p_in_expr_target} \
      ${p_in_sample} \
      ${p_out_net}\
      ${fname_net_bart} \
      ${flag_slurm} \
      ${p_src_code}
    fi
fi

# ======================================================================================================= #
# |                                  *** END GENERATE BART NETWORK ***                                  | #
# ======================================================================================================= #

job_id_normalize_ldb=1
if [ ${flag_normalize} == "ON" ]
then
    mkdir -p ${p_out_tmp}normalize/
    job_normalize_ldb=$(sbatch \
                    -o ${p_out_logs}${data}/normalize_net_ldb_%J.out \
                    -e ${p_out_logs}${data}/normalize_net_ldb_%J.err \
                    -J normalize_net_ldb \
                    --dependency=afterany:${job_id_lasso}:${job_id_bart} \
                    ${p_src_code}wrapper/prepare_data_normalize_source_info.sh \
                        --p_net_lasso_ref ${p_net_lasso_ref} \
                        --p_net_de_ref ${p_net_de_ref} \
                        --p_net_bart_ref ${p_net_bart_ref} \
                        --p_net_lasso ${p_net_lasso} \
                        --p_net_de ${p_in_net_de} \
                        --p_net_bart ${p_net_bart} \
                        --p_out_dir ${p_out_tmp}normalize/ \
                        --p_src_code ${p_src_code} \
                        --flag_slurm ${flag_slurm} \
                        --method ${normalize_method})
                        
    job_id_normalize_ldb=$(echo ${job_normalize_ldb} | awk '{split($0, a, " "); print a[4]}')
    
    if [ ${p_net_lasso} != "NONE" ]
    then
        p_net_lasso=${p_out_tmp}normalize/net_lasso.tsv
    fi
    
    if [ ${p_net_de} != "NONE" ]
    then
        p_net_de=${p_out_tmp}normalize/net_de.tsv
    fi
    
    if [ ${p_net_bart} != "NONE" ]
    then
    p_net_bart=${p_out_tmp}normalize/net_bart.tsv
    fi
fi



 
# ======================================================================================================= #
# |                                       *** COMBINE NETWORKS ***                                      | #
# ======================================================================================================= #
job_id_combine_net_ldb=1
if [ ${flag_run_combine} == "ON" ] || [ ${flag_run_all} == "ON" ]
then
    # tmp directory
    if [ -d ${p_out_tmp}combine_net_ldb/ ]
    then
        rm -r ${p_out_tmp}combine_net_ldb/ 
    fi
    mkdir -p ${p_out_tmp}combine_net_ldb/
    
    
    # net directory
    if [ -d ${p_out_net}combine_net_ldb/ ]
    then
        rm -r ${p_out_net}combine_net_ldb/
    fi
    mkdir -p ${p_out_net}combine_net_ldb/
    
    if (( ${flag_slurm} == "ON" ))
    then
      mkdir -p ${p_out_logs}${data}/
      if [ -d ${p_out_logs}${data}/combine_net_ldb/ ]
      then
          rm -r ${p_out_logs}${data}/combine_net_ldb/
      fi
      mkdir -p ${p_out_logs}${data}/combine_net_ldb/
      job_combine_net_ldb=$(sbatch \
          --mail-type=${mail_type} \
          --mail-user=${mail_user} \
          -J ${data}_combine_net_ldb \
          -o ${p_out_logs}${data}/combine_net_ldb/combine_net_ldb_%J.out \
          -e ${p_out_logs}${data}/combine_net_ldb/combine_net_ldb_%J.err \
          --dependency=afterany:${job_id_lasso}:${job_id_bart}:${job_id_normalize_ldb} \
          --mem-per-cpu 10G \
          ${p_src_code}wrapper/combine_networks_a.sh \
            --p_out_tmp ${p_out_tmp}combine_net_ldb/ \
            --p_out_net ${p_out_net}combine_net_ldb/ \
            --p_net_lasso ${p_net_lasso} \
            --p_net_bart ${p_net_bart} \
            --p_net_pwm NONE \
            --p_net_de ${p_in_net_de} \
            --p_binding_event ${p_in_binding_event} \
            --model_1 ${model_1a} \
            --model_2 ${model_2a} \
            --p_src_code ${p_src_code} \
            --p_net_np3 ${p_out_net}combine_net_ldb/${fname_net_np3_a} \
            --flag_slurm ${flag_slurm} \
            --seed ${seed} \
            --p_reg ${p_in_reg} \
            --p_target ${p_in_target} \
            --l_top_edges_1 ${l_top_edges_1[@]} \
            --l_top_edges_2 ${l_top_edges_2[@]} \
            --p_out_logs ${p_out_logs}${data}/combine_net_ldb/ \
            --data ${data} \
            --flag_penalize ${flag_penalize} \
            --flag_training ${flag_training} \
            --l_coef_1 ${l_coef_1a} \
            --l_coef_2 ${l_coef_2a} \
            --nbr_reg ${nbr_reg} \
            --flag_intercept ${flag_intercept} \
            --p_model_1 ${p_model_1a} \
            --p_model_2 ${p_model_2a})

      job_id_combine_net_ldb=$(echo ${job_combine_net_ldb} | awk '{split($0, a, " "); print a[4]}')
      printf " ${job_id_combine_net_ldb}" >> ${p_out_tmp}scancel.txt
      
    elif (( ${flag_slurm} == "OFF" ))
    then
      ${p_src_code}wrapper/combine_networks_flag_feed_forward.sh \
       --p_out_tmp ${p_out_tmp} \
           --p_out_net ${p_out_net} \
           --p_net_lasso ${p_net_lasso} \
           --p_net_bart ${p_net_bart} \
           --p_net_de ${p_in_net_de} \
           --p_binding_event ${p_in_binding_event} \
           --model_1 ${model_1a} \
           --model_2 ${model_2a} \
           --p_src_code ${p_src_code} \
           --p_net_np3 ${p_out_net}${fname_net_np3_a} \
           --flag_slurm ${flag_slurm} \
           --seed ${seed} \
           --p_reg ${p_in_reg} \
           --p_target ${p_in_target} \
           --l_top_edges_1 ${l_top_edges_1[@]} \
           --l_top_edges_2 ${l_top_edges_2[@]}
    fi
fi
# ======================================================================================================= #
# |                                   *** END COMBINE NETWORKS ***                                      | #
# ======================================================================================================= #


# ======================================================================================================= #
# |                                    *** GENERATE MOTIF NETWORK ***                                   | #
# ======================================================================================================= #

job_id_build_pwm_net=1
if [ ${flag_run_pwm} == "ON" ] || [ ${flag_run_all} == "ON" ]
then
    # create directory for results
    mkdir -p ${p_out_tmp}motif_inference/
    mkdir -p ${p_out_tmp}motif_inference/network_bins/
    mkdir -p ${p_out_tmp}motif_inference/motifs_pfm/
    mkdir -p ${p_out_tmp}motif_inference/motifs_score/

    num_regulators=$(wc -l ${p_in_reg} | cut -d" " -f1)
    if [ ${flag_slurm} == "ON" ]
    then
        # create director for logs
        mkdir -p ${p_out_logs}${data}
        if [ -d ${p_out_logs}${data}/infer_score_pwm/ ]
        then
            rm -r ${p_out_logs}${data}/infer_score_pwm/
        fi
        mkdir -p ${p_out_logs}${data}/infer_score_pwm/

        # read the job id for concatenate network from combine networks module
        while [ ! -f ${p_out_net}combine_net_ldb/${fname_net_np3_a} ]
        do
            sleep 10
        done
        
        # unmelt the network
        job_unmelt_net=$(sbatch \
        --mail-type=${mail_type} \
        --mail-user=${mail_user} \
        -o ${p_out_logs}${data}/infer_score_pwm/unmelt_net_%A.out \
        -e ${p_out_logs}${data}/infer_score_pwm/unmelt_net_%A.err \
        -J ${data}_unmelt_net \
        --dependency=afterany:${job_id_combine_net_ldb} \
        ${p_src_code}wrapper/helper_unmelt_net.sh \
            ${p_out_net}combine_net_ldb/${fname_net_np3_a} \
            ${p_in_reg} \
            ${p_in_target} \
            ${p_out_net}combine_net_ldb/${fname_net_np3_a_unmelt} \
            ${flag_slurm} \
            ${p_src_code})
        job_id_unmelt_net=$(echo ${job_unmelt_net} | awk '{split($0, a, " "); print a[4]}')
        printf " ${job_id_unmelt_net}" >> ${p_out_tmp}scancel.txt
        
        # infer motifs
        mkdir -p ${p_out_logs}${data}/infer_score_pwm/pwm_infer/
        p_in_net_pwm=${p_out_net}${fname_net_pwm}
        job_infer_pwm=$(sbatch \
        --mail-type=${mail_type} \
        --mail-user=${mail_user} \
        -o ${p_out_logs}${data}/infer_score_pwm/pwm_infer/infer_pwm_%A.out \
        -e ${p_out_logs}${data}/infer_score_pwm/pwm_infer/infer_pwm_%A.err \
        -J ${data}_infer_pwm \
        --array=1-${num_regulators} \
        --dependency=afterany:${job_id_unmelt_net} \
        ${p_src_code}wrapper/build_net_motif_infer_motifs.sh \
        ${p_out_tmp} \
        ${p_out_net}combine_net_ldb/${fname_net_np3_a_unmelt} \
        ${p_in_reg} \
        ${p_in_target} \
        ${p_in_promoter} \
        ${p_out_tmp}flag_infer_motifs \
        ${flag_slurm} \
        ${p_src_code})
        job_id_infer_pwm=$(echo ${job_infer_pwm} | awk '{split($0, a, " "); print a[4]}')
        printf " ${job_id_infer_pwm}" >> ${p_out_tmp}scancel.txt
        
        # score motifs
        mkdir -p ${p_out_logs}${data}/infer_score_pwm/pwm_score/
        job_score_pwm=$(sbatch \
        --mail-type=${mail_type} \
        --mail-user=${mail_user} \
        -o ${p_out_logs}${data}/infer_score_pwm/pwm_score/score_pwm_%A.out \
        -e ${p_out_logs}${data}/infer_score_pwm/pwm_score/score_pwm_%A.err \
        -J ${data}_score_pwm \
        --array=1-${num_regulators} \
        --dependency=afterany:${job_id_infer_pwm} \
        ${p_src_code}wrapper/build_net_motif_score_motifs.sh \
        ${p_out_tmp} \
        ${p_out_tmp}motif_inference/network_bins/ \
        ${p_in_reg} \
        ${p_in_promoter} \
        ${p_out_tmp}motif_inference/motifs.txt \
        ${p_out_tmp}flag_score_motifs \
        ${flag_slurm} \
        ${p_src_code})
        job_id_score_pwm=$(echo ${job_score_pwm} | awk '{split($0, a, " "); print a[4]}')
        printf " ${job_id_score_pwm}" >> ${p_out_tmp}scancel.txt
        
        # build pwm network
        job_build_pwm_net=$(sbatch \
        --mail-type=${mail_type} \
        --mail-user=${mail_user} \
        -o ${p_out_logs}${data}/infer_score_pwm/build_pwm_net_%A.out \
        -e ${p_out_logs}${data}/infer_score_pwm/build_pwm_net_%A.err \
        -J ${data}_build_pwm_net \
        --dependency=afterany:${job_id_score_pwm} \
        ${p_src_code}wrapper/build_net_motif.sh \
            ${p_out_tmp}motif_inference/motifs.txt \
            ${p_in_reg} \
            ${p_in_target} \
            ${p_out_tmp}motif_inference/motifs_score/ \
            robust \
            16 \
            ${p_in_net_pwm} \
            ${p_src_code} \
            ${flag_slurm})
        job_id_build_pwm_net=$(echo ${job_build_pwm_net} | awk '{split($0, a, " "); print a[4]}')
        printf " ${job_id_build_pwm_net}" >> ${p_out_tmp}scancel.txt
    fi
fi
# ======================================================================================================= #
# |                                  *** END GENERATE PWM NETWORK ***                                   | #
# ======================================================================================================= #


job_id_normalize_p=1
# if [ ${flag_normalize} == "ON" ]
# then
#     mkdir -p ${p_out_tmp}normalize/
#     job_normalize_p=$(sbatch \
#                     -o ${p_out_logs}${data}/normalize_net_pwm_%J.out \
#                     -e ${p_out_logs}${data}/normalize_net_pwm_%J.err \
#                     -J normalize_net_pwm \
#                     --dependency=afterany:${job_id_build_pwm_net} \
#                     ${p_src_code}wrapper/prepare_data_normalize_source_info.sh \
#                         --p_net_pwm_ref ${p_net_pwm_ref} \
#                         --p_net_pwm ${p_in_net_pwm} \
#                         --p_out_dir ${p_out_tmp}normalize/ \
#                         --p_src_code ${p_src_code} \
#                         --flag_slurm ${flag_slurm} \
#                         --method ${normalize_method})
#     job_id_normalize_p=$(echo ${job_normalize_p} | awk '{split($0, a, " "); print a[4]}')
    
#     if [ ${p_in_net_pwm} != "NONE" ]
#     then
#         p_in_net_pwm=${p_out_tmp}normalize/net_pwm.tsv
#     fi
# fi

# ======================================================================================================= #
# |                                       *** COMBINE NETWORKS ***                                      | #
# |                                         combine the PWM network                                     | #
# ======================================================================================================= #
job_id_combine_net_ldbp=1
if [ ${flag_run_combine_pwm} == "ON" ] || [ ${flag_run_all} == "ON" ]
then
    if (( ${flag_slurm} == "ON" ))
    then
      # tmp directory
      if [ -d ${p_out_tmp}combine_net_ldbp/ ]
      then
          rm -r ${p_out_tmp}combine_net_ldbp/
      fi
      mkdir -p ${p_out_tmp}combine_net_ldbp/
      
      # net directory
      if [ -d ${p_out_net}combine_net_ldbp/ ]
      then
          rm -r ${p_out_net}combine_net_ldbp/
      fi
      mkdir -p ${p_out_net}combine_net_ldbp/
      
      mkdir -p ${p_out_logs}${data}/
      if [ -d ${p_out_logs}${data}/combine_net_ldbp/ ]
      then
          rm -r ${p_out_logs}${data}/combine_net_ldbp/
      fi
      mkdir -p ${p_out_logs}${data}/combine_net_ldbp/
      job_combine_net_ldbp=$(sbatch \
          --mail-type=${mail_type} \
          --mail-user=${mail_user} \
          -J ${data}_combine_net_ldbp \
          -o ${p_out_logs}${data}/combine_net_ldbp/combine_net_ldbp_%J.out \
          -e ${p_out_logs}${data}/combine_net_ldbp/combine_net_ldbp_%J.err \
          --mem-per-cpu 10G \
          --dependency=afterany:${job_id_build_pwm_net}:${job_id_normalize_p} \
          ${p_src_code}wrapper/combine_networks_a.sh \
            --p_out_tmp ${p_out_tmp}combine_net_ldbp/ \
            --p_out_net ${p_out_net}combine_net_ldbp/ \
            --l_path_net_1 ${l_path_net_1} \
            --l_name_net_1 ${l_name_net_1} \
            --l_path_net_2 ${l_path_net_2} \
            --l_name_net_2 ${l_name_net_2} \
            --p_binding_event ${p_in_binding_event} \
            --model_1 ${model_1b} \
            --model_2 ${model_2b} \
            --p_src_code ${p_src_code} \
            --p_net_np3 ${p_out_net}combine_net_ldbp/${fname_net_np3_b} \
            --flag_slurm ${flag_slurm} \
            --seed ${seed} \
            --p_reg ${p_in_reg} \
            --p_target ${p_in_target} \
            --l_top_edges_1 ${l_top_edges_1[@]} \
            --l_top_edges_2 ${l_top_edges_2[@]} \
            --p_out_logs ${p_out_logs}${data}/combine_net_ldbp/ \
            --data ${data} \
            --flag_penalize ${flag_penalize} \
            --flag_training ${flag_training} \
            --l_coef_1 ${l_coef_1b} \
            --l_coef_2 ${l_coef_2b} \
            --nbr_reg ${nbr_reg} \
            --flag_intercept ${flag_intercept} \
            --p_model_1 ${p_model_1b} \
            --p_model_2 ${p_model_2b})

      job_id_combine_net_ldbp=$(echo ${job_combine_net_ldbp} | awk '{split($0, a, " "); print a[4]}')
      printf " ${job_id_combine_net_ldbp}" >> ${p_out_tmp}scancel.txt

    elif (( ${flag_slurm} == "OFF" ))
    then
        ${p_src_code}wrapper/combine_networks_a.sh \
            --p_out_tmp ${p_out_tmp} \
            --p_out_net ${p_out_net} \
            --p_net_lasso ${p_net_lasso} \
            --p_net_bart ${p_net_bart} \
            --p_net_de ${p_in_net_de} \
            --p_net_pwm ${p_net_pwm} \
            --p_binding_event ${p_in_binding_event} \
            --model_1 ${model_1} \
            --model_2 ${model_2} \
            --p_src_code ${p_src_code} \
            --p_net_np3 ${p_out_net}${fname_net_np3_b} \
            --flag_slurm ${flag_slurm} \
            --seed ${seed} \
            --p_reg ${p_in_reg} \
            --p_target ${p_in_target} \
            --l_top_edges_1 ${l_top_edges_1[@]} \
            --l_top_edges_2 ${l_top_edges_2[@]}
    fi
fi
# ======================================================================================================= #
# |                                   *** END COMBINE NETWORKS ***                                      | #
# ======================================================================================================= #



# ======================================================================================================= #
# |                                       *** EVALUATE NETWORKS ***                                     | #
# ======================================================================================================= #
job_id_ldb_concat_with_without_de=1
job_id_ldbp_concat_with_without_de=1
job_id_combine_net_ldbp=1
if [ ${flag_run_eval} == "ON" ] || [ ${flag_run_all} == "ON" ]
then
    if [ ${flag_training} == "10-fold-cv" ] || [ ${flag_training} == "1-fold" ]
    then
    while [ ! -f ${p_out_net}combine_net_ldbp/${fname_net_np3_b} ]
    do
        sleep 60
    done
    sleep 90
#         while [ ! -f ${p_out_tmp}combine_net_ldb/job_id_concat_with_without_de.txt ] || [ ! -f ${p_out_tmp}combine_net_ldbp/job_id_concat_with_without_de.txt ] & [ ${job_id_ldb_concat_with_without_de} != 1 ] & [ ${job_id_ldbp_concat_with_without_de} != 1 ] & [ ${job_id_combine_net_ldbp} != 1 ]
#         do
#             sleep 60
#         done
#         while [ ! -f ${p_out_tmp}combine_net_ldbp/job_id_concat_with_without_de.txt ] & [ ${job_id_ldbp_concat_with_without_de} != 1 ] & [ ${job_id_combine_net_ldbp} != 1 ]
#         do
#             sleep 60
#         done
        
#         if [ -f ${p_out_tmp}combine_net_ldb/job_id_concat_with_without_de.txt ]
#         then
#             job_id_ldb_concat_with_without_de=$(<${p_out_tmp}combine_net_ldb/job_id_concat_with_without_de.txt)
#         fi

#         if [ -f ${p_out_tmp}combine_net_ldbp/job_id_concat_with_without_de.txt ]
#         then
#             job_id_ldbp_concat_with_without_de=$(<${p_out_tmp}combine_net_ldbp/job_id_concat_with_without_de.txt)
#         fi
    fi 
    
    l_p_in_net=(3 ${p_net_lasso} ${p_in_net_de} ${p_net_bart})
    l_fname_net=(3 lasso de bart)
    if (( ${flag_slurm} == "ON" ))
    then
      job_evaluate_net=$(sbatch \
        --mail-type=${mail_type} \
        --mail-user=${mail_user} \
        -J ${data}_evaluate_net \
          -o ${p_out_logs}${data}/evaluate_all_net_%J.out \
          -e ${p_out_logs}${data}/evaluate_all_net_%J.err \
          --dependency=afterany:${job_id_ldb_concat_with_without_de}:${job_id_ldbp_concat_with_without_de}:${job_id_combine_net_ldbp} \
          ${p_src_code}wrapper/evaluate_network.sh \
            --p_in_dir_net ${p_out_net} \
            --p_in_reg ${p_in_reg} \
            --p_in_target ${p_in_target} \
            --p_in_binding_event ${p_in_binding_event} \
            --flag_slurm ${flag_slurm} \
            --p_src_code ${p_src_code} \
            --p_out_file_eval ${p_out_net}eval_all_net.tsv \
            --l_fname_net ${l_fname_net[@]} \
            --l_p_in_net ${l_p_in_net[@]})
    job_id_evaluate_net=$(echo ${job_evaluate_net} | awk '{split($0, a, " "); print a[4]}')
    printf " ${job_id_evaluate_net}" >> ${p_out_tmp}scancel.txt
    elif (( ${flag_slurm} == "OFF" ))
    then
      ${p_src_code}wrapper/evaluate_network.sh \
        --p_in_dir_net ${p_out_net} \
            --p_in_dir_net ${p_out_net} \
            --p_in_reg ${p_in_reg} \
            --p_in_target ${p_in_target} \
            --p_in_binding_event ${p_in_binding_event} \
            --flag_slurm ${flag_slurm} \
            --p_src_code ${p_src_code} \
            --p_out_file_eval ${p_out_net}evaluation.tsv \
            --l_fname_net ${l_fname_net[@]} \
            --l_p_in_net ${l_p_in_net[@]}
    fi
fi

# ======================================================================================================= #
# |                                   *** END EVALUATE NETWORKS ***                                     | #
# ======================================================================================================= #
job_id_ldb_concat_with_without_de=1
job_id_ldbp_concat_with_without_de=1
if [ ${flag_analyze_predictors} == "ON" ] || [ ${flag_run_all} == "ON" ]
then
    if [ ${flag_slurm} == "ON" ]
    then
#         while [ ! -f ${p_out_tmp}combine_net_ldb/job_id_concat_with_without_de.txt ] || [ ! -f ${p_out_tmp}combine_net_ldbp/job_id_concat_with_without_de.txt ]
#         do
#             sleep 60
#         done 
#         job_id_ldb_concat_with_without_de=$(<${p_out_tmp}combine_net_ldb/job_id_concat_with_without_de.txt)
#         job_id_ldbp_concat_with_without_de=$(<${p_out_tmp}combine_net_ldbp/job_id_concat_with_without_de.txt)
    
        l_p_dir_combine=(6 ${p_out_tmp}combine_net_ldbp/with_de/ ${p_out_tmp}combine_net_ldbp/without_de/ ${p_out_tmp}combine_net_ldb/with_de/ ${p_out_tmp}combine_net_ldb/without_de/ ${p_out_tmp}combine_net_ldbp/with_de/top_${l_top_edges_1[3]}/ ${p_out_tmp}combine_net_ldbp/without_de/top_${l_top_edges_2[3]}/)
        l_p_dir_analysis=(6 ${p_out_net}analysis_predictors_ldbp_with_de.txt ${p_out_net}analysis_predictors_ldbp_without_de.txt ${p_out_net}analysis_predictors_ldb_with_de.txt ${p_out_net}analysis_predictors_ldb_without_de.txt ${p_out_net}analysis_predictors_ldbp_with_de_top_${l_top_edges_1[3]}.txt ${p_out_net}analysis_predictors_ldbp_without_de_top_${l_top_edges_2[3]}.txt)
        job_analysis_predictors=$(sbatch \
                                  -o ${p_out_logs}${data}/analyze_predictors_%J.out \
                                  -e ${p_out_logs}${data}/analyze_predictors_%J.err \
                                  -J ${data}_analyze_predictors \
                                  --dependency=afterok:${job_id_ldb_concat_with_without_de}:${job_id_ldbp_concat_with_without_de} \
                                  ${p_src_code}wrapper/analyze_predictors.sh \
                                      --l_p_dir_combine ${l_p_dir_combine[@]} \
                                      --l_p_dir_analysis ${l_p_dir_analysis[@]} \
                                      --flag_slurm ${flag_slurm} \
                                      --p_src_code ${p_src_code})
    job_id_analysis_predictors=$(echo ${job_analysis_predictors} | awk '{split($0, a, " "); print a[4]}')
    printf " ${job_id_analysis_predictors}" >> ${p_out_tmp}scancel.txt                                         
    else
        ${p_src_code}wrapper/analyze_predictors.sh \
            --l_p_dir_combine ${p_out_tmp}combine_net_ldbp/
    fi
fi