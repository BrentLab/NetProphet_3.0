build_gam_model_for_one_gene = function(x
                                       , y
                                       , df_allowed
                                       , target_id
                                       , df_test_Q0
                                       , df_test_Q100
                                       , smooth="s"){
  if (!require(mgcv)){
    install.packages("mgcv")
    library("mgcv")
  }
  # train gam model, then test for every reg with Q0 and Q100
  # create data frame for training data
  x_allowed = x
  x_allowed[, which(df_allowed==0)] = 0
  
  df_test_Q0_allowed = df_test_Q0
  df_test_Q0_allowed[, which(df_allowed==0)] = 0
  df_test_Q0_allowed[which(df_allowed==0), ] = 0
  
  df_test_Q100_allowed = df_test_Q100
  df_test_Q100_allowed[, which(df_allowed==0)] = 0
  df_test_Q100_allowed[which(df_allowed==0), ] = 0
  
  data_training = data.frame(cbind(y, x_allowed), check.names=FALSE)
  
  df_prediction = tryCatch({
    #if (smooth == "s"){
    # formula = paste("s(", colnames(data.frame(x_allowed)), sep="")
    # formula = paste(formula, ")", sep="")
    # formula = as.formula(paste(target_id, paste(formula, collapse = "+"), sep=" ~ "))
    # }
    # else{
    # # create formula for GAM model
    formula = paste("s(", colnames(data.frame(x_allowed)), sep="")
    formula = paste(formula, ", bs='cs', k=4)", sep="")
    formula = as.formula(paste(target_id, paste(formula, collapse="+"), sep=" ~ "))
    # }
    
    # train GAM model
    model = bam(formula, data=data_training, select=TRUE, nthreads = NA, gamma=1.4)
    
    # do the prediction for Q0 and Q100
    predict_Q0 = predict(model, df_test_Q0_allowed)
    predict_Q100 = predict(model, df_test_Q100_allowed)
    
    # the edges scores for network is the difference
    prediction = predict_Q0 - predict_Q100

  }, error = function(err){
    prediction = rep(0, dim(x)[2])

  }, finally ={

  })
  # package the prediction into dataframe
  df_prediction = data.frame(prediction)
  colnames(df_prediction) = target_id
  
  df_prediction
}

build_gam_model_for_list_of_genes = function(idx_per_process){
  rank = mpi.comm.rank()
  idx = idx_per_process[[rank]]
  df_prediction_all = data.frame(matrix(nrow=dim(x)[2], ncol=0))
  # rownames(df_prediction) = colnames(x)
  for (i in idx){
    df_y = data.frame(y[, i])
    target_id = as.character(colnames(y)[i])
    colnames(df_y)=target_id
    cat('target gene: ', i, 'name: ', target_id, '\n')
    df_prediction = build_gam_model_for_one_gene(x=x
                                             , y=df_y
                                             , df_allowed=df_allowed[, i]
                                             , target_id
                                             , df_test_Q0=df_test_Q0
                                             , df_test_Q100=df_test_Q100)
    df_prediction_all = cbind(df_prediction_all, df_prediction)
  }
  
  df_prediction_all
}

prepare_data = function(p_expr_target
                        , p_expr_reg
                        , nbr_processes
                        , p_src_code){
  if (!require(matrixStats)){
    install.packages("matrixStats")
    library("matrixStats")
  }
  source(paste(p_src_code, 'code/prepare_data_generate_allowed_perturbed_and_scale_normalize.R', sep=''))
  
  df_expr_target = read.csv(p_expr_target, header=TRUE, row.names=1, sep='\t', check.names = FALSE)
  rownames(df_expr_target) = lapply(rownames(df_expr_target), function(r) gsub("-", "_", r))
  
  df_expr_reg = read.csv(p_expr_reg, header=TRUE, row.names=1, sep='\t', check.names = FALSE)
  rownames(df_expr_reg) = lapply(rownames(df_expr_reg), function(r) gsub("-", "_", r))
  
  l_target = rownames(df_expr_target)
  total_target = length(l_target)
  l_reg = rownames(df_expr_reg)
  l_sample = colnames(df_expr_target)
  
  x = t(df_expr_reg)
  y = t(df_expr_target)
  
  # prepare testing data
  df_expr_Q = colQuantiles(x)
  df_expr_Q0 = t(df_expr_Q[, "0%"])
  df_expr_Q50 = t(df_expr_Q[, "50%"])
  df_expr_Q100 = t(df_expr_Q[, "100%"])
  
  df_test_Q0 = data.frame(lapply(df_expr_Q50, rep, length(l_reg)))
  colnames(df_test_Q0) = l_reg
  rownames(df_test_Q0) = l_reg
  
  df_test_Q100 = data.frame(lapply(df_expr_Q50, rep, length(l_reg)))
  colnames(df_test_Q100) = l_reg
  rownames(df_test_Q100) = l_reg
  
  for ( reg_id in l_reg){
    df_test_Q0[reg_id, reg_id] = df_expr_Q0[, reg_id]
    df_test_Q100[reg_id, reg_id] = df_expr_Q100[, reg_id]
  }
  
  # generate allowed matrix
  df_allowed = as.matrix(generate_allowed_perturbed_matrices(l_in_target=l_target
                                                             , l_in_reg=l_reg
                                                             , l_in_sample=l_sample
                                                             , NULL
                                                             , p_src_code=p_src_code)[[1]])
  data = c()
  data[[1]] = x
  data[[2]] = y
  data[[3]] = df_test_Q0
  data[[4]] = df_test_Q100
  data[[5]] = df_allowed
  data[[6]] = total_target
  data[[7]] = l_reg
  data
}
generate_gam_net = function(p_expr_target
                			    , p_expr_reg
                			    , fname_gam
                			    , p_out_dir
                			    , nbr_processes
                			    , p_src_code){
    

   
    
    # prepare data
    data = prepare_data(p_expr_target=p_expr_target
                       , p_expr_reg=p_expr_reg
                       , nbr_processes=nbr_processes
                       , p_src_code=p_src_code)
    
    x = data[[1]]
    y = data[[2]]
    df_test_Q0 = data[[3]]
    df_test_Q100 = data[[4]]
    df_allowed = data[[5]]
    total_target = data[[6]]
    l_reg = data[[7]]

    # prepare indices for parallel/distributed processing
    idx_per_process = suppressWarnings(split(seq(total_target), seq(nbr_processes)))

    mpi.spawn.Rslaves(nslaves=nbr_processes)
    mpi.bcast.Robj2slave(x)
    mpi.bcast.Robj2slave(y)
    mpi.bcast.Robj2slave(df_test_Q0)
    mpi.bcast.Robj2slave(df_test_Q100)
    mpi.bcast.Robj2slave(df_allowed)
    mpi.bcast.Robj2slave(build_gam_model_for_one_gene)
    mpi.bcast.Robj2slave(build_gam_model_for_list_of_genes)
    l_slave = mpi.remote.exec(build_gam_model_for_list_of_genes, idx_per_process, simplify = FALSE, comm =1, ret =TRUE)
    mpi.close.Rslaves()
    
    # process the results from all slaves
    df_net = data.frame(matrix(nrow=dim(x)[2], ncol=0))
    for (i in seq(length(l_slave))){
        if (typeof(l_slave[[i]]) == "list"){
          df_net = cbind(df_net, l_slave[[i]])  
          }
    }
    
    # # write gam network
    rownames(df_net) = lapply(rownames(df_net), function(r) gsub("_", "-", r))
    colnames(df_net) = lapply(colnames(df_net), function(c) gsub("_", "-", c))
    write.table(df_net
                , file.path(p_out_dir, fname_gam)
                , row.names=rownames(df_net)
                , col.names=colnames(df_net)
                , quote=FALSE
                , sep="\t")
}


if (sys.nframe() == 0){
    # =========================================== #
    # |       *** Install packages ***          | #
    # =========================================== #
    if (!require(optparse)) {  # library for parsing arguments
        install.packages("optparse", repo="http://cran.rstudio.com/")
        library("optparse")
    }
    
    
    if (!require(Rmpi)){
      install.packages("Rmpi")
      library("Rmpi")
    }

    # =========================================== #
    # |         **** Parse Arguments ****       | #
    # =========================================== #
    p_expr_target = make_option(c("--p_expr_target"), type="character")
    p_expr_reg = make_option(c("--p_expr_reg"), type="character")
    fname_gam = make_option(c("--fname_gam"), type="character")
    p_out_dir = make_option(c("--p_out_dir"), type="character")
    nbr_processes = make_option(c("--nbr_processes"), type="integer")
    p_src_code = make_option(c("--p_src_code"), type="character")
    
    opt_parser = OptionParser(option_list=list(p_expr_target, p_expr_reg, fname_gam, p_out_dir, nbr_processes, p_src_code))
    opt = parse_args(opt_parser)

    quit(status=generate_gam_net(p_expr_target=opt$p_expr_target
                                 , p_expr_reg=opt$p_expr_reg
                        				 , fname_gam=opt$fname_gam
                        				 , p_out_dir=opt$p_out_dir
                        				 , nbr_processes=opt$nbr_processes
                        				 , p_src_code=opt$p_src_code))
}	
