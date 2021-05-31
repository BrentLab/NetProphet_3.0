# ======================================================================= #
# | This module build network with optimized regression models          | #
# | first select a set of target genes to optimize parameters with      | #
# | grid search, then use these optimized parameters to build an        | #
# | optimized network                                                   | #
# ======================================================================= #

# ======================================================================= #
# |                  *** General Helper functions ***                   | #
# ======================================================================= #

# --------------------------------------------------------------- #
# | **** start of train function ****                           | #
# | given the model name, data, and set of parameters, a cor-   | #
# | responding model is trained. if df_model_param == NULL      | #
# | default parameters are used.                                | #
# --------------------------------------------------------------- #
train = function(model_name
                 , df_training_x
                 , df_training_y
                 , df_model_param
                 , seed
){
  
  set.seed(seed)
  if (model_name == "bart"){
    library("BART")
    if (typeof(df_model_param) != "list"){
      ntree = 200
      k = 2
      sigdf = 3
      sigquant = 0.9
      cat("default parameters will be used: ntree: ", ntree, ", k: ", k, ", sigdf: ", sigdf, ", sigquant: ", sigquant)
    } else{
      ntree = df_model_param[['ntree']]
      k = df_model_param[['k']]
      sigdf = df_model_param[['sigdf']]
      sigquant = df_model_param[['sigquant']]
    }
    sink('/dev/null')
    model = wbart(x.train=as.matrix(df_training_x)
                  , y.train=as.double(t(df_training_y))
                  , ntree=ntree
                  , k=k
                  , sigdf=sigdf
                  , sigquant=sigquant
                  , rm.const=FALSE)
    sink()
  } else if (model_name == "xgboost"){
    
  }
  
  model
}
# --------------------------------------------------------------- #
# | **** End of train function ****                             | #
# --------------------------------------------------------------- #

# --------------------------------------------------------------- #
# | **** start of test function ****                            | #
# | given a model object, model name and testing set,           | #
# | predictions are returned.                                   | #
# --------------------------------------------------------------- #
test = function(model
                , model_name
                , df_testing_x){
  
  if (model_name == "bart"){
    library("BART")
    sink('/dev/null')
    df_prediction = predict(model, as.matrix(df_testing_x)) 
    sink()
    df_prediction = colMeans(df_prediction)
  } else if (model_name == "xgboost"){
    
  }
  df_prediction
}
# --------------------------------------------------------------- #
# | **** End of test function ****                              | #
# --------------------------------------------------------------- #

# ======================================================================= #
# |               *** End General Helper functions ***                  | #
# ======================================================================= #


# ======================================================================= #
# |         *** Functions for Parameter Optimization ***                | #
# ======================================================================= #
# -------------------------------------------------------------------- #
# | **** start of function: generate_job_list_for_param_optimazation | #
# | return a list of jobs that will have the data of one fold, and a | #
# | set of model parameters for training/testing. This list          | #
# | will be divided on allocated slaves that will run independly     | #
# | from each other                                                  | #
# -------------------------------------------------------------------- #
generate_job_list_for_param_optimization = function(p_in_expr_target
                                                    , p_in_expr_reg
                                                    , nbr_target_optimize
                                                    , nbr_fold
                                                    , df_model_param
                                                    , seed
){
  data = list()
  # read expression data for regulators & target genes
  df_expr_target = read.csv(p_in_expr_target, header=TRUE, row.names=1, sep='\t')
  rownames(df_expr_target) = lapply(rownames(df_expr_target), function(r) gsub("-", "_", r))
  
  df_expr_reg = read.csv(p_in_expr_reg, header=TRUE, row.names=1, sep='\t')
  rownames(df_expr_reg) = lapply(rownames(df_expr_reg), function(r) gsub("-", "_", r))
  
  # get samples of targets to do the optimization on these targets
  set.seed(seed)
  idx_target_optimize = sample(row.names(df_expr_target), nbr_target_optimize)
  df_expr_target_optimize = df_expr_target[idx_target_optimize, ]
  
  # define the list of jobs that will run on slaves
  l_job = list()
  l_fold = cut(seq(1, dim(df_expr_target)[2]), breaks=nbr_fold, label=FALSE)  # c(1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5)
  for (target in row.names(df_expr_target_optimize)){  # loop over all selected targets for optimization
    for (model_param_idx in seq(dim(df_model_param)[1])){  # loop over models and their param
      for (fold in seq(nbr_fold)){  # loop over all $nbr_fold
        l_job[[paste(target, fold, model_param_idx, sep='_')]]['target'] = target
        l_job[[paste(target, fold, model_param_idx, sep='_')]]['testing_idx'] = list(which(l_fold==fold, arr.ind=TRUE))
        l_job[[paste(target, fold, model_param_idx, sep='_')]]['model_param'] = list(df_model_param[model_param_idx, ])
      }
    }
  }
  
  # return list of jobs
  data[[1]] = t(df_expr_target_optimize)
  data[[2]] = df_expr_reg
  data[[3]] = l_job
  
  data
}
# -------------------------------------------------------------------- #
# | **** End of function: generate_job_list_for_param_optimazation   | #
# -------------------------------------------------------------------- #


# --------------------------------------------------------------- #
# | **** start of function: train_test_and_calculate_se ****    | #
# | This function will run on allocated slaves in the workflow  | #
# |  function, it trains/tests and calculate squarred error     | #
# | (se) for every target gene                                  | # 
# --------------------------------------------------------------- #
train_test_and_calculate_se = function(idx_per_slave){
  rank = mpi.comm.rank()
  idx = idx_per_slave[[rank]]
  
  df_se = data.frame(matrix(ncol=dim(l_job[[1]]$model_param)[2], nrow=0))
  for (i in idx){
    data = l_job[[i]]  # get data for ith job
    target = data$target
    testing_idx = data$testing_idx
    df_allowed_x = x
    df_allowed_x[, which(df_allowed[, target]==0)] = 0
    df_training_x = df_allowed_x[-testing_idx, ]
    df_training_y = df_expr_target_optimize[-testing_idx, target]
    df_testing_x = df_allowed_x[testing_idx, ]
    df_testing_y = df_expr_target_optimize[testing_idx, target]
    df_model_param = data$model_param
    if (model_name == "bart"){
      # train model
      model = train(model_name=model_name
                    , df_training_x
                    , df_training_y
                    , df_model_param
                    , seed)
      df_testing_pred = test(model=model
                             , model_name=model_name
                             , df_testing_x=df_testing_x)
      se = sum((df_testing_pred - df_testing_y)**2)
      df_se = rbind(df_se, data.frame(ntree=c(df_model_param[['ntree']])
                                      , k=c(df_model_param[['k']])
                                      , sigdf=c(df_model_param[['sigdf']])
                                      , sigquant=c(df_model_param[['sigquant']])
                                      , se=c(se)))
      gc()
    } else if (model_name == "xgboost"){
      
    }
  }
  df_se
}
# --------------------------------------------------------------- #
# | **** End of function: train_test_and_calculate_se ****      | #
# --------------------------------------------------------------- #

# ======================================================================= #
# |          *** End Functions for Param Optimization ***               | #
# ======================================================================= #


# ======================================================================= #
# |          *** Functions for Building Network Edges ***               | #
# ======================================================================= #
# --------------------------------------------------------------------- #
# | **** start of function: prepare_data_for_building_network ****    | #
# | This function will prepare data for building network by regression| #
# | model: training, testing(Q0 & Q100), and allowed predictors       | #
# --------------------------------------------------------------------- #
prepare_data_for_building_network = function(p_in_expr_target
                                             , p_in_expr_reg
                                             , p_src_code){
  
  library("matrixStats")
  source(paste(p_src_code, 'src/build_optimized_net/code/prepare_data_generate_allowed_perturbed_and_scale_normalize.R', sep=''))
  
  df_expr_target = read.csv(p_in_expr_target, header=TRUE, row.names=1, sep='\t', check.names = FALSE)
  rownames(df_expr_target) = lapply(rownames(df_expr_target), function(r) gsub("-", "_", r))
  
  df_expr_reg = read.csv(p_in_expr_reg, header=TRUE, row.names=1, sep='\t', check.names = FALSE)
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
# --------------------------------------------------------------------- #
# | **** End of function: prepare_data_for_building_network ****      | #
# --------------------------------------------------------------------- #

# --------------------------------------------------------------------- #
# | **** start of function: build_model_and_predict_for_gene ****     | #
# | This function predict the coeffients (edges score) for one target | #
# --------------------------------------------------------------------- #
build_model_and_predict_for_one_gene = function(x
                                                , y
                                                , df_allowed
                                                , target_id
                                                , df_test_Q0
                                                , df_test_Q100){
  
  # Train model, then test for regulators with Q0 and Q100
  
  # check if response (y) is one of  predictors (x)
  # x_allowed assigns 0 when one of predictors is the same as y 
  x_allowed = x
  x_allowed[, which(df_allowed==0)] = 0
  
  df_test_Q0_allowed = df_test_Q0
  df_test_Q0_allowed[, which(df_allowed==0)] = 0
  df_test_Q0_allowed[which(df_allowed==0), ] = 0
  
  df_test_Q100_allowed = df_test_Q100
  df_test_Q100_allowed[, which(df_allowed==0)] = 0
  df_test_Q100_allowed[which(df_allowed==0), ] = 0
  
  data = as.matrix(x_allowed)
  label = as.matrix(y)
  
  # do the predictions
  df_prediction = tryCatch({
    
    # train model
    model = train(df_training_x=data
                  , df_training_y=label
                  , model_name=model_name
                  , df_model_param=df_model_param_optimal
                  , seed=seed)
    
    # do the prediction for Q0 and Q100
    predict_Q0 = test(model=model
                      , df_testing_x=as.matrix(df_test_Q0_allowed)
                      , model_name=model_name)
    
    predict_Q100 = test(model=model
                        , df_testing_x=as.matrix(df_test_Q100_allowed)
                        , model_name=model_name)
    
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
# --------------------------------------------------------------------- #
# | **** End of function: build_model_and_predict_for_gene ****     | #
# --------------------------------------------------------------------- #

# --------------------------------------------------------------------- #
# | **** start of function: predict_for_all_genes ****                | #
# | This function will run on allocated slaves, and predict           | #
# | coefficients for all target genes                                 | #
# --------------------------------------------------------------------- #
predict_for_all_genes = function(idx_per_slave){
  rank = mpi.comm.rank()
  idx = idx_per_slave[[rank]]
  df_prediction_all = data.frame(matrix(nrow=dim(x)[2], ncol=0))
  # rownames(df_prediction) = colnames(x)
  for (i in idx){
    df_y = data.frame(y[, i])
    target_id = as.character(colnames(y)[i])
    colnames(df_y)=target_id
    # cat('target gene: ', i, 'name: ', target_id, '\n')
    df_prediction = build_model_and_predict_for_one_gene(x=x
                                                         , y=df_y
                                                         , df_allowed=df_allowed[, i]
                                                         , target_id
                                                         , df_test_Q0=df_test_Q0
                                                         , df_test_Q100=df_test_Q100)
    df_prediction_all = cbind(df_prediction_all, df_prediction)
    gc()
  }
  
  df_prediction_all
}
# --------------------------------------------------------------------- #
# | **** End of function: predict_for_all_genes ****                  | #
# --------------------------------------------------------------------- #
# ======================================================================= #
# |          *** End Functions for Building Network Edges ***           | #
# ======================================================================= #


# ======================================================================= #
# |          *** Workflow Function for Building Network Edges ***       | #
# ======================================================================= #
build_network = function(p_in_expr_target
                         , p_in_expr_reg
                         , flag_optimize
                         , nbr_target_optimize
                         , nbr_fold
                         , model_name
                         , df_model_param
                         , df_model_param_optimal
                         , nbr_rmpi_slaves
                         , p_out_dir
                         , f_out_name
                         , p_src_code
                         , seed
){
  
  #' Parameters:
  #' 
  #' p_in_expr_target: path of expression levels for target genes
  #' p_in_expr_reg: path of expression levels for regulators
  #' flag_optimize: ON or OFF for optimization of regression parameters
  #' nbr_target_optimize: number of target genes that will be used in the optimization
  #' nbr_fold: number of CV folds for optimization
  #' df_model_param: dataframe for regression parameters columns are regression parameters and rows are different options for that
  #' nbr_rmpi_slaves: number of RMPI slaves for parallel/distributed computations
  #' model_name: name of model bart, xgboost, etc
  #' p_out_dir: path of output directory 
  #' f_out_name: name of the output network file
  #' p_src_code: path of source code
  #' 
  #' Returns
  #' No object is returned, however the network file is saved in $p_out_dir$f_out_name
  #'  
  
  # load libraries
  library("Rmpi")
  library("dplyr")
  
  # prepare data for Regression
  data_regression = prepare_data_for_building_network(p_in_expr_target=p_in_expr_target
                                                      , p_in_expr_reg=p_in_expr_reg
                                                      , p_src_code=p_src_code)
  
  
  # get data: x:predictor, y: response, quantiles 0 and 100, allowed predictors, etc
  x = data_regression[[1]]
  y = data_regression[[2]]
  df_test_Q0 = data_regression[[3]]
  df_test_Q100 = data_regression[[4]]
  df_allowed = data_regression[[5]]
  total_target = data_regression[[6]]
  l_reg = data_regression[[7]]
  
  
  # allocate Rmpi slaves
  mpi.spawn.Rslaves(nslaves=nbr_rmpi_slaves)
  
  # send variables to slaves
  mpi.bcast.Robj2slave(seed)
  mpi.bcast.Robj2slave(train)
  mpi.bcast.Robj2slave(test)
  mpi.bcast.Robj2slave(model_name)
  mpi.bcast.Robj2slave(x)
  mpi.bcast.Robj2slave(y)
  mpi.bcast.Robj2slave(df_test_Q0)
  mpi.bcast.Robj2slave(df_test_Q100)
  mpi.bcast.Robj2slave(df_allowed)
  mpi.bcast.Robj2slave(build_model_and_predict_for_one_gene)
  mpi.bcast.Robj2slave(predict_for_all_genes)
  
  # ----------------------------------------------------------------- #
  # |  *** Part I: Optimize Regression if flag_optimize == ON ***   | #
  # ----------------------------------------------------------------- #
  if (flag_optimize == "ON"){
    # prepare list of jobs that will be sent to all allocated slaves
    data_optimization = generate_job_list_for_param_optimization(p_in_expr_target
                                                                 , p_in_expr_reg
                                                                 , nbr_target_optimize
                                                                 , nbr_fold
                                                                 , df_model_param
                                                                 , seed
    )
    df_expr_target_optimize = data_optimization[[1]]
    l_job = data_optimization[[3]]
    
    # divide the list of jobs on all slaves
    idx_per_slave = suppressWarnings(split(seq(length(l_job)), seq(nbr_rmpi_slaves)))
    
    # send variables to all slaves, so they are visible to them
    mpi.bcast.Robj2slave(df_expr_target_optimize)
    mpi.bcast.Robj2slave(l_job)
    mpi.bcast.Robj2slave(train_test_and_calculate_se)
    
    # run optimization for all folds & for all models
    l_slave = mpi.remote.exec(train_test_and_calculate_se
                              , idx_per_slave
                              , simplify=FALSE
                              , comm=1
                              , ret=TRUE)
    
    df_rmse_grouped = l_slave[[1]]
    group_by_cols = paste(colnames(df_rmse_grouped)[!names(df_rmse_grouped) %in% c('se')], collapse=', ')
    for (slave_idx in seq(2, length(l_slave), 1)){
      df_rmse_grouped = data.frame(rbind(df_rmse_grouped, l_slave[[slave_idx]]))
      cmd_group_by = paste("df_rmse_grouped %>% group_by(", group_by_cols, ") %>% summarise(se=sum(se))", sep='')
      df_rmse_grouped = data.frame(eval(parse(text=cmd_group_by)))
      
    }
    
    print('se for all models')
    print(df_rmse_grouped)
    # select the optimal model parameters 
    df_model_param_optimal = df_rmse_grouped[which.min(df_rmse_grouped$se), ]
    print('optimal parameters')
    print(df_model_param_optimal)
    
  }
  # end regression optimization
  
  # ----------------------------------------------------------------- #
  # |  *** Part II: Regression & Build network ***                  | #
  # | if parameters are optimized, use them otherwise use default   | #
  # ----------------------------------------------------------------- #
  
  # divide data on all slaves, so they are processed in parallel/distributed fashion
  # prepare indices for parallel/distributed processing
  idx_per_slave = suppressWarnings(split(seq(total_target), seq(nbr_rmpi_slaves)))
  
  mpi.bcast.Robj2slave(x)
  mpi.bcast.Robj2slave(y)
  mpi.bcast.Robj2slave(df_test_Q0)
  mpi.bcast.Robj2slave(df_test_Q100)
  mpi.bcast.Robj2slave(df_allowed)
  mpi.bcast.Robj2slave(df_model_param_optimal)
  mpi.bcast.Robj2slave(build_model_and_predict_for_one_gene)
  mpi.bcast.Robj2slave(predict_for_all_genes)
  l_slave = mpi.remote.exec(predict_for_all_genes, idx_per_slave, simplify = FALSE, comm =1, ret =TRUE)
  
  mpi.close.Rslaves()
  
  
  # process the results from all slaves
  df_net = data.frame(matrix(nrow=dim(x)[2], ncol=0))
  for (i in seq(length(l_slave))){
    if (typeof(l_slave[[i]]) == "list"){
      df_net = cbind(df_net, l_slave[[i]])  
    }
  }
  
  # # write gam network
  rownames(df_net) = lapply(l_reg, function(r) gsub("_", "-", r))
  colnames(df_net) = lapply(colnames(df_net), function(c) gsub("_", "-", c))
  write.table(df_net
              , file.path(p_out_dir, f_out_name)
              , row.names=rownames(df_net)
              , col.names=colnames(df_net)
              , quote=FALSE
              , sep="\t")
}
# ======================================================================= #
# |      *** End Workflow Function for Building Network Edges ***       | #
# ======================================================================= #


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# |                     *** MAIN FUNCTION ***                  | #
# |       This function will start the workflow function       | #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #   
if (sys.nframe() == 0){
  # ====================================================== #
  # |          *** load required libraries ***           | #
  # ====================================================== #
  library("optparse")
  
  # ====================================================== #
  # |               *** Parse Arguments ***              | #
  # ====================================================== #
  opt_parser = OptionParser(option_list=list(
    
    # Input: Training & Testing
    p_in_expr_target = make_option(c("--p_in_expr_target"), type="character", help="path of expression for target genes")
    , p_in_expr_reg = make_option(c("--p_in_expr_reg"), type="character", help="path of expression for regulators")
    
    # Regression/Optimization
    , flag_optimize = make_option(c("--flag_optimize"), type="character", help="ON or OFF for optimization")
    , nbr_target_optimize = make_option(c("--nbr_target_optimize"), type="integer", help="number of target genes used in the optimiization")
    , nbr_fold = make_option(c("--nbr_fold"), type="integer", help="number of CV folds for parameter optimization")
    , model_name = make_option(c("--model_name"), type="character", help="bart, xgboost, random forest, etc")
    , df_model_param = make_option(c("--df_model_param"), type="character", default="NULL", help="string encodes dataframe for grid search parameters: columns are parameters and rows are different options")
    , df_model_param_optimal = make_option(c("--df_model_param_optimal"), type="character", default="NULL", help="string encodes dataframe for optimal parameters in case flag_optimize == OFF")
    
    # logistics
    , seed = make_option(c("--seed"), type="integer", help="to set up the seed for reproducibility")
    , p_src_code = make_option(c("--p_src_code"), type="character", help="path of directory for source code")
    
    # distributed/parallel computation
    , nbr_rmpi_slaves = make_option(c("--nbr_rmpi_slaves"), type="integer", help="number of slaves that will allocated by Rmpi")
    
    # Ouput
    , p_out_dir = make_option(c("--p_out_dir"), type="character", help="path of output directory")
    , f_out_name = make_option(c("--f_out_name"), type="character", help="name of file for output network")
  ))
  
  opt = parse_args(opt_parser, positional_arguments=TRUE)$options
  
  # Build network
  build_network(p_in_expr_target=opt$p_in_expr_target
                , p_in_expr_reg=opt$p_in_expr_reg
                , flag_optimize=opt$flag_optimize
                , nbr_target_optimize=opt$nbr_target_optimize
                , nbr_fold=opt$nbr_fold
                , model_name=opt$model_name
                , df_model_param=eval(parse(text=opt$df_model_param))
                , df_model_param_optimal=eval(parse(text=opt$df_model_param_optimal))
                , nbr_rmpi_slaves=opt$nbr_rmpi_slaves
                , p_out_dir=opt$p_out_dir
                , f_out_name=opt$f_out_name
                , p_src_code=opt$p_src_code
                , seed=opt$seed)
}
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# |                  *** End MAIN FUNCTION ***                 | #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #   