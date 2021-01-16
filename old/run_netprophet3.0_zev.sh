#!/bin/bash
l_top=(5 454736 227368 227368 56842 15100)
#l_top=(56842 15100)
p_wd=/scratch/mblab/dabid/netprophet/
./netprophet3.0.sh \
  -c -e \
  --p_in_target ${p_wd}net_in/sub_in_target_6023 \
  --p_in_reg ${p_wd}net_in/sub_in_reg_tf_151 \
  --p_in_sample ${p_wd}net_in/zev_in_condition_591 \
  --p_in_expr_target ${p_wd}net_in/sub2_zev_expr_6023_591 \
  --p_in_expr_reg ${p_wd}net_in/sub2_zev_expr_reg_151_591 \
  --flag_slurm "ON" \
  --p_out_logs ${p_wd}net_logs/ \
  --p_out_dir ${p_wd}net_out/zev_netprophet3_no_exclude_tf_with_inclusive_binding/ \
  --data zev \
  --flag_global_shrinkage "ON" \
  --flag_local_shrinkage "OFF" \
  --model "netprophet" \
  --p_in_net_de ${p_wd}net_in/sub2_zev_de_shrunken_151_6023 \
  --p_in_binding_event ${p_wd}data_binding/reg_target_cc_exo_chip_inclusive_only_cc_exo.txt \
  --l_count_top ${l_top[@]} \
  --p_in_net_lasso ${p_wd}net_out/zev_netprophet3_new/net/net_lasso.tsv \
  --p_in_net_bart ${p_wd}net_out/zev_netprophet3_new/net/net_bart

