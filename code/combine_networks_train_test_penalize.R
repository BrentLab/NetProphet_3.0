# ===================================================================== #
# |             *** Train and Write Penalized Model ***               | #
# ===================================================================== #
train_and_write_model = function(p_in_train_binding
                                 , p_in_train_lasso
                                 , p_in_train_de
                                 , p_in_train_bart
                                 , p_in_train_pwm
                                 , p_in_train_new
                                 , model
                                 , p_out_model
                                 , flag_penalize){
  # Read Binding data
  if (!is.null(p_in_train_binding)){
    df_in_train_binding = read.csv(p_in_train_binding, header=FALSE, sep='\t')
    if (length(colnames(df_in_train_binding)) > 3){
      train_binding = unlist(df_in_train_binding)
    } else{
      train_binding = df_in_train_binding[3]
    }
    colnames(train_binding) = "binding"
  }
  
  # Read source of information from file into dataframe for training
  df_training = read_data(model=model
                          , p_lasso=p_in_train_lasso
                          , p_de=p_in_train_de
                          , p_bart=p_in_train_bart
                          , p_pwm=p_in_train_pwm
                          , p_new=p_in_train_new
                         )
 
  # train penalized model witht glmnet
  if (flag_penalize == "L1" || flag_penalize == "ON"){
    model = glmnet(as.matrix(df_training), as.matrix(train_binding), family="binomial", alpha=1)
  } else if (flag_penalize == "L2"){
    model = glmnet(as.matrix(df_training), as.matrix(train_binding), family="binomial", alpha=0)
  } else if (flag_penalize == "L1_L2") {
    model = glmnet(as.matrix(df_training), as.matrix(train_binding), family="binomial", alpha=0.5)
  }
  
  # write the model into RData file
  if (!is.null(p_out_model)){
    saveRDS(model, file=p_out_model)
  }
    
}

# ===================================================================== #
# |                 *** Test and Write likelihood ***                 | #
# ===================================================================== #
test_and_write_sum_log_likelihood = function(p_in_model_lambda
                                             , p_in_model
                                             , p_in_test_binding
                                             , p_in_test_lasso
                                             , p_in_test_de
                                             , p_in_test_bart
                                             , p_in_test_pwm
                                             , p_in_test_new
                                             , p_out_log_likelihood
                                             , model){
  # ----------------------------------------------------------- #
  # | read the model trained by all training data to get the  | #
  # | list of lambdas, then use these lambdas with the        | #
  # | trained model by 10-fold of CVs to calculate sum of log | #
  # | likelihood                                              | #
  # ----------------------------------------------------------- #
  
  # Read Binding data that will be used to calculate the likelihood
  if (!is.null(p_in_test_binding)){
    df_in_test_binding = read.csv(p_in_test_binding, header=FALSE, sep='\t')
    if (length(colnames(df_in_test_binding)) > 3){
      test_binding = unlist(df_in_test_binding)
    } else{
      test_binding = df_in_test_binding[3]
    }
    colnames(test_binding) = 'binding'
  }
  
  # Read source of information from file into dataframe for testing
  df_testing = read_data(model=model
                         , p_lasso=p_in_test_lasso
                         , p_de=p_in_test_de
                         , p_bart=p_in_test_bart
                         , p_pwm=p_in_test_pwm
                         , p_new=p_in_test_new
                        )
  
  # calculate the sum of log likelihood for every lambda
  model_lambda = readRDS(p_in_model_lambda)  # read the model for lambdas
  model = readRDS(p_in_model)  # read the model of training
  l_log_likelihood = c()
  for (i in 1:length(model_lambda$lambda)){
    lambda_value = model_lambda$lambda[i]
    tryCatch({
      test_predict = predict(model, newx=as.matrix(df_testing), s=lambda_value, type="response")
      log_likelihood = sum(log(c(test_predict[test_binding == 1], 1-test_predict[test_binding == 0])))
    }, error = function(e) {
      print(lambda_value)
      print(e)
    }, finally = {
      l_log_likelihood = c(l_log_likelihood, log_likelihood)
    })
    }
  
  # write the sum log likelihood for every lambda
  write.table(file=file(p_out_log_likelihood)
            , data.frame(matrix(l_log_likelihood, nrow=1, byrow=FALSE))
            , row.names=FALSE, col.names=FALSE, sep='\t', quote=FALSE)
}

# ===================================================================== #
# |              *** Select Optimal Lambda and Predict ***            | #
# ===================================================================== #
select_optimal_lambda_and_predict = function(p_in_train_binding
                                             , p_in_train_lasso
                                             , p_in_train_de
                                             , p_in_train_bart
                                             , p_in_train_pwm
                                             , p_in_train_new
                                             , p_in_test_lasso
                                             , p_in_test_de
                                             , p_in_test_bart
                                             , p_in_test_pwm
                                             , p_in_test_new
                                             , p_in_model_lambda
                                             , p_out_pred_train
                                             , p_out_pred_test
                                             , p_out_optimal_lambda
                                             , p_dir_log_likelihood
                                             , model
                                             ){
  # Read likelihoods for all 10-fold CVs
  df_log_likelihood = read.csv(paste(p_dir_log_likelihood, "fold0_log_likelihood.tsv", sep=""), header=FALSE, sep="\t")
  for (i in 1:9){
    df_log_likelihood_tmp = read.csv(paste(p_dir_log_likelihood, "fold", i, "_log_likelihood.tsv", sep=""), header=FALSE, sep="\t")
    df_log_likelihood = rbind(df_log_likelihood, df_log_likelihood_tmp)    
  }
  
  # select optimal lambda having the maximum log_likelihood
  model_lambda = readRDS(p_in_model_lambda)
  l_lambda_model = model_lambda$lambda
  l_mean_log_likelihood = c()
  for (i in 1:length(l_lambda_model)){
    l_log_likelihood = df_log_likelihood[, i]
    l_mean_log_likelihood = c(l_mean_log_likelihood, mean(l_log_likelihood))
  }
  lambda = l_lambda_model[which(l_mean_log_likelihood == max(l_mean_log_likelihood))][1]
    
  # write optimal lambda 
  write.table(file=file(p_out_optimal_lambda)
             , data.frame(c(lambda))
             , row.names=FALSE, col.names=FALSE, sep='\t', quote=FALSE)

  # Read Binding for training
  if (!is.null(p_in_train_binding)){
    df_in_train_binding = read.csv(p_in_train_binding, header=FALSE, sep='\t')
    if (length(colnames(df_in_train_binding)) > 3){
      train_binding = unlist(df_in_train_binding)
    } else{
      train_binding = df_in_train_binding[3]
      l_train_reg = df_in_train_binding[1]
      colnames(l_train_reg) = "REGULATOR"
      l_train_target = df_in_train_binding[2]
      colnames(l_train_target) = "TARGET"
    }
    colnames(train_binding) = 'binding'
  }
  # read source of information of training into dataframe
  df_training = read_data(model=model
                          , p_lasso=p_in_train_lasso
                          , p_de=p_in_train_de
                          , p_bart=p_in_train_bart
                          , p_pwm=p_in_train_pwm
                          , p_new=p_in_train_new
                         )
  # read list of regulators and targets to be able to write the prediction for testing data
  if (!is.null(p_in_test_lasso)){
    df_in_test_lasso = read.csv(p_in_test_lasso, header=FALSE, sep='\t')
    if (length(colnames(df_in_test_lasso)) > 3){
      test_lasso = unlist(df_in_test_lasso)
    } else{
      test_lasso = df_in_test_lasso[3]
      l_test_reg = df_in_test_lasso[1]
      colnames(l_test_reg) = "REGULATOR"
      l_test_target = df_in_test_lasso[2]
      colnames(l_test_target) = "TARGET"
    }
  }
  # read source of information of testing into dataframe
  df_testing = read_data(model=model
                        , p_lasso=p_in_test_lasso
                        , p_de=p_in_test_de
                        , p_bart=p_in_test_bart
                        , p_pwm=p_in_test_pwm
                        , p_new=p_in_test_new
                        )
  
  # predict and write of prediction for training data
  test_predict = predict(model_lambda, newx=as.matrix(df_testing), s=lambda, type="response")
  write.table(
    file=file(p_out_pred_test)
    , x=data.frame(REGULATOR=l_test_reg, TARGET=l_test_target, VALUE=test_predict)
    , row.names=FALSE, col.names=FALSE, sep='\t', quote=FALSE)  
 
  # predict and write of prediction for testing data
  train_predict = predict(model_lambda, newx=as.matrix(df_training), s=lambda, type="response")
  write.table(
    file=file(p_out_pred_train)
    , x=data.frame(REGULATOR=l_train_reg, TARGET=l_train_target, VALUE=train_predict)
    , row.names=FALSE, col.names=FALSE, sep='\t' , quote=FALSE)
}

if (sys.nframe() == 0){
  # ======================================================== #
  # |          *** Install and Call Packages ***           | #
  # ======================================================== #
  # Install optparse package
  if (!require(optparse)){
    install.packages("optparse", repo="http://cran.rstudio.com")
    library("optparse", quietly=TRUE)
  }
  # Install glmnet package  
  if (!require(glmnet)){
    install.packages("glmnet")
    library("glmnet", quietly=TRUE)
  }
  
  # ======================================================== #
  # |                *** Parse Arguments ***               | #
  # ======================================================== #
  p_in_train_binding = make_option(c("--p_in_train_binding"), type="character")
  p_in_train_lasso = make_option(c("--p_in_train_lasso"), type="character", default=NULL)
  p_in_train_de = make_option(c("--p_in_train_de"), type="character", default=NULL)
  p_in_train_bart = make_option(c("--p_in_train_bart"), type="character", default=NULL)
  p_in_train_pwm = make_option(c("--p_in_train_pwm"), type="character", default=NULL)
  p_in_train_new = make_option(c("--p_in_train_new"), type="character", default=NULL)
    
  
  p_in_test_binding = make_option(c("--p_in_test_binding"), type="character", default=NULL)
  p_in_test_lasso = make_option(c("--p_in_test_lasso"), type="character", default=NULL)
  p_in_test_de = make_option(c("--p_in_test_de"), type="character", default=NULL)
  p_in_test_bart = make_option(c("--p_in_test_bart"), type="character", default=NULL)
  p_in_test_pwm = make_option(c("--p_in_test_pwm"), type="character", default=NULL)
  p_in_test_new = make_option(c("--p_in_test_new"), type="character", default=NULL)
    
  flag_penalize = make_option(c("--flag_penalize"), type="character", default=NULL)
  p_dir_log_likelihood = make_option(c("--p_dir_log_likelihood"), type="character", default=NULL)
  flag_step = make_option(c("--flag_step"), type="character", default=NULL)
  in_model = make_option(c("--in_model"), type="character")
  p_model = make_option(c("--p_model"), type="character", default=NULL)
  p_in_model_lambda = make_option(c("--p_in_model_lambda"), type="character", default=NULL)
                               
  p_out_log_likelihood = make_option(c("--p_out_log_likelihood"), type="character", default=NULL)
  p_out_pred_train = make_option(c("--p_out_pred_train"), type="character", default=NULL)
  p_out_pred_test = make_option(c("--p_out_pred_test"), type="character", default=NULL)
  p_out_optimal_lambda = make_option(c("--p_out_optimal_lambda"), type="character", default=NULL)
    
  p_src_code = make_option(c("--p_src_code"), type="character", default=NULL)
  
  opt_parser = OptionParser(option_list=list(p_in_train_binding, p_in_train_lasso, p_in_train_de
                                             , p_in_train_bart, p_in_train_pwm, p_in_train_new, p_in_test_binding
                                             , p_in_test_lasso, p_in_test_de, p_in_test_bart
                                             , p_in_test_pwm, p_in_test_new, flag_step, in_model, p_model
                                             , p_in_model_lambda, p_out_log_likelihood
                                             , p_dir_log_likelihood
                                             , p_out_pred_train, p_out_pred_test, p_out_optimal_lambda
                                             , p_src_code, flag_penalize
                                             ))
  
  opt = parse_args(opt_parser)
  
  source(paste(opt$p_src_code, "code/combine_networks_read_files_into_data_frame.R", sep=""))
    
  if (opt$flag_step == "train_and_write_model_with_all_training" || opt$flag_step == "train_and_write_model_with_fold_training"){
    train_and_write_model(p_in_train_binding=opt$p_in_train_binding
                          , p_in_train_lasso=opt$p_in_train_lasso
                          , p_in_train_de=opt$p_in_train_de
                          , p_in_train_bart=opt$p_in_train_bart
                          , p_in_train_pwm=opt$p_in_train_pwm
                          , p_in_train_new=opt$p_in_train_new
                          , model=opt$in_model
                          , p_out_model=opt$p_model
                          , flag_penalize=opt$flag_penalize)
  } else if (opt$flag_step == "test_and_write_sum_log_likelihood"){
    test_and_write_sum_log_likelihood(p_in_model_lambda=opt$p_in_model_lambda
                                      , p_in_model=opt$p_model
                                      , p_in_test_binding=opt$p_in_test_binding
                                      , p_in_test_lasso=opt$p_in_test_lasso
                                      , p_in_test_de=opt$p_in_test_de
                                      , p_in_test_bart=opt$p_in_test_bart
                                      , p_in_test_pwm=opt$p_in_test_pwm
                                      , p_in_test_new=opt$p_in_test_new
                                      , p_out_log_likelihood=opt$p_out_log_likelihood
                                      , model=opt$in_model)
  } else if (opt$flag_step == "select_optimal_lambda_and_predict"){
    select_optimal_lambda_and_predict(p_in_train_binding=opt$p_in_train_binding
                                      , p_in_train_lasso=opt$p_in_train_lasso
                                      , p_in_train_de=opt$p_in_train_de
                                      , p_in_train_bart=opt$p_in_train_bart
                                      , p_in_train_pwm=opt$p_in_train_pwm
                                      , p_in_train_new=opt$p_in_train_new
                                      , p_in_test_lasso=opt$p_in_test_lasso
                                      , p_in_test_de=opt$p_in_test_de
                                      , p_in_test_bart=opt$p_in_test_bart
                                      , p_in_test_pwm=opt$p_in_test_pwm
                                      , p_in_test_new=opt$p_in_test_new
                                      , p_dir_log_likelihood=opt$p_dir_log_likelihood
                                      , model=opt$in_model
                                      , p_in_model_lambda=opt$p_in_model_lambda
                                      , p_out_pred_train=opt$p_out_pred_train
                                      , p_out_pred_test=opt$p_out_pred_test
                                      , p_out_optimal_lambda=opt$p_out_optimal_lambda)
  }
    
  
}