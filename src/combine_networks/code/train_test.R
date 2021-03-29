# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# | Train model and Predict testing data.                      | #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# # to remove
# p_wd="/scratch/mblab/dabid/netprophet/net_out/kem_np3_full_L1_nbr_reg_40_seed_0_tf281_target6112/tmp/combine_net_ldbp/with_de/"
# p_binding_train=paste(p_wd, 'data_1_fold/train_binding.tsv', sep='')
# l_name_net=c('lasso', 'de', 'bart')
# l_path_net_train=c(paste(p_wd, 'data_1_fold/train_lasso.tsv', sep='')
#                   , paste(p_wd, 'data_1_fold/train_de.tsv', sep='')
#                   , paste(p_wd, 'data_1_fold/train_bart.tsv', sep=''))
# l_path_net_test=c(paste(p_wd, 'tmp_penalize/data_cv/fold0_test_lasso.tsv', sep='')
#                    , paste(p_wd, 'tmp_penalize/data_cv/fold0_test_de.tsv', sep='')
#                    , paste(p_wd, 'tmp_penalize/data_cv/fold0_test_bart.tsv', sep=''))
# model_name="dummy_transform"
# flag_penalize="ON"
# penalize_nbr_fold=10
# p_dir_penalize=paste(p_wd,'tmp_penalize/' , sep='')
# p_out_model=paste(p_wd, 'model_test.RData', sep='')
# p_out_optimal_lambda = paste(p_wd, 'optimal_lambda.tsv', sep='')
# p_out_pred_train=paste(p_wd, 'predict_train.tsv', sep='')
# p_out_pred_test=paste(p_wd, 'predict_test.tsv', sep='')
# # end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# |          *** TRAIN & TEST WITH PENALIZATION ***            | #
# | This function assumes thatm # fold of CVs data generated   | #
# | from training data to select optimal lambda are already    | #
# | generated in p_dir_penalize/data_cv                        | #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
train_test_with_penalization = function( #input
                                        p_binding_train
                                        , l_name_net
                                        , l_path_net_train
                                        , l_path_net_test
                                        , model_name
                                        # output
                                        , p_out_pred_train
                                        , p_out_pred_test
                                        , p_out_model
                                        # penalization
                                        , p_out_optimal_lambda
                                        , flag_penalize
                                        , p_dir_penalize
                                        , penalize_nbr_fold
                                        # logistics
                                        , p_src_code
                                        , nbr_job
                                       ){
    #' Parameters:
    #' 
    #' p_binding_train: path of labels 1: bound, 0: unbound
    #' l_name_net: list of network name included in the training: lasso, de, bart, etc
    #' l_path_net_train: list of path of files for networks (source of info) for training
    #' l_path_net_test: list of path of files for networks (source of info) for testing
    #' model_name: model name such dummy_transform, that will determine the design matrix
    #' p_out_pred_train: path of file of prediction for training set (l_path_net_train) 
    #' p_out_pred_test: path of file of prediction for testing set (l_path_net_test)
    #' p_out_model: path of file for trained model on l_path_net_test (R object)
    #' p_out_optimal_lambda: path of file for optimal lambda (in case of regularization)
    #' flag_penalize: if ON, or L1, or L2, or L1_L2, regularization is effective
    #' p_dir_penalize: path of directory for temporarily/intermediate files for regularization
    #' penalize_nbr_fold: number of folds used for estimating lambda (in case of regularization)
    #' 
    #' 
    #' Returns
    #' No object is returned, however all these files are saved
    #'  
    
   

    # ========================================================== #
    # |              *** DEFINE FUNCTIONS ***                  | #
    # | We code these functions, so they will run in parallel | #
    # | in the workflow                                        | #
    # ========================================================== #

    # ========================================================== #
    # |                   *** Train Model ***                  | #
    # | Train separate 11 modela with (1) all data, and (2)    | #
    # | 10 fold of CV data.                                    | #
    # | (1) will be used for the list of lambdas, and (2) will | #
    # | used to train 10 fold of CV data to pick the optimal   | #
    # | lambda.                                                | #
    # ========================================================== #
    train_model = function(p_binding_train
                           , l_name_net
                           , l_path_net_train
                           , model_name
                           , flag_penalize
                           , p_out_model
                           , p_src_code
                             ){
        # load libraries
        library("glmnet")
        source(paste(p_src_code, "src/combine_networks/code/helper/read_networks_into_data_frame.R", sep=""))
        # prepare data
        train_binding = read.csv(p_binding_train, header=FALSE, sep='\t')[3]
        colnames(train_binding) = "binding"
        df_training = read_data(model_name=model_name
                           , l_name_net=l_name_net
                           , l_path_net=l_path_net_train)
       
        # train model with glmnet
        if (flag_penalize == "L1" || flag_penalize == "ON"){
            alpha = 1
        } else if (flag_penalize == "L2"){
            alpha = 0
        } else if (flag_penalize == "L1_L2"){
            alpha = 0.5
        }
        model = glmnet(as.matrix(df_training)
                       , as.matrix(train_binding)
                       , family="binomial"
                       , alpha=alpha)
        
        # write the model object into a file
        if (!is.null(p_out_model)){
            saveRDS(model, file=p_out_model)
        }                                 
        
        list(df_training, model)
    }
    
    # ========================================================== #
    # |         *** Calculate Sum Log Likelihood ***           | #
    # | The model trained on all training data that will be    | #
    # | used for lambda values. Models trained on CV folds     | #
    # | will use these lambda values to calculate the sum of   | #
    # | log likeligood for every single lambda                 | #
    # ========================================================== #
    calculate_sum_log_likelihood = function(model_all
                                            , model_fold
                                            , p_binding_test
                                            , l_name_net
                                            , l_path_net_test
                                            , l_path_net_train
                                            , model_name
                                            , p_out_sum_log_likelihood
                                            , p_src_code){
        source(paste(p_src_code, "src/combine_networks/code/helper/read_networks_into_data_frame.R", sep=""))
        
        # read binding data for testing
        test_binding = read.csv(p_binding_test, header=FALSE, sep='\t')[3]
        colnames(test_binding) = 'binding'
        
        # read source info of testing in dataframe
        # due to data difference, some of the columns will be missing
        # testing data, so read training data to pad with 0s for them
        df_testing = read_data(model_name=model_name
                              , l_name_net=l_name_net
                              , l_path_net=l_path_net_test)
        df_training = read_data(model_name=model_name
                                , l_name_net=l_name_net
                                , l_path_net=l_path_net_train)
        l_missing_col = setdiff(colnames(df_training), colnames(df_testing))
        df_testing[l_missing_col] = 0
        df_testing = df_testing[colnames(df_training)]
        
        # start calculating sum log likelihoods for every lambda 
        # gotten the model that was training on all training data
        l_sum_log_likelihood = c()
        for (i in 1:length(model_all$lambda)){
            lambda_value = model_all$lambda[i]
            tryCatch({
                predict_test = predict(model_fold, newx=as.matrix(df_testing), s=lambda_value, type="response")
                sum_log_likelihood = sum(log(c(predict_test[test_binding==1], 1-predict_test[test_binding==0])))
            }, error=function(e){
                print(lambda_value)
                print(e)
            }, finally={
               l_sum_log_likelihood = c(l_sum_log_likelihood, sum_log_likelihood) 
            })
        }
        
        # write sum log likelihood for every lambda into files
        if (!is.null(p_out_sum_log_likelihood)){
            write.table(file=file(p_out_sum_log_likelihood)
                        , data.frame(matrix(l_sum_log_likelihood, nrow=1, byrow=FALSE))
                        , row.names=FALSE, col.names=FALSE, sep='\t', quote=FALSE)
        }
        
        # return the list of sum of log likelihood
        l_sum_log_likelihood
    }
    
    # ========================================================== #
    # |         *** Predict and Write Predictions ***          | #
    # | Given a model and new data, predict the labels for new | #
    # | data, and write them into a file                       | #
    # ========================================================== #
    predict_and_write_predictions = function(model
                                             , df_new_data
                                             , optimal_lambda
                                             , l_reg
                                             , l_target
                                             , p_out_pred
                                             ){
        library("glmnet")
        predictions = predict(model, newx=as.matrix(df_new_data), s=optimal_lambda, type="response")
        write.table(file=file(p_out_pred)
                    , x=data.frame(REGULATOR=l_reg, TARGE=l_target, VALUE=predictions)
                    , row.names=FALSE, col.names=FALSE, sep='\t', quote=FALSE)
        predictions
    }
    
    # ========================================================== #
    # |              *** DEFINE FUNCTIONS ***                  | #
    # ========================================================== #
    
    # ========================================================== #
    # |                 *** WORKFLOW STARTS ***                | #
    # ========================================================== #
    # load libraries
    library("foreach")
    library("doParallel")
    
    # Allocate cores for parallel runs, allocate as many as folds+1
    cl = makeCluster(min(nbr_job, detectCores(logical=FALSE)[1]-1))
    registerDoParallel(cl)
    
    
    
    ## 1. Train models, train on all training data, train on fold CVs
    # prepare data
    l_p_binding_train = c(p_binding_train, unlist(lapply(seq(0, penalize_nbr_fold-1, 1)
                            , function(x) paste(p_dir_penalize, "data_cv/fold", x, "_train_binding.tsv", sep=""))))
    l_l_path_net_train = list()
    l_l_path_net_train[[1]] = l_path_net_train
    for (f in seq(penalize_nbr_fold)){
        l_l_path_net_train[[f+1]] = unlist(lapply(l_name_net
                                    , function(x) paste(p_dir_penalize, "data_cv/fold", f-1, "_train_", x, ".tsv", sep="")))
    }
    l_p_out_model = c(p_out_model, unlist(lapply(seq(0, penalize_nbr_fold-1, 1)
                                 , function(x) paste(p_dir_penalize, "predictions/fold", x, "_model.RData", sep=""))))
    # train models in parallel (lunch parallel jobs)
    l_df_training_model = foreach(p_binding_train_each=l_p_binding_train
                      , l_path_net_train_each=l_l_path_net_train
                      , p_out_model_each=l_p_out_model
                      ) %dopar% {
                            train_model(p_binding_train=p_binding_train_each
                                        , l_name_net=l_name_net
                                        , l_path_net_train=l_path_net_train_each
                                        , model_name=model_name
                                        , flag_penalize=flag_penalize
                                        , p_out_model=p_out_model_each
                                        , p_src_code=p_src_code)
    } 
    ## 2. After training models, calculate sum(log(likelihood))
    # prepare data
    model_for_all_training = l_df_training_model[[1]][[2]]  # get the model trained on all training data
    l_l_path_net_test = list()  # define testing data
    for (f in seq(penalize_nbr_fold)){
        l_l_path_net_test[[f]] = unlist(lapply(l_name_net
                                 , function(x) paste(p_dir_penalize, "data_cv/fold", f-1, "_test_", x, ".tsv", sep="")))
    }
    l_p_out_sum_log_likelihood = unlist(lapply(seq(0, penalize_nbr_fold-1, 1)  # list of output files for sum(log(likelihood))
                         , function(x) paste(p_dir_penalize, "predictions/fold", x, "_sum_log_likelihood.tsv", sep="")))
    
    # calculate sum(log(likelihood)) for every fold of CV in parallel
    # launch jobs as many as CV folds                                              
    l_l_sum_log_likelihood = foreach(
              model_for_one_fold=lapply(seq(2, 11, 1), function(x) l_df_training_model[[x]][[2]])
            , p_binding_test_each=unlist(
                lapply(seq(0, 9, 1), function(x) paste(p_dir_penalize
                      , "data_cv/fold", x, '_test_binding.tsv', sep="")))
            , l_path_net_test_each=l_l_path_net_test
            , l_path_net_train_each=l_l_path_net_train[seq(2, 11, 1)]
            , p_out_sum_log_likelihood_each=l_p_out_sum_log_likelihood
            ) %dopar%{
        calculate_sum_log_likelihood(model_all=model_for_all_training
                                    , model_fold=model_for_one_fold
                                    , p_binding_test=p_binding_test_each
                                    , l_name_net=l_name_net
                                    , l_path_net_test=l_path_net_test_each
                                    , l_path_net_train=l_path_net_train_each
                                    , model_name=model_name
                                    , p_out_sum_log_likelihood=p_out_sum_log_likelihood_each
                                    , p_src_code=p_src_code)
    }
                                          
    ## 3. Select Optimal lambda and do predictions for testing data
    l_mean_log_likelihood = c()
    for (i in 1:length(model_for_all_training$lambda)){
        l_log_likelihood = data.frame(l_l_sum_log_likelihood)[i, ]
        l_mean_log_likelihood = c(l_mean_log_likelihood, mean(unlist(l_log_likelihood)))
    }
    optimal_lambda = model_for_all_training$lambda[which(l_mean_log_likelihood == max(l_mean_log_likelihood))][1]
    # write optimal lambda
    write.table(file=file(p_out_optimal_lambda)
             , data.frame(c(optimal_lambda))
             , row.names=FALSE, col.names=FALSE, sep='\t', quote=FALSE)
    
    ## 4. After calculating optimal lambda, do predictions
    # prepare training data
    df_net_train = read.csv(l_path_net_train[[1]], header=FALSE, sep='\t')
    l_reg_train = unlist(df_net_train[1])
    l_target_train = unlist(df_net_train[2])
    df_training = l_df_training_model[[1]][[1]]
    
    # prepare testing data
    df_net_test = read.csv(l_path_net_test[[1]], header=FALSE, sep='\t')
    l_reg_test = unlist(df_net_test[1])
    l_target_test = unlist(df_net_test[2])
    df_testing = read_data(model_name=model_name  # prepare testing data
                              , l_name_net=l_name_net
                              , l_path_net=l_path_net_test)
    # pad with 0s for missing columns
    l_missing_col = setdiff(colnames(df_training), colnames(df_testing))
    df_testing[l_missing_col] = 0
    df_testing = df_testing[colnames(df_training)]
    
    # do the predictions for training and testing in parallel
    l_predictions = foreach(df_new_data_each=list(df_training, df_testing)
            , l_reg_each=list(l_reg_train, l_reg_test)
            , l_target_each=list(l_target_train, l_target_test)
            , p_out_pred_each=c(p_out_pred_train, p_out_pred_test)
            ) %dopar% {
        predict_and_write_predictions(model=model_for_all_training
                                      , df_new_data=df_new_data_each
                                      , optimal_lambda=optimal_lambda
                                      , l_reg=l_reg_each
                                      , l_target=l_target_each
                                      , p_out_pred=p_out_pred_each
                                      )}
                    
    # close connection (for parallel runs)
    stopCluster(cl) 
                                             
}
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# |          *** TRAIN & TEST WITH PENALIZATION ***            | #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
                                         

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# |            *** TRAIN & TEST PLAIN & SIMPLE ***             | #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
train_test = function(p_in_binding_train
                      , l_in_name_net
                      , l_in_path_net_train
                      , l_in_path_net_test
                      , in_model_name
                      , flag_intercept
                      , p_out_pred_train
                      , p_out_pred_test
                      , p_out_model_summary
                      , p_out_model){
    warnings()
    
    # Read Binding data
    train_binding = read.csv(p_in_binding_train, header=FALSE, sep='\t')[3]
    
    # Read first network to get the list of regulators/targets for the training/testing
    p_net_train = l_in_path_net_train[1]
    df_net_train = read.csv(p_net_train, header=FALSE, sep='\t')
    l_reg_train = df_net_train[1]
    l_target_train = df_net_train[2]
    
    p_net_test = l_in_path_net_test[1]
    df_net_test = read.csv(p_net_test, header=FALSE, sep='\t')
    l_reg_test = df_net_test[1]
    l_target_test = df_net_test[2]
    
    # Training: Read source of information from files into DataFrame
    df_training = read_data(l_name_net=l_in_name_net
                            , l_path_net=l_in_path_net_train
                            , model_name=in_model_name)
    # Training: Training the model with lars
    if (flag_intercept == "ON"){
        model = glm(binding ~ ., data=data.frame(binding=unlist(train_binding), df_training), family=binomial)
    } else{
        model = glm(binding ~ . -1, data=data.frame(binding=unlist(train_binding), df_training), family=binomial)
    }
    # Testing: Read source of information from files into DataFrame
    df_testing = read_data(l_name_net=l_in_name_net
                           , l_path_net=l_in_path_net_test
                           , model_name=in_model_name
                          )
    if (dim(df_training)[2] != dim(df_testing)[2]){
        # pad with 0s for missing columns
        l_missing_col = setdiff(colnames(df_training), colnames(df_testing))
        df_testing[l_missing_col] = 0
        df_testing = df_testing[colnames(df_training)]
    }
        
    # Predictions: Predict Training  & Testing data
    predict_train = predict(model, df_training, type="response")
    predict_test = predict(model, df_testing, type="response")
    # Write Predictions and Model Summary
    saveRDS(model, file=p_out_model)
    capture.output(summary(model), file=p_out_model_summary, append=FALSE)
    write.table(
        file=file(p_out_pred_train)
        , x=data.frame(REGULATOR=l_reg_train, TARGET=l_target_train, VALUE=predict_train)
        , row.names=FALSE, col.names=FALSE, sep='\t', quote=FALSE)
    
    write.table(
        file=p_out_pred_test
        , x=data.frame(REGULATOR=l_reg_test, TARGET=l_target_test, VALUE=predict_test)
        , row.names=FALSE, col.names=FALSE,  sep='\t', quote=FALSE)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# |           *** END TRAIN & TEST PLAIN SIMPLE ***            | #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
                                         
                                         
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# |                     *** MAIN FUNCTION ***                  | #
# |           This function will start the workflow            | #
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
        p_binding_train = make_option(c("--p_in_binding_train"), type="character", help="path of binding file for training")
        , l_name_net = make_option(c("--l_in_name_net"))
        , l_path_net_train = make_option(c("--l_in_path_net_train"))
        , l_path_net_test = make_option(c("--l_in_path_net_test"))
        , model_name = make_option(c("--in_model_name"), type="character", help="string of model")
        
        # Output
        , p_out_pred_train = make_option(c("--p_out_pred_train"), type="character", help="path of output for predicting the training data")
        , p_out_pred_test = make_option(c("--p_out_pred_test"), type="character", help="path of output for predicting the testing data")
        , p_out_model_summary = make_option(c("--p_out_model_summary"), type="character", help="path of output for model summary")
        , p_out_model = make_option(c("--p_out_model"), type="character", help="path of the trained model")
        , p_out_optimal_lambda = make_option(c("--p_out_optimal_lambda"), type="character", help="path of file for optimal lambda")

        # logistics
        , p_src_code = make_option(c("--p_src_code"), type="character", help="path of source of code for netprophet")
        , nbr_job = make_option(c("--nbr_job"), type="integer", help="number of tasks/jobs running in parallel")
        
        # prediction parameters/options
        , flag_intercept = make_option(c("--flag_intercept"), type="character", help="ON or OFF for intercept generation")
        
        # penalization
        , flag_penalize = make_option(c("--flag_penalize"), type="character", help="ON or OFF for penalization/regularization")
        , p_dir_penalize = make_option(c("--p_dir_penalize"), type="character", help="path of directory for penalization intermediate files")
        , penalize_nbr_fold = make_option(c("--penalize_nbr_fold"), type="integer", help="number of CV folds for penalization/regularization")                                      
    ))
    
    
    opt = parse_args(opt_parser, positional_arguments=TRUE)$options
    
    # ====================================================== #
    # |           *** Load helper libraries***             | #
    # ====================================================== #
    source(paste(opt$p_src_code, "src/combine_networks/code/helper/read_networks_into_data_frame.R", sep=""))
    
    # ====================================================== #
    # |                *** Train & Test ***                | #
    # ====================================================== #
    if (opt$flag_penalize == "OFF"){
        train_test(p_in_binding_train=opt$p_in_binding_train
                   , l_in_name_net=strsplit(opt$l_in_name_net, ",")[[1]]
                   , l_in_path_net_train=strsplit(opt$l_in_path_net_train, ",")[[1]]
                   , l_in_path_net_test=strsplit(opt$l_in_path_net_test, ",")[[1]]
                   , in_model_name=opt$in_model_name
                   , p_out_pred_train=opt$p_out_pred_train
                   , p_out_pred_test=opt$p_out_pred_test
                   , p_out_model_summary=opt$p_out_model_summary
                   , flag_intercept=opt$flag_intercept
                   , p_out_model=opt$p_out_model)
    } else if (opt$flag_penalize == "ON"){
        train_test_with_penalization(# all training data parameters
                                     p_binding_train=opt$p_in_binding_train
                                     , l_name_net=strsplit(opt$l_in_name_net, ",")[[1]]
                                     , l_path_net_train=strsplit(opt$l_in_path_net_train, ",")[[1]]
                                     , l_path_net_test=strsplit(opt$l_in_path_net_test, ",")[[1]]
                                     , model_name=opt$in_model_name
                                     # output parameters
                                     , p_out_model=opt$p_out_model
                                     , p_out_pred_train=opt$p_out_pred_train
                                     , p_out_pred_test=opt$p_out_pred_test
                                     , p_out_optimal_lambda=opt$p_out_optimal_lambda
                                     # penalization parameters
                                     , flag_penalize=opt$flag_penalize
                                     , penalize_nbr_fold=opt$penalize_nbr_fold
                                     , p_dir_penalize=opt$p_dir_penalize  # will have 10 fold of CV data
                                     # logistics
                                     , p_src_code=opt$p_src_code
                                     , nbr_job=opt$nbr_job
                                    )
    }
    
}
                                         
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# |                   *** END MAIN FUNCTION ***                | #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #                                            