# ********************************************************************** #
# |                   *** Worflow Functions ***                        | #
# | These functions are specific modules/parts of the workflow         | #
# ********************************************************************** #

# ====================================================================== #
# |                  *** Start of prepare_data ***                     | #
# ====================================================================== #
prepare_data = function(p_in_expr_target
                        , p_in_expr_reg
                        , nbr_target_optimize
                        , seed
                        , p_src_code){
  # load libraries
  source(paste(p_src_code, 'src/helper/prepare_data_generate_allowed_perturbed_and_scale_normalize.R', sep=''))
  
  # read data
  df_expr_target = read.csv(p_in_expr_target, header=TRUE, row.names=1, sep='\t', check.names=FALSE)
  rownames(df_expr_target) = lapply(rownames(df_expr_target), function(r) gsub('-', '_', r))
  
  df_expr_reg = read.csv(p_in_expr_reg, header=TRUE, row.names=1, sep='\t', check.names=FALSE)
  rownames(df_expr_reg) = lapply(rownames(df_expr_reg), function(r) gsub('-', '_', r))
  
  l_target = rownames(df_expr_target)
  l_reg = rownames(df_expr_reg)
  l_sample = colnames(df_expr_target)
  
  # generate allowed matrix
  df_allowed = as.matrix(generate_allowed_perturbed_matrices(l_in_target=l_target
                                                             , l_in_reg=l_reg
                                                             , l_in_sample=l_sample
                                                             , NULL
                                                             , p_src_code=p_src_code)[[1]])
  
  # expression matrix for optimization
  set.seed(seed)
  l_target_optimize = sample(l_target, nbr_target_optimize)
  df_expr_target_optimize = df_expr_target[l_target_optimize, ]
  
  # prepare data in the appropriate format for processing
  data = list()
  data[[1]] = t(df_expr_target)
  data[[2]] = t(df_expr_reg)
  data[[3]] = df_allowed
  data[[4]] = t(df_expr_target_optimize)
  
  data
}
# ====================================================================== #
# |                   *** End of prepare_data ***                      | #
# ====================================================================== #

# ====================================================================== #
# |                 *** Start of get_all_lambdas ***                   | #
# ====================================================================== #
get_all_lambdas = function(ys
                            , x
                            , alpha
                            , nlambda
                            , nbr_rmpi_slave
                            , df_allowed){
  
  train_to_get_lambdas = function(idx_per_slave){
    library("glmnet")
    nbr_slave = mpi.comm.rank()
    idx = idx_per_slave[[nbr_slave]]
    
    
    l_lambda = c()
    for (i in idx){
      df_allowed_x = x
      df_allowed_x[, which(df_allowed[, i] == 0)] = 0
      model = glmnet(x=df_allowed_x
                     , y=ys[, i]
                     , nlambda=nlambda
                     , alpha=alpha
                     , intercept = FALSE)
      l_lambda = c(l_lambda, model$lambda)
      gc()
    }
    
    l_lambda
  }
  
  # divide targets per number of allocated slaves
  idx_per_slave = suppressWarnings(split(seq(dim(ys)[2]), seq(nbr_rmpi_slave)))
  
  # mpi.spawn.Rslaves(nslaves=nbr_rmpi_slave)
  mpi.bcast.Robj2slave(x)
  mpi.bcast.Robj2slave(ys)
  mpi.bcast.Robj2slave(alpha)
  mpi.bcast.Robj2slave(nlambda)
  mpi.bcast.Robj2slave(df_allowed)
  mpi.bcast.Robj2slave(train_to_get_lambdas)
  l_slave = mpi.remote.exec(train_to_get_lambdas
                            , idx_per_slave
                            , simplify=FALSE
                            , comm=1
                            , ret=TRUE)
  # mpi.close.Rslaves()
  l_lambda = c()
  for (idx in seq(nbr_rmpi_slave)){
    l_lambda = c(l_lambda, l_slave[[idx]])
  }
  l_lambda
}
# ====================================================================== #
# |                  *** End of get_all_lambdas ***                    | #
# ====================================================================== #

# ====================================================================== #
# |              *** Start of select_optimal_lambdas ***               | #
# ====================================================================== #
select_optimal_lambda = function(ys
                                 , x
                                 , alpha
                                 , l_lambda
                                 , df_allowed
                                 , nbr_rmpi_slave
                                 , nbr_fold
                                 ){
  train_test_and_calculate_se = function(idx_per_slave){
    library("glmnet")
    nbr_slave = mpi.comm.rank()
    idx = idx_per_slave[[nbr_slave]]
    l_se = list()
    for (i in seq(idx)){
      # get data from the ith job
      job_idx = idx[[i]]
      data = l_job[[job_idx]]
      target = data$target
      testing_idx = data$testing_idx
      
      # allow only regulators different from target as predictor
      df_allowed_x = x
      df_allowed_x[, which(df_allowed[, target]==0)] = 0
      
      # training data
      df_training_x = df_allowed_x[-testing_idx, ]
      df_training_y = ys[-testing_idx, target]
      
      # testing data
      df_testing_x = df_allowed_x[testing_idx, ]
      df_testing_y = ys[testing_idx, target]
      
      # train
      model = glmnet(x=df_training_x
                     , y=df_training_y
                     , lambda=l_lambda
                     , alpha=alpha
                     , intercept = FALSE)
      # test/predict
      df_pred = predict(model, df_testing_x)
      
      # calculate se
      se = (df_pred - df_testing_y)**2
      
      l_se[[i]] = colSums(se)
      gc()
    }
    rowSums(data.frame(l_se))
  }
  l_job = list()
  l_fold = cut(seq(1, dim(ys)[1]), breaks=nbr_fold, label=FALSE)
  l_target = colnames(ys)
  for (idx_target in seq(length(l_target))){
    for (fold in seq(nbr_fold)){
      target = l_target[idx_target]
      l_job[[paste(target, 'fold', fold, sep='_')]]['target'] = target
      l_job[[paste(target, 'fold', fold, sep='_')]]['testing_idx'] = list(which(l_fold==fold, arr.ind=TRUE))
    }
  }
  
  # divide jobs on slaves
  idx_per_slave = suppressWarnings(split(seq(length(l_job)), seq(nbr_rmpi_slave)))
  
  # allocate slaves and send variables
  # mpi.spawn.Rslaves(nslaves=nbr_rmpi_slave)
  mpi.bcast.Robj2slave(alpha)
  mpi.bcast.Robj2slave(l_lambda)
  mpi.bcast.Robj2slave(df_allowed)
  mpi.bcast.Robj2slave(nbr_fold)
  mpi.bcast.Robj2slave(x)
  mpi.bcast.Robj2slave(ys)
  mpi.bcast.Robj2slave(l_job)
  mpi.bcast.Robj2slave(train_test_and_calculate_se)
  
  # execute cmd for train_test_and_calculate_se
  l_slave = mpi.remote.exec(train_test_and_calculate_se
                            , idx_per_slave
                            , simplify=TRUE
                            , comm=1
                            , ret=TRUE)
  
  # mpi.close.Rslaves()

  l_se = rowSums(data.frame(l_slave))
  optimal_lambda_idx = which(l_se == min(l_se))
  optimal_lambda = l_lambda[optimal_lambda_idx]
  optimal_lambda
}
# ====================================================================== #
# |              *** End of select_optimal_lambdas ***                 | #
# ====================================================================== #


# ====================================================================== #
# |         *** Start of build_network_with_optimal_lambda ***         | #
# ====================================================================== #
build_network_with_optimal_lambda = function(ys
                                             , x
                                             , alpha
                                             , df_allowed
                                             , optimal_lambda
                                             , nbr_rmpi_slave){
  train_and_get_coefficients = function(idx_per_slave){
    library("glmnet")
    nbr_slave = mpi.comm.rank()
    idx = idx_per_slave[[nbr_slave]]
    l_l_coef = list()
    for (i in idx){
      # prepare data
      target = colnames(ys)[i]
      y = ys[, i]
      df_allowed_x = x
      df_allowed_x[, which(df_allowed[, target]==0)] = 0
      
      # train
      model = glmnet(x=df_allowed_x
                     , y=y
                     , alpha=alpha
                     , lambda=optimal_lambda
                     , intercept=FALSE)
      l_l_coef[[target]] = rep(0, dim(x)[2])
      l_coef = model$beta@x
      l_idx = model$beta@i
      for (j in seq(length(l_coef))){
        coef_idx = l_idx[[j]] + 1
        coef = l_coef[[j]]
        l_l_coef[[target]][[coef_idx]] =  coef
      }
      gc()
    }
    data.frame(l_l_coef)
  }
  
  idx_per_slave = suppressWarnings(split(seq(dim(ys)[2]), seq(nbr_rmpi_slave)))
  
  # mpi.spawn.Rslaves(nslaves=nbr_rmpi_slave)
  mpi.bcast.Robj2slave(ys)
  mpi.bcast.Robj2slave(x)
  mpi.bcast.Robj2slave(df_allowed)
  mpi.bcast.Robj2slave(alpha)
  mpi.bcast.Robj2slave(optimal_lambda)
  mpi.bcast.Robj2slave(train_and_get_coefficients)
  l_slave = mpi.remote.exec(train_and_get_coefficients
                            , idx_per_slave
                            , simplify=TRUE
                            , comm=1
                            , ret=TRUE)
  
  # mpi.close.Rslaves()
  
  df_net = l_slave[[1]]
  for (slave_idx in seq(2, nbr_rmpi_slave, 1)){
    df_net = cbind(df_net, l_slave[[slave_idx]])
  }
  
  df_net = df_net[, colnames(ys)]  # reindex the targets in the final network
  
  df_net
  
}

# ====================================================================== #
# |         *** End of build_network_with_optimal_lambda ***         | #
# ====================================================================== #

# ********************************************************************** #
# |                  *** End Worflow Functions ***                     | #
# ********************************************************************** #


# ********************************************************************** #
# |                         *** Workflow ***                           | #                      
# ********************************************************************** #
build_network = function(# Input
                        p_in_expr_target
                        , p_in_expr_reg
                        , alpha
                        , nlambda
                        , nbr_target_optimize
                        , nbr_fold
                        
                        # Output
                        , p_out_dir
                        , f_out_name
                        
                        # Logistics
                        , p_src_code
                        , seed
                        
                        # Distributed/Parallel computation
                        , nbr_rmpi_slave){
  library("Rmpi")
  
  # prepare data
  data = prepare_data(p_in_expr_target=p_in_expr_target
                      , p_in_expr_reg=p_in_expr_reg
                      , nbr_target_optimize=nbr_target_optimize
                      , seed=seed
                      , p_src_code)
  
  df_expr_target = data[[1]]
  df_expr_reg = data[[2]]
  df_allowed = data[[3]]
  df_expr_target_optimize = data[[4]]
  
  mpi.spawn.Rslaves(nslaves=nbr_rmpi_slave)
  # get all lambdas
  print('get all lambdas..')
  l_lambda = get_all_lambdas(ys=df_expr_target_optimize
                             , x=df_expr_reg
                             , nbr_rmpi_slave=nbr_rmpi_slave
                             , alpha=alpha
                             , nlambda=nlambda
                             , df_allowed=df_allowed)

  # select optimimal lambda
  print('select optimal lambda..')
  optimal_lambda = select_optimal_lambda(ys=df_expr_target_optimize
                                         , x=df_expr_reg
                                         , alpha=alpha
                                         , df_allowed=df_allowed
                                         , l_lambda=l_lambda
                                         , nbr_rmpi_slave=nbr_rmpi_slave
                                         , nbr_fold=nbr_fold)

  cat('optimal lambda: ', optimal_lambda, '\n')
  # use this optimal lambda to build the network
  print('build network with optimal lambda')
  df_net = build_network_with_optimal_lambda(ys=df_expr_target
                                             , x=df_expr_reg
                                             , alpha=alpha
                                             , df_allowed=df_allowed
                                             , optimal_lambda=optimal_lambda
                                             , nbr_rmpi_slave=nbr_rmpi_slave)
  mpi.close.Rslaves()
  
  # write network
  write.table(df_net
              , file.path(p_out_dir,f_out_name)
              , row.names=lapply(colnames(df_expr_reg), function(r) gsub('_', '-', r))
              , col.names=lapply(colnames(df_net), function(r) gsub('_', '-', r))
              , quote=FALSE
              , sep='\t'
              )
  
}

# ********************************************************************** #
# |                      *** End Workflow ***                          | #                      
# ********************************************************************** #

# ********************************************************************** #
# |                     *** Bash Function ***                          | #
# ********************************************************************** #
if (sys.nframe() == 0){
  
  # ====================================================== #
  # |          *** load required libraries ***           | #
  # ====================================================== #
  library("optparse")
  
  # ====================================================== #
  # |               *** Parse Arguments ***              | #
  # ====================================================== #
  opt_parser = OptionParser(option_list=list(
    # Input
    p_in_expr_target = make_option(c("--p_in_expr_target"), type="character", help="expression of target genes")
    , p_in_expr_reg = make_option(c("--p_in_expr_reg"), type="character", help="expression of regulators")
    , flag_lasso_ridge = make_option(c("--flag_lasso_ridge"), type="character", help="LASSO or RIDGE")
    
    # Input for optimization
    , nbr_lambda = make_option(c("--nbr_lambda"), type="integer", help="number of lambdas for LASSO/RIDGE")
    , nbr_target_optimize = make_option(c("--nbr_target_optimize"), type="integer", help="number of targets that will be used for selecting optimal lambda ")
    , nbr_fold = make_option(c("--nbr_fold"), type="integer", help="number of fold used in optimization")
    
    # Output
    , p_out_dir = make_option(c("--p_out_dir"), type="character", help="path for output directory")
    , f_out_name = make_option(c("--f_out_name"), type="character", help="name for output file")
    
    # Logistics
    , p_src_code = make_option(c("--p_src_code"), type="character", help="path of source code")
    , seed = make_option(c("--seed"), type="integer", help="setting up seed for reproducibility")
    
    # Distributed/Parallel Computation
    , nbr_rmpi_slave = make_option(c("--nbr_rmpi_slave"), type="integer", help="number of Rmpi slaves for allocation")
  ))
  
  opt = parse_args(opt_parser, positional_arguments=TRUE)$options
  
  # Build network
  build_network(# Input
                p_in_expr_target=opt$p_in_expr_target
                , p_in_expr_reg=opt$p_in_expr_reg
                , alpha=if (opt$flag_lasso_ridge == 'lasso') 1 else 0
                , nlambda=opt$nbr_lambda
                , nbr_target_optimize=opt$nbr_target_optimize
                , nbr_fold=opt$nbr_fold
                
                # Output
                , p_out_dir=opt$p_out_dir
                , f_out_name=opt$f_out_name
                
                # Logistics
                , p_src_code=opt$p_src_code
                , seed=opt$seed
                
                # Distributed/Parallel computation
                , nbr_rmpi_slave=opt$nbr_rmpi_slave
                )
}
# ********************************************************************** #
# |                    *** End Bash Function ***                       | #
# ********************************************************************** #