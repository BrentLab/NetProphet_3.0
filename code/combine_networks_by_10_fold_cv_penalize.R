source("/scratch/mblab/dabid/netprophet/code_netprophet3.0/code/combine_networks_read_files_into_data_frame.R")

train_penalize = function(p_in_train_binding
              , p_in_train_lasso
              , p_in_train_de
              , p_in_train_bart
              , p_in_train_pwm
              , model
              , p_out_model){
  # debug mode
  # p_in_train_binding = '/scratch/mblab/dabid/netprophet/net_out/zev_netprophet3_np1dummy_feed_ldbp_tf320_target6175_penalize_bis/tmp/combine_net_a/with_de/support/tmp_penalize/fold0/data_cv/fold5_test_binding.tsv'
  # p_in_train_lasso = '/scratch/mblab/dabid/netprophet/net_out/zev_netprophet3_np1dummy_feed_ldbp_tf320_target6175_penalize_bis/tmp/combine_net_a/with_de/support/tmp_penalize/fold0/data_cv/fold5_test_lasso.tsv'
  # p_in_train_de = '/scratch/mblab/dabid/netprophet/net_out/zev_netprophet3_np1dummy_feed_ldbp_tf320_target6175_penalize_bis/tmp/combine_net_a/with_de/support/tmp_penalize/fold0/data_cv/fold0_test_de.tsv'
  # p_in_train_bart = '/scratch/mblab/dabid/netprophet/net_out/zev_netprophet3_np1dummy_feed_ldbp_tf320_target6175_penalize_bis/tmp/combine_net_a/with_de/support/tmp_penalize/fold0/data_cv/fold5_test_bart.tsv'
  # p_in_train_pwm = "NONE"
  # model = "dummy_ldb_transform"
  # # p_in_train_pwm = '/scratch/mblab/dabid/netprophet/net_out/kem_netprophet3_np1dummy_feed_ldbp_tf313_target6112_bis/tmp/combine_net_b/with_de/net_pwm.tsv'
  # p_in_lambda_model = '/scratch/mblab/dabid/netprophet/net_out/zev_netprophet3_np1dummy_feed_ldbp_tf320_target6175_penalize/tmp/combine_net_a/without_de/support/data_pred/fold0_model.RData'
  # p_in_model = '/scratch/mblab/dabid/netprophet/net_out/zev_netprophet3_np1dummy_feed_ldbp_tf320_target6175_penalize_bis/tmp/combine_net_a/without_de/support/tmp_penalize/fold0/data_pred/fold5_model.RData'
  # 
  # BINDING
  if (!is.null(p_in_train_binding)){
    df_in_train_binding = read.csv(p_in_train_binding, header=FALSE, sep='\t')
    if (length(colnames(df_in_train_binding)) > 3){
      train_binding = unlist(df_in_train_binding)
    } else{
      train_binding = df_in_train_binding[3]
    }
    colnames(train_binding) = "binding"
  }
  
  df_training = read_data(model=model
                          , p_lasso=p_in_train_lasso
                          , p_de=p_in_train_de
                          , p_bart=p_in_train_bart
                          , p_pwm=p_in_train_pwm)
  if (!require(glmnet)){
      install.packages("glmnet")
      library("glmnet")}
  model = glmnet(as.matrix(df_training), as.matrix(train_binding), family="binomial")
  if (!is.null(p_out_model)){
    saveRDS(model, file=p_out_model)
  }
    
}

test_using_lambda = function(p_in_model_lambda
                  , p_in_model
                  , p_in_test_binding
                  , p_in_test_lasso
                  , p_in_test_de
                  , p_in_test_bart
                  , p_in_test_pwm
                  , p_out_log_likelihood
                  , model){
  
# BINDING
  if (!is.null(p_in_test_binding)){
    df_in_test_binding = read.csv(p_in_test_binding, header=FALSE, sep='\t')
    if (length(colnames(df_in_test_binding)) > 3){
      test_binding = unlist(df_in_test_binding)
    } else{
      test_binding = df_in_test_binding[3]
    }
    colnames(test_binding) = 'binding'
  }
  
  df_testing = read_data(model=model
                         , p_lasso=p_in_test_lasso
                         , p_de=p_in_test_de
                         , p_bart=p_in_test_bart
                         , p_pwm=p_in_test_pwm)
  if (!require(glmnet)){
    install.packages("glmnet")
    library("glmnet")
  }
  model_lambda = readRDS(p_in_model_lambda)  # read the model for lambdas
  model = readRDS(p_in_model)  # read the model of training
  # l_mse = c()
  l_log_likelihood = c()
  for (i in 1:length(model_lambda$lambda)){
    lambda_value = model_lambda$lambda[i]
    tryCatch({
      test_predict = predict(model, newx=as.matrix(df_testing), s=lambda_value, type="response")
      log_likelihood = sum(log(c(test_predict[test_binding == 1], 1-test_predict[test_binding == 0])))
    }, error = function(e) {
      # comment out the next print statement for a silent error
      print(lambda_value)
      print(e)
    }, finally = {
      l_log_likelihood = c(l_log_likelihood, log_likelihood)
    })
    }
  
  write.table(file=file(p_out_log_likelihood)
            , data.frame(matrix(l_log_likelihood, nrow=1, byrow=FALSE))
            , row.names=FALSE, col.names=FALSE, sep='\t', quote=FALSE)
}

select_lambda_and_predict = function(p_in_train_binding
                         , p_in_train_lasso
                         , p_in_train_de
                         , p_in_train_bart
                         , p_in_train_pwm
                         , p_in_test_lasso
                         , p_in_test_de
                         , p_in_test_bart
                         , p_in_test_pwm
                         , p_in_model_lambda
                         , p_out_pred_train
                         , p_out_pred_test
                         , p_out_lambda
                         , p_dir_log_likelihood
                         , model
                         ){
  
  # ============================================================= #
  # |                  *** CALCULATE LAMBDA ***                 | #
  # ============================================================= #
  # # debug mode
  # p_in_test_binding = '/scratch/mblab/dabid/netprophet/net_out/zev_netprophet3_np1dummy_feed_ldbp_tf320_target6175_penalize/tmp/combine_net_a/without_de/support/tmp_penalize/fold0/data_cv/fold0_test_binding.tsv'
  # p_in_test_lasso = '/scratch/mblab/dabid/netprophet/net_out/zev_netprophet3_np1dummy_feed_ldbp_tf320_target6175_penalize/tmp/combine_net_a/without_de/support/tmp_penalize/fold0/data_cv/fold0_test_lasso.tsv'
  # # p_in_test_de = '/scratch/mblab/dabid/netprophet/net_out/kem_netprophet3_np1dummy_feed_ldbp_tf313_target6112_bis/tmp/combine_net_b/with_de/net_de.tsv'
  # p_in_test_bart = '/scratch/mblab/dabid/netprophet/net_out/zev_netprophet3_np1dummy_feed_ldbp_tf320_target6175_penalize/tmp/combine_net_a/without_de/support/tmp_penalize/fold0/data_cv/fold0_test_bart.tsv'
  # # p_in_test_pwm = '/scratch/mblab/dabid/netprophet/net_out/kem_netprophet3_np1dummy_feed_ldbp_tf313_target6112_bis/tmp/combine_net_b/with_de/net_pwm.tsv'
  # p_in_model = '/scratch/mblab/dabid/netprophet/net_out/zev_netprophet3_np1dummy_feed_ldbp_tf320_target6175_penalize/tmp/combine_net_a/without_de/support/data_pred/fold0_model.RData'
  # p_in_model_lambda = '/scratch/mblab/dabid/netprophet/net_out/zev_netprophet3_np1dummy_feed_ldbp_tf320_target6175_penalize_bis3/tmp/combine_net_ldb/without_de/support/data_pred/fold0_model.RData'
  # p_dir_log_likelihood = '/scratch/mblab/dabid/netprophet/net_out/zev_netprophet3_np1dummy_feed_ldbp_tf320_target6175_penalize_bis3/tmp/combine_net_ldb/without_de/support/tmp_penalize/fold0/data_pred/'
  # # p_in_dir = '/scratch/mblab/dabid/netprophet/net_debug/'
  
  
  # collect all log likelihood across lambdas
  df_log_likelihood = read.csv(paste(p_dir_log_likelihood, "fold0_log_likelihood.tsv", sep=""), header=FALSE, sep="\t")
  for (i in 1:9){
    df_log_likelihood_tmp = read.csv(paste(p_dir_log_likelihood, "fold", i, "_log_likelihood.tsv", sep=""), header=FALSE, sep="\t")
    df_log_likelihood = rbind(df_log_likelihood, df_log_likelihood_tmp)    
  }
  model_lambda = readRDS(p_in_model_lambda)
  l_lambda_model = model_lambda$lambda
  l_mean_log_likelihood = c()
  for (i in 1:length(l_lambda_model)){
    l_log_likelihood = df_log_likelihood[, i]
    l_mean_log_likelihood = c(l_mean_log_likelihood, mean(l_log_likelihood))
  }

  lambda = l_lambda_model[which(l_mean_log_likelihood == max(l_mean_log_likelihood))]
  # write lambda 
  capture.output(c(l_lambda_model, lambda), file=p_out_lambda, append=FALSE)

  # ============================================================= #
  # |                *** READ TRAINING DATA ***                 | #
  # ============================================================= #
  # BINDING
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
  
  df_training = read_data(model=model
                          , p_lasso=p_in_train_lasso
                          , p_de=p_in_train_de
                          , p_bart=p_in_train_bart
                          , p_pwm=p_in_train_pwm)
  
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
  df_testing = read_data(model=model
                        , p_lasso=p_in_test_lasso
                        , p_de=p_in_test_de
                        , p_bart=p_in_test_bart
                        , p_pwm=p_in_test_pwm)
  
    if (!require(glmnet)){
      install.packages("glmnet")
      library("glmnet")
    }
    
  # predict the training & testing data
    test_predict = predict(model_lambda, newx=as.matrix(df_testing), s=lambda, type="response")
    train_predict = predict(model_lambda, newx=as.matrix(df_training), s=lambda, type="response")
    
    # write training predictions
    write.table(
      file=file(p_out_pred_train)
      , x=data.frame(REGULATOR=l_train_reg, TARGET=l_train_target, VALUE=train_predict)
      , row.names=FALSE, col.names=FALSE, sep='\t' , quote=FALSE)
 
  # write testing predictions
  write.table(
    file=file(p_out_pred_test)
    , x=data.frame(REGULATOR=l_test_reg, TARGET=l_test_target, VALUE=test_predict)
    , row.names=FALSE, col.names=FALSE, sep='\t', quote=FALSE)
  
}

if (sys.nframe() == 0){
  if (!require(optparse)){
    install.packages("optparse", repo="http://cran.rstudio.com")
    library("optparse")
  }
  
  p_in_train_binding = make_option(c("--p_in_train_binding"), type="character")
  p_in_train_lasso = make_option(c("--p_in_train_lasso"), type="character", default=NULL)
  p_in_train_de = make_option(c("--p_in_train_de"), type="character", default=NULL)
  p_in_train_bart = make_option(c("--p_in_train_bart"), type="character", default=NULL)
  p_in_train_pwm = make_option(c("--p_in_train_pwm"), type="character", default=NULL)
  
  p_in_test_binding = make_option(c("--p_in_test_binding"), type="character", default=NULL)
  p_in_test_lasso = make_option(c("--p_in_test_lasso"), type="character", default=NULL)
  p_in_test_de = make_option(c("--p_in_test_de"), type="character", default=NULL)
  p_in_test_bart = make_option(c("--p_in_test_bart"), type="character", default=NULL)
  p_in_test_pwm = make_option(c("--p_in_test_pwm"), type="character", default=NULL)
  
  p_dir_log_likelihood = make_option(c("--p_dir_log_likelihood"), type="character", default=NULL)
  flag_step = make_option(c("--flag_step"), type="character", default=NULL)
  in_model = make_option(c("--in_model"), type="character")
  p_model = make_option(c("--p_model"), type="character", default=NULL)
  p_in_model_lambda = make_option(c("--p_in_model_lambda"), type="character", default=NULL)
                               
                               
  
  p_out_log_likelihood = make_option(c("--p_out_log_likelihood"), type="character", default=NULL)
  p_out_pred_train = make_option(c("--p_out_pred_train"), type="character", default=NULL)
  p_out_pred_test = make_option(c("--p_out_pred_test"), type="character", default=NULL)
  p_out_lambda = make_option(c("--p_out_lambda"), type="character", default=NULL)
  
  opt_parser = OptionParser(option_list=list(p_in_train_binding, p_in_train_lasso, p_in_train_de
                                             , p_in_train_bart, p_in_train_pwm, p_in_test_binding
                                             , p_in_test_lasso, p_in_test_de, p_in_test_bart
                                             , p_in_test_pwm, flag_step, in_model, p_model
                                             , p_in_model_lambda, p_out_log_likelihood
                                             , p_dir_log_likelihood
                                             , p_out_pred_train, p_out_pred_test, p_out_lambda
                                             ))
  
  opt = parse_args(opt_parser)
  
  if (opt$flag_step == "get_lambda" || opt$flag_step == "train_penalize"){
    train_penalize(p_in_train_binding=opt$p_in_train_binding
                  , p_in_train_lasso=opt$p_in_train_lasso
                  , p_in_train_de=opt$p_in_train_de
                  , p_in_train_bart=opt$p_in_train_bart
                  , p_in_train_pwm=opt$p_in_train_pwm
                  , model=opt$in_model
                  , p_out_model=opt$p_model)
  } else if (opt$flag_step == "test_using_lambda"){
    test_using_lambda(p_in_model_lambda=opt$p_in_model_lambda
                      , p_in_model=opt$p_model
                      , p_in_test_binding=opt$p_in_test_binding
                      , p_in_test_lasso=opt$p_in_test_lasso
                      , p_in_test_de=opt$p_in_test_de
                      , p_in_test_bart=opt$p_in_test_bart
                      , p_in_test_pwm=opt$p_in_test_pwm
                      , p_out_log_likelihood=opt$p_out_log_likelihood
                      , model=opt$in_model)
    
    
  } else if (opt$flag_step == "select_lambda_and_predict"){
    select_lambda_and_predict(p_in_train_binding=opt$p_in_train_binding
                             , p_in_train_lasso=opt$p_in_train_lasso
                             , p_in_train_de=opt$p_in_train_de
                             , p_in_train_bart=opt$p_in_train_bart
                             , p_in_train_pwm=opt$p_in_train_pwm
                             , p_in_test_lasso=opt$p_in_test_lasso
                             , p_in_test_de=opt$p_in_test_de
                             , p_in_test_bart=opt$p_in_test_bart
                             , p_in_test_pwm=opt$p_in_test_pwm
                             , p_dir_log_likelihood=opt$p_dir_log_likelihood
                             , model=opt$in_model
                             , p_in_model_lambda=opt$p_in_model_lambda
                             , p_out_pred_train=opt$p_out_pred_train
                             , p_out_pred_test=opt$p_out_pred_test
                             , p_out_lambda=opt$p_out_lambda)
  }
    
  
}