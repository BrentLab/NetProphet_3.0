train_test = function(p_binding_train
                      , l_name_net
                      , l_path_net_train
                      , l_path_net_test
                      , model_name
                      , p_out_pred_train
                      , p_out_pred_test
                      , p_out_model_summary
                      , flag_intercept
                      , p_out_model){
    # Read Binding data
    if (!is.null(p_binding_train) & p_binding_train != "NONE"){
        df_in_train_binding = read.csv(p_binding_train, header=FALSE, sep='\t')
        if (length(colnames(df_in_train_binding)) > 3){
          train_binding = unlist(df_in_train_binding)
        } else{
          train_binding = df_in_train_binding[3]
          train_reg = df_in_train_binding[1]
          train_target = df_in_train_binding[2]
        }
        colnames(train_binding) = "binding"
    }
    
    # Read first network to get the list of regulators/targets for the testing
    path_net_test = strsplit(l_path_net_test, ',')[[1]][1]
    df_net_test = read.csv(path_net_test, header=FALSE, sep='\t')
        if (length(colnames(df_net_test)) > 3){
          test_net = unlist(df_net_test)
        } else{
          test_net = df_net_test[3]
          test_reg = df_net_test[1]
          test_target = df_net_test[2]
        }
    
    # Training: Read source of information from files into DataFrame
    df_training = read_data(l_name_net=l_name_net
                            , l_path_net=l_path_net_train
                            , model_name=model_name)
    
    # Training: Training the model with lars
    if (flag_intercept == "ON"){
        model = glm(binding ~ ., data=data.frame(binding=unlist(train_binding), df_training), family=binomial)
    } else{
        model = glm(binding ~ . -1, data=data.frame(binding=unlist(train_binding), df_training), family=binomial)
    }
    # Testing: Read source of information from files into DataFrame
    df_testing = read_data(l_name_net=l_name_net
                           , l_path_net=l_path_net_test
                           , model_name=model_name
                          )
    if (dim(df_training)[2] != dim(df_testing)[2]){
        stop("the number of cases for dummy variables are different in the training & testing")
    }
        
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
    opt_parser = OptionParser(option_list=list(
        
        # Input: Training & Testing
        p_binding_train = make_option(c("--p_binding_train"), type="character", help="path of binding file for training")
        , l_name_net = make_option(c("--l_name_net"))
        , l_path_net_train = make_option(c("--l_path_net_train"))
        , l_path_net_test = make_option(c("--l_path_net_test"))
       
        # Output
        , model_name = make_option(c("--model_name"), type="character", help="string of model")
        , p_out_pred_train = make_option(c("--p_out_pred_train"), type="character", help="path of output for predicting the training data")
        , p_out_pred_test = make_option(c("--p_out_pred_test"), type="character", help="path of output for predicting the testing data")
        , p_out_model_summary = make_option(c("--p_out_model_summary"), type="character", help="path of output for model summary")
        , p_out_model = make_option(c("--p_out_model"), type="character", help="path of the trained model")

        , p_src_code = make_option(c("--p_src_code"), type="character", help="path of source of code for netprophet")

        , flag_intercept = make_option(c("--flag_intercept"), type="character", help="ON or OFF for intercept generation")
    ))
    
    
    opt = parse_args(opt_parser, positional_arguments=TRUE)$options
    
    source(paste(opt$p_src_code, "code/combine_networks_read_files_into_data_frame.R", sep=""))
    
    train_test(p_binding_train=opt$p_binding_train
               , l_name_net=opt$l_name_net
               , l_path_net_train=opt$l_path_net_train
               , l_path_net_test=opt$l_path_net_test
               , model_name=opt$model_name
               , p_out_pred_train=opt$p_out_pred_train
               , p_out_pred_test=opt$p_out_pred_test
               , p_out_model_summary=opt$p_out_model_summary
               , flag_intercept=opt$flag_intercept
               , p_out_model=opt$p_out_model
              )
    
}