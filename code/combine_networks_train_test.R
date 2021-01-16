train_test = function(p_in_train_binding
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
               , in_model
               , p_out_pred_train
               , p_out_pred_test
               , p_out_model_summary
               , flag_intercept
               , p_out_model){
    # Read Binding data
    if (!is.null(p_in_train_binding) & p_in_train_binding != "NONE"){
        df_in_train_binding = read.csv(p_in_train_binding, header=FALSE, sep='\t')
        if (length(colnames(df_in_train_binding)) > 3){
          train_binding = unlist(df_in_train_binding)
        } else{
          train_binding = df_in_train_binding[3]
          train_reg = df_in_train_binding[1]
          train_target = df_in_train_binding[2]
        }
        colnames(train_binding) = "binding"
    }
    
    # Read Lasso data to get the list of regulators/targets for the testing
    if (!is.null(p_in_test_lasso) & p_in_test_lasso != "NONE"){
        df_in_test_lasso = read.csv(p_in_test_lasso, header=FALSE, sep='\t')
        if (length(colnames(df_in_test_lasso)) > 3){
          test_lasso = unlist(df_in_test_lasso)
        } else{
          test_lasso = df_in_test_lasso[3]
          test_reg = df_in_test_lasso[1]
          test_target = df_in_test_lasso[2]
        }
    }
    
    # Training: Read source of information from files into DataFrame
    df_training = read_data(model=in_model
                            , p_lasso=p_in_train_lasso
                            , p_de=p_in_train_de
                            , p_bart=p_in_train_bart
                            , p_pwm=p_in_train_pwm
                            , p_new=p_in_train_new
                           )
    
    # Training: Training the model with lars
    if (flag_intercept == "ON"){
        model = glm(binding ~ ., data=data.frame(binding=unlist(train_binding), df_training), family=binomial)
    } else{
        model = glm(binding ~ . -1, data=data.frame(binding=unlist(train_binding), df_training), family=binomial)
    }
    # Testing: Read source of information from files into DataFrame
    df_testing = read_data(model=in_model
                           , p_lasso=p_in_test_lasso
                           , p_de=p_in_test_de
                           , p_bart=p_in_test_bart
                           , p_pwm=p_in_test_pwm
                           , p_new=p_in_test_new
                          )
    # Predictions: Predict Training  & Testing data
    predict_train = predict(model, df_training, type="response")
    predict_test = predict(model, df_testing, type="response")
    # Write Predictions and Model Summary
    saveRDS(model, file=p_out_model)
    capture.output(summary(model), file=p_out_model_summary, append=FALSE)
    write.table(
        file=file(p_out_pred_train)
        , x=data.frame(REGULATOR=train_reg, TARGET=train_target, VALUE=predict_train)
        , row.names=FALSE, col.names=FALSE, sep='\t', quote=FALSE)
    
    write.table(
        file=p_out_pred_test
        , x=data.frame(REGULATOR=test_reg, TARGET=test_target, VALUE=predict_test)
        , row.names=FALSE, col.names=FALSE,  sep='\t', quote=FALSE)
    
}

if (sys.nframe() == 0){
    if (!require(optparse)){
        install.packages("optparse", repo="http://cran.rstudio.com/")
        library("optparse")
    }
    # Input: Training
    p_in_train_binding = make_option(c("--p_in_train_binding"), type="character", help="path of binding file for training")
    p_in_train_lasso = make_option(c("--p_in_train_lasso"), type="character", help="path of lasso file for training")
    p_in_train_de = make_option(c("--p_in_train_de"), type="character", default=NULL, help="path of de file for training")
    p_in_train_bart = make_option(c("--p_in_train_bart"), type="character", help="path of bart file for training")
    p_in_train_pwm = make_option(c("--p_in_train_pwm"), type="character", default=NULL, help="path of pwm file for training")
    p_in_train_new = make_option(c("--p_in_train_new"), type="character", default=NULL, help="path of new source of information file for training")
    
    # Input: Testing
    p_in_test_lasso = make_option(c("--p_in_test_lasso"), type="character", help="path of lasso file for testing")
    p_in_test_de = make_option(c("--p_in_test_de"), type="character", default=NULL, help="path of de file for testing")
    p_in_test_bart =make_option(c("--p_in_test_bart"), type="character", help="path of file bart file for testing")
    p_in_test_pwm = make_option(c("--p_in_test_pwm"), type="character", default=NULL, help="path of file pwm file for testing")
    p_in_test_new = make_option(c("--p_in_test_new"), type="character", default=NULL, help="path of file new source of information file for testing")
    
    # Output
    in_model = make_option(c("--in_model"), type="character", help="string of model")
    p_out_pred_train = make_option(c("--p_out_pred_train"), type="character", help="path of output for predicting the training data")
    p_out_pred_test = make_option(c("--p_out_pred_test"), type="character", help="path of output for predicting the testing data")
    p_out_model_summary = make_option(c("--p_out_model_summary"), type="character", help="path of output for model summary")
    p_out_model = make_option(c("--p_out_model"), type="character", help="path of the trained model")
    
    p_src_code = make_option(c("--p_src_code"), type="character", help="path of source of code for netprophet")
    
    flag_intercept = make_option(c("--flag_intercept"), type="character", help="ON or OFF for intercept generation")
                                 
    opt_parser = OptionParser(option_list=list(p_in_train_binding, p_in_train_lasso, p_in_train_de, p_in_train_bart, p_in_train_pwm, p_in_train_new, p_in_test_lasso, p_in_test_de, p_in_test_bart, p_in_test_pwm, p_in_test_new, in_model, p_out_pred_train, p_out_pred_test, p_out_model_summary, p_src_code, flag_intercept, p_out_model))
    
    
    opt = parse_args(opt_parser)
    
    source(paste(opt$p_src_code, "code/combine_networks_read_files_into_data_frame.R", sep=""))
    
    train_test(p_in_train_binding=opt$p_in_train_binding
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
               , in_model=opt$in_model
               , p_out_pred_train=opt$p_out_pred_train
               , p_out_pred_test=opt$p_out_pred_test
               , p_out_model_summary=opt$p_out_model_summary
               , flag_intercept=opt$flag_intercept
               , p_out_model=opt$p_out_model
              )
    
}