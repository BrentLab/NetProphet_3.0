analysis_model = function(p_dir_combine
                          , p_out_file_analysis){
  # cat("p_dir_combine", p_dir_combine)
  # cat("p_out_file_analysis", p_out_file_analysis)
  # p_dir_combine="/scratch/mblab/dabid/netprophet/net_out/zev_np3_dummypenalizetransform_tf320_target6175/tmp/combine_net_ldbp/without_de/"
  library("Matrix")
  # unsupport
  model_unsupport = readRDS(paste(p_dir_combine, 'unsupport/data_pred/model.RData', sep=''))
  lambda_unsupport = as.double(read.table(paste(p_dir_combine, 'unsupport/data_pred/lambda.tsv', sep='')))
  beta_unsupport = model_unsupport$beta[, which(round(model_unsupport$lambda, digits=6)== round(lambda_unsupport, digits=6))]
  df_beta = data.frame(beta_unsupport)
  
  # support
  for (i in 0:9){
    model_support = readRDS(paste(p_dir_combine, 'support/data_pred/fold', i, '_model.RData', sep=''))
    lambda_support = as.double(read.table(paste(p_dir_combine, 'support/data_pred/fold', i, '_lambda.tsv', sep='')))
    beta_support = model_support$beta[, which(round(model_support$lambda, digits=6)== round(lambda_support, digits=6))]
    df_beta = cbind(df_beta, beta_support)
  }
  df_percentage = round(rowSums(df_beta != 0)*100/11, digits=0)
  df_mean = rowMeans(df_beta)
  
  write.table(file=file(p_out_file_analysis)
              , x=data.frame('percentage'=unlist(df_percentage), 'mean'=unlist(df_mean))
              , row.names=TRUE, col.names=TRUE, sep="\t", quote=FALSE)
}
if (sys.nframe() == 0){
  if (!require(optparse)){
    install.packages("optparse", repo="http://cran.rstudio.com/")
    library("optparse")
  }
  
  p_in_dir_combine = make_option(c("--p_dir_combine"), type="character", help="input forr path of directory for combine network results")
  p_out_file_analysis = make_option(c("--p_out_file_analysis"), type="character", help="output for path of file for analysis")
  opt_parser = OptionParser(option_list=list(p_in_dir_combine, p_out_file_analysis))
  
  opt = parse_args(opt_parser)
  
  
  
  analysis_model(p_dir_combine=opt$p_dir_combine
                 , p_out_file_analysis=opt$p_out_file_analysis)
}