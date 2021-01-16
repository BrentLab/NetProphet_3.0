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
    --model                  : name of the model for combining networks
    --l_count_top            : array for feed forward run such (3000 2000 1000)
    
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

# BART arguments
fname_net_bart=net_bart

# COMBINATION arguments
nbr_cv_fold=10
l_count_top="NONE"

# OUTPUT argunments
fname_net_np3=net_np3_b.tsv

# pwm arguments
fname_net_pwm=net_pwm.tsv

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
# ------------------------------------------------------------------------------------- #
# |                   *** Read arguments provided by the user ***                     | #
# ------------------------------------------------------------------------------------- #
while getopts ":hlbckme-:" OPTION
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
        p_in_promoter)
          p_in_promoter="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
        p_out_logs)
          p_out_logs="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        mail_type)
          mail_type="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        mail_user)
          mail_user="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        l_count_top)
          l_count_top=()
          narg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
          for (( i=1;i<`expr ${narg}+1`;i++ ))
          do
            arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
            l_count_top+=("${arg}")
          done
          ;;
        data)
          data="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        
      esac;;
    

    esac
done

# ======================================================================================================= #
# |                                    **** END PARSE ARGUMENTS ****                                    | #
# ======================================================================================================= #

# create the output directory if it doesn't exist
mkdir -p ${p_out_dir}

p_out_tmp=${p_out_dir}tmp/
mkdir -p ${p_out_tmp}

p_out_net=${p_out_dir}net/
mkdir -p ${p_out_net}

mkdir -p ${p_out_tmp}motif_inference/
mkdir -p ${p_out_tmp}motif_inference/network_bins/
mkdir -p ${p_out_tmp}motif_inference/motifs_pfm/
mkdir -p ${p_out_tmp}motif_inference/motifs_score/

# ======================================================================================================= #
# |                                   *** GENERATE LASSO NETWORK ***                                    | #
# ======================================================================================================= #
job_id_lasso=1

if [ ${flag_run_lasso} == "ON" ] || [ ${flag_run_all} == "ON" ]
then

    p_net_lasso=${p_out_net}${fname_net_lasso}
    if (( ${flag_slurm} == "ON" ))
    then
    job_lasso=$(sbatch \
      --mail-type=${mail_type} \
      --mail-user=${mail_user} \
      -J ${data}_lasso \
      -o ${p_out_logs}${data}_lasso_%J.out \
      -e ${p_out_logs}${data}_lasso_%J.err \
      -n 11 \
      -D ${p_src_code}code/netprophet1/ \
      --mem-per-cpu=10GB \
      --cpus-per-task=2 \
      ${p_src_code}wrapper/lasso.sh \
        ${p_in_target} \
        ${p_in_reg} \
        ${p_in_sample} \
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

    elif (( ${flag_slurm} == "OFF" ))
    then
    ${p_src_code}wrapper/lasso.sh \
      ${p_in_target} \
      ${p_in_reg} \
      ${p_in_sample} \
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
      ${p_src_code}wrapper/bart.sh \
      ${p_in_target} \
      ${p_in_reg} \
      ${p_in_expr_target} \
      ${p_in_sample} \
      ${p_out_net}\
      ${fname_net_bart} \
      ${flag_slurm} \
      ${p_src_code})
    job_id_bart=$(echo ${job_bart} | awk '{split($0, a, " "); print a[4]}')
    elif ((${flag_slurm} == "OFF"))
    then
    ${p_src_code}wrapper/bart.sh \
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

 
 
# ======================================================================================================= #
# |                                       *** COMBINE NETWORKS ***                                      | #
# ======================================================================================================= #
job_id_combine_net=1
if [ ${flag_run_combine} == "ON" ] || [ ${flag_run_all} == "ON" ]
then
    if (( ${flag_slurm} == "ON" ))
    then
      job_combine_net=$(sbatch \
          --mail-type=${mail_type} \
          --mail-user=${mail_user} \
          -J ${data}_combine_net_a \
          -o ${p_out_logs}${data}_combine_net_%J.out \
          -e ${p_out_logs}${data}_combine_net_%J.err \
          --dependency=afterany:${job_id_lasso}:${job_id_bart} \
          ${p_src_code}wrapper/combine_networks_flag_feed_forward.sh \
            --p_out_tmp ${p_out_tmp} \
            --p_out_net ${p_out_net} \
            --p_net_lasso ${p_net_lasso} \
            --p_net_bart ${p_net_bart} \
            --p_net_de ${p_in_net_de} \
            --p_in_binding_event ${p_in_binding_event} \
            --model ${model} \
            --p_src_code ${p_src_code} \
            --p_net_np3 ${p_out_net}net_np3_a.tsv \
            --flag_slurm ${flag_slurm} \
            --seed ${seed} \
            --p_in_reg ${p_in_reg} \
            --p_in_target ${p_in_target} \
            --l_count_top "NONE")

      job_id_combine_net=$(echo ${job_combine_net} | awk '{split($0, a, " "); print a[4]}')

    elif (( ${flag_slurm} == "OFF" ))
    then
      ${p_src_code}wrapper/combine_networks_flag_feed_forward.sh \
        --p_out_tmp ${p_out_tmp} \
        --p_out_net ${p_out_net} \
        --p_net_lasso ${p_out_net}${fname_net_lasso} \
        --p_net_bart ${p_out_net}${fname_net_bart} \
        --p_net_de ${p_in_net_de} \
        --p_in_binding_event ${p_in_binding_event} \
        --model ${model} \
        --p_src_code ${p_src_code} \
        --p_net_np3 ${p_out_net}net_np3_a.tsv \
        --flag_slurm ${flag_slurm} \
        --seed ${seed} \
        --p_in_reg ${p_in_reg} \
        --p_in_target ${p_in_target} \
        --l_count_top "NONE"
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
    num_regulators=$(wc -l ${p_in_reg} | cut -d" " -f1)
    if (( ${flag_slurm} == "ON" ))
    then
        p_in_net_pwm=${p_out_net}${fname_net_pwm}
        # infer motifs
        job_infer_pwm=$(sbatch \
        --mail-type=${mail_type} \
        --mail-user=${mail_user} \
        -o ${p_out_logs}${data}_infer_pwm_%A_%a.out \
        -e ${p_out_logs}${data}_infer_pwm_%A_%a.err \
        -J ${data}_infer_pwm \
        --array=1-${num_regulators}%48 \
        --dependency=afterany:${job_id_combine_net} \
        ${p_src_code}wrapper/infer_motifs.sh \
        ${p_out_tmp} \
        ${p_out_net}net_np3_a.tsv \
        ${p_in_reg} \
        ${p_in_target} \
        ${p_in_promoter} \
        ${p_out_tmp}flag_infer_motifs \
        ${flag_slurm} \
        ${p_src_code})
        job_id_infer_pwm=$(echo ${job_infer_pwm} | awk '{split($0, a, " "); print a[4]}')

        # score motifs
        job_score_pwm=$(sbatch \
        --mail-type=${mail_type} \
        --mail-user=${mail_user} \
        -o ${p_out_logs}${data}_score_pwm_%A_%a.out \
        -e ${p_out_logs}${data}_score_pwm_%A_%a.err \
        -J ${data}_score_pwm \
        --array=1-${num_regulators}%48 \
        --dependency=afterany:${job_id_infer_pwm} \
        ${p_src_code}wrapper/score_motifs.sh \
        ${p_out_tmp} \
        ${p_out_tmp}motif_inference/network_bins/ \
        ${p_in_reg} \
        ${p_in_promoter} \
        ${p_out_tmp}motif_inference/motifs.txt \
        ${p_out_tmp}flag_score_motifs \
        ${flag_slurm} \
        ${p_src_code})
        job_id_score_pwm=$(echo ${job_score_pwm} | awk '{split($0, a, " "); print a[4]}')
    
        # build pwm network
        p_in_net_pwm=${p_out_net}${fname_net_pwm}
        job_build_pwm_net=$(sbatch \
        --mail-type=${mail_type} \
        --mail-user=${mail_user} \
        -o ${p_out_logs}${data}_build_pwm_net_%A.out \
        -e ${p_out_logs}${data}_build_pwm_net_%A.err \
        -J ${data}_build_pwm_net \
        --dependency=afterany:${job_id_score_pwm} \
        ${p_src_code}wrapper/motif.sh \
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
        
    elif (( ${flag_slurm} == "OFF" ))
    then
        # infer motifs
        ${p_src_code}wrapper/run_infer_motifs.sh \
            ${p_out_tmp} \
            ${p_out_net}${fname_net_np3} \
            ${p_in_reg} \
            ${p_in_target} \
            ${p_in_promoter} \
            ${p_out_tmp}flag_infer_motifs \
            true
            
        # score motifs
        ${p_src_code}wrapper/run_score_motifs.sh \
            ${p_out_tmp} \
            ${p_out_tmp}motif_inference/network_bins/ \
            ${p_in_reg} \
            ${p_in_promoter} \
            ${p_out_tmp}motif_inference/motifs.txt \
            ${p_out_tmp}flag_score_motifs \
            true 
            
        # build motif network
        ${p_src_code}wrapper/build_motif_network_wrap.sh \
            ${p_out_tmp}motif_inference/motifs.txt \
            ${p_in_reg} \
            ${p_in_target} \
            ${p_out_tmp}motif_inference/motifs_score/ \
            robust \
            16 \
            ${p_in_net_pwm}
       
    fi
fi

# ======================================================================================================= #
# |                                  *** END GENERATE PWM NETWORK ***                                   | #
# ======================================================================================================= #


# ======================================================================================================= #
# |                                       *** COMBINE NETWORKS ***                                      | #
# |                                         combine the PWM network                                     | #
# ======================================================================================================= #
job_id_combine_net_pwm=1
if [ ${flag_run_combine_pwm} == "ON" ] || [ ${flag_run_all} == "ON" ]
then
    if (( ${flag_slurm} == "ON" ))
    then
      job_combine_net_pwm=$(sbatch \
          --mail-type=${mail_type} \
          --mail-user=${mail_user} \
          -J ${data}_combine_net_b \
          -o ${p_out_logs}${data}_combine_net_%J.out \
          -e ${p_out_logs}${data}_combine_net_%J.err \
          --dependency=afterany:${job_id_lasso}:${job_id_bart}:${job_id_build_pwm_net} \
          ${p_src_code}wrapper/combine_networks_flag_feed_forward.sh \
            --p_out_tmp ${p_out_tmp} \
            --p_out_net ${p_out_net} \
            --p_net_lasso ${p_net_lasso} \
            --p_net_bart ${p_net_bart} \
            --p_net_de ${p_in_net_de} \
            --p_net_pwm ${p_in_net_pwm} \
            --p_in_binding_event ${p_in_binding_event} \
            --model ${model} \
            --p_src_code ${p_src_code} \
            --p_net_np3 ${p_out_net}${fname_net_np3} \
            --flag_slurm ${flag_slurm} \
            --seed ${seed} \
            --p_in_reg ${p_in_reg} \
            --p_in_target ${p_in_target} \
            --l_count_top ${l_count_top[@]})

      job_id_combine_net_pwm=$(echo ${job_combine_net_pwm} | awk '{split($0, a, " "); print a[4]}')

    elif (( ${flag_slurm} == "OFF" ))
    then
      ${p_src_code}wrapper/combine_networks_flag_feed_forward.sh \
        --p_out_tmp ${p_out_tmp} \
        --p_out_net ${p_out_net} \
        --p_net_lasso ${p_out_net}${fname_net_lasso} \
        --p_net_bart ${p_out_net}${fname_net_bart} \
        --p_net_de ${p_in_net_de} \
        --p_in_binding_event ${p_in_binding_event} \
        --model ${model} \
        --p_src_code ${p_src_code} \
        --p_net_np3 ${p_out_net}${fname_net_np3} \
        --flag_slurm ${flag_slurm} \
        --seed ${seed} \
        --p_in_reg ${p_in_reg} \
        --p_in_target ${p_in_target} \
        --l_count_top ${l_count_top[@]}
    fi
fi
# ======================================================================================================= #
# |                                   *** END COMBINE NETWORKS ***                                      | #
# ======================================================================================================= #



# ======================================================================================================= #
# |                                       *** EVALUATE NETWORKS ***                                     | #
# ======================================================================================================= #
if [ ${flag_run_eval} == "ON" ] || [ ${flag_run_all} == "ON" ]
then
    l_p_in_net=(3 ${p_net_lasso} ${p_in_net_de} ${p_net_bart})
    l_fname_net=(3 lasso de bart)
    if (( ${flag_slurm} == "ON" ))
    then
      job_evaluate_net=$(sbatch \
        --mail-type=${mail_type} \
        --mail-user=${mail_user} \
        -J ${data}_evaluate_net \
          -o ${p_out_logs}${data}_evaluate_net_%J.out \
          -e ${p_out_logs}${data}_evaluate_net_%J.err \
          --dependency=afterok:${job_id_combine_net_pwm} \
          ${p_src_code}wrapper/evaluate_network.sh \
            --p_in_dir_net ${p_out_net} \
            --p_in_reg ${p_in_reg} \
            --p_in_target ${p_in_target} \
            --p_in_binding_event ${p_in_binding_event} \
            --flag_slurm ${flag_slurm} \
            --p_src_code ${p_src_code} \
            --p_out_file_eval ${p_out_net}evaluation.tsv \
            --l_fname_net ${l_fname_net[@]} \
            --l_p_in_net ${l_p_in_net[@]})

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
