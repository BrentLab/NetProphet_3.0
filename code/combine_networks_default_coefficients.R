apply_default_coefficients = function(l_coef
                                      , p_model
                                      , p_lasso
                                      , p_de
                                      , p_bart
                                      , p_pwm
                                      , p_out_net
                                      , model){
  
  df_data = read_data(model=model
                      , p_lasso=p_lasso
                      , p_de=p_de
                      , p_bart=p_bart
                      , p_pwm=p_pwm)

  if (p_model != "NONE"){
      model = readRDS(p_model)
      df_pred = predict(model, df_data, type="response")
  }else if (!is.null(l_coef)){
      library("e1071")
      df_pred = sigmoid(colSums(t(data.frame(rep(1, dim(df_data)[1]), df_data)) * l_coef))
  }
  
  
  if (!is.null(p_lasso) & p_lasso != "NONE"){
      df_lasso = read.csv(p_lasso, header=FALSE, sep="\t")
      if (length(colnames(df_lasso)) > 3){
          l_lasso = unlist(df_lasso)
      } else{
          l_reg = df_lasso[1]
          l_target = df_lasso[2]
      }
      
  }
  write.table(file=file(p_out_net)
              , x=data.frame(REGULATOR=l_reg, TARGET=l_target, VALUE=df_pred)
              , row.names=FALSE, col.names=FALSE, sep="\t", quote=FALSE)
  
}


if (sys.nframe() == 0){
  if (!require(optparse)){
    install.packages("optparse", repo="http://cran.rstudio.com/")
    library("optparse")
  }
  model = make_option(c("--model"), type="character", help="model for combination")
  p_in_lasso = make_option(c("--p_in_lasso"), type="character", default=NULL, help="path of LASSO file")
  p_in_de = make_option(c("--p_in_de"), type="character", default="NONE", help="path of DE file")
  p_in_bart = make_option(c("--p_in_bart"), type="character", default=NULL, help="path of BART file")
  p_in_pwm = make_option(c("--p_in_pwm"), type="character", default="NONE", help="path of PWM file")
  l_coef = make_option(c("--l_coef"), type="character", default="NULL", help="list of coefficients encoded in a string")
  p_model = make_option(c("--p_model"), type="character", default="NONE", help="path of model (R object)")
  p_out_net = make_option(c("--p_out_net"), type="character", help="path of file for output network")
  p_src_code = make_option(c("--p_src_code"), type="character", help="path of the source code")
  
  opt_parser = OptionParser(option_list=list(model
                                             , p_in_lasso
                                             , p_in_de
                                             , p_in_bart
                                             , p_in_pwm
                                             , l_coef
                                             , p_model
                                             , p_out_net
                                             , p_src_code))
  
  opt = parse_args(opt_parser)
  
  source(paste(opt$p_src_code, "code/combine_networks_read_files_into_data_frame.R", sep=""))
    
   apply_default_coefficients(l_coef=eval(parse(text=opt$l_coef))
                              , p_model=opt$p_model
                              , p_lasso=opt$p_in_lasso
                              , p_de=opt$p_in_de
                              , p_bart=opt$p_in_bart
                              , p_pwm=opt$p_in_pwm
                              , p_out_net=opt$p_out_net
                              , model=opt$model) 
}