apply_default_coefficients = function(l_coef
                                      , p_model
                                      , l_in_name_net
                                      , l_in_path_net
                                      , p_out_net
                                      , model_name){
  library("mlr")
  
  df_data = read_data(model_name=model_name
                      , l_name_net=l_in_name_net
                      , l_path_net=l_in_path_net)
  print(df_data)
  # if (p_model != "NONE"){
  #     model = readRDS(p_model)
  #     df_pred = predict(model, df_data, type="response")
  # }else if (l_coef != "NONE"){
  #     library("e1071")
  #     df_pred = sigmoid(colSums(t(data.frame(rep(1, dim(df_data)[1]), df_data)) * l_coef))
  # }
  fact_col = colnames(df_data)[sapply(df_data, is.character)]
  for(i in fact_col) set(df_data, j=i, value=factor(df_data[[i]]))
  task = makeClassifTask(data=data.frame(df_data, target=factor(rep(1, dim(df_data)[1]))), target="target")
  
  model = readRDS(p_model)
  df_pred = predict(model, task)$data$prob.1
  
  p_net = l_in_path_net[1]
  df_net = read.csv(p_net, header=FALSE, sep='\t')
  l_reg = df_net[1]
  l_target = df_net[2]
  
  write.table(file=file(p_out_net)
              , x=data.frame(REGULATOR=l_reg, TARGET=l_target, VALUE=df_pred)
              , row.names=FALSE, col.names=FALSE, sep="\t", quote=FALSE)
  
}


if (sys.nframe() == 0){
    library("optparse")
    
    opt_parser = OptionParser(option_list=list(
        #Input
        l_in_name_net = make_option(c("--l_in_name_net"), type="character", help="list of name of networks separated by comma")
        , l_in_path_net = make_option(c("--l_in_path_net"), type="character", help="list of path of networks separated by comma")
        , in_model_name = make_option(c("--in_model_name"), type="character", help="model for combination")
        , in_coef = make_option(c("--in_coef"), type="character", default="NONE", help="a string coding list of coefficients encoded in a string: c(1,3,..) ")
        , p_in_model = make_option(c("--p_in_model"), type="character", default="NONE", help="path of model (R object)")
        
        # Output
        , p_out_net = make_option(c("--p_out_net_np3"), type="character", help="path of file for output network")
        
        # Logistics
        , p_src_code = make_option(c("--p_src_code"), type="character", help="path of the source code")
    ))
  
    opt = parse_args(opt_parser, positional_arguments=TRUE)$options
  
    source(paste(opt$p_src_code, "src/combine_networks/code/helper/read_networks_into_data_frame.R", sep=""))
    
       apply_default_coefficients(l_coef=eval(parse(text=opt$in_coef))
                              , p_model=opt$p_in_model
                              , l_in_name_net=strsplit(opt$l_in_name_net, ',')[[1]]
                              , l_in_path_net=strsplit(opt$l_in_path_net, ',')[[1]]
                              , p_out_net=opt$p_out_net_np3
                              , model_name=opt$in_model_name) 
}