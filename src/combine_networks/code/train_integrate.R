train_integrate = function(idx_per_slave){
    
    # load libraries
    library("xgboost")
    library("mlr")
    library("parallel")
    library("parallelMap")
    library("reshape2")
    
    nbr_slave = mpi.comm.rank()  # get the Rmpi rank (or the slave)
    idx = idx_per_slave[[nbr_slave]]  # get the indexes that will be treated in this slave
    df_prediction = data.frame()  # create df for ouptut
    
    for (i in idx){  # loop over the tfs that will be trained, i can include more than one tf
        # careful some of the TFs are not in the training, I have either to get this differently
        # filter and skip the TFs that do not have binding.
        l_tf_idx = idx_per_train[[i]] 
        
        # get the binding data (labels) for training: subset based on tfs
        l_tf = l_reg[l_tf_idx]
        df_binding_sub = df_binding[df_binding[, 1] %in% l_tf, ]
        train_binding =  df_binding_sub[, 3]
        
        # df_binding_sub = df_binding[l_tf_idx,]
        # df_binding_sub = cbind(rownames=rownames(df_binding_sub), df_binding_sub)
        # df_binding_sub = melt(df_binding_sub, id.vars="rownames")
        # train_binding = df_binding_sub[, 3]
        
        # get the source of info for training
        l_source_info_df_sub = list()
        for (name_net in names(l_source_info_df)){
            df_source_info = l_source_info_df[[name_net]]
            df_source_info = df_source_info[df_source_info[, 1] %in% l_tf, ]
            l_source_info_df_sub[[name_net]] = df_source_info[, 3]
            # df_source_info = l_source_info_df[[name_net]][l_tf_idx,]
            # df_source_info = cbind(rownames=rownames(df_source_info), df_source_info)
            # l_source_info_df_sub[[name_net]] = melt(df_source_info, id.vars="rownames")[, 3]
        }
        df_training = data.frame(l_source_info_df_sub)
        
        # convert characters to factors
        fact_col = colnames(df_training)[sapply(df_training, is.character)]
        for(i in fact_col) set(df_training, j=i, value=factor(df_training[[i]]))
        
        # create tasks for training
        train_task = makeClassifTask(data=data.frame(df_training, target=unlist(train_binding)), target="target")
        
        # create learner
        learner = makeLearner("classif.xgboost", predict.type="prob")
        learner$par.vals = list(objective="binary:logistic"
                                , eval_metric="logloss"
                                , nrounds=20L, eta=0.1)
        
        # set parameter space
        params = makeParamSet(makeDiscreteParam("booster", values=c("gbtree"))
                              , makeIntegerParam("max_depth", lower=1L, upper=10L)
                              , makeNumericParam("min_child_weight", lower=1L, upper=5L)
                              , makeNumericParam("subsample", lower=0.5, upper=1)
                              , makeNumericParam("colsample_bytree", lower=0.5, upper=1)
                              , makeNumericParam("gamma", lower=0, upper=10)
                              , makeNumericParam("lambda", lower=0, upper=1))
        
        # set resampling strategy
        if ((nbr_reg == 1) & (sum(train_binding) <= 1)){
            # put the predictions together
            df_prediction = rbind(df_prediction
                                  , data.frame(REGULATOR=unlist(lapply(unlist(df_binding_sub[, 1]), function(x) gsub('\\.', '-', x)))
                                               , TARGET=unlist(lapply(unlist(df_binding_sub[, 2]), function(x) gsub('\\.', '-', x)))
                                               , PREDICTION=unlist(matrix(0, nrow=length(train_binding), ncol=1))))
        } else{
            if (nbr_reg < 5){
                rdesc = makeResampleDesc("CV", stratify=TRUE, iters=2L)  # for 2-fold CV 
            } else{
            rdesc = makeResampleDesc("CV", stratify=TRUE, iters=5L)  # for 5-fold CV 
            }
            
            # search strategy
            ctrl = makeTuneControlRandom(maxit = 10L)
            
            # set parallel backend
            parallelStartSocket(cpus=detectCores())
            
            # parameter tuning
            mytune = tuneParams(learner=learner
                                , task=train_task
                                , resampling=rdesc
                                , measures=acc
                                , par.set=params
                                , control=ctrl
                                , show.info=TRUE
            )
            # tuned param
            tuned_param = setHyperPars(learner, par.vals = mytune$x)
            
            # Train model with tuned parameters
            model = train(learner=tuned_param, task=train_task)
            
            
            
            predict_train = predict(model, train_task)
            
            # put the predictions together
            df_prediction = rbind(df_prediction
                                  , data.frame(REGULATOR=unlist(lapply(unlist(df_binding_sub[, 1]), function(x) gsub('\\.', '-', x)))
                                               , TARGET=unlist(lapply(unlist(df_binding_sub[, 2]), function(x) gsub('\\.', '-', x)))
                                               , PREDICTION=unlist(predict_train$data$prob.1)))
                                               

        rm(model)
        rm(predict_train)
        gc()  # free memory
        }
    }
    df_prediction
}


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
        p_in_binding = make_option(c("--p_in_binding"), type="character", help="path of binding file for training")
        , l_in_name_net = make_option(c("--l_in_name_net"))
        , l_in_path_net = make_option(c("--l_in_path_net"))
        , in_nbr_reg = make_option(c("--in_nbr_reg"), type="integer")
        , seed = make_option(c("--seed"), type="integer", help="seed for selecting training sets")
        # Logistic
        , slurm_ntasks = make_option(c("--slurm_ntasks"), type="integer", help="number of tasks in slurm")
        # Output
        , p_out_pred = make_option(c("--p_out_pred"), type="character", help="path of output for prediction" )
    ))
    
    opt = parse_args(opt_parser, positional_argument=TRUE)$option
    
    # # debug to comment
    # p_in_binding = '/scratch/mblab/dabid/proj_net/output/yeast/section_5/res_kem_ldbpgenie3_atomic_10cv_tf313_target6112/seed_0/tmp_combine/network_construction/supported/net_binding.tsv'
    # l_in_name_net = "lasso,bart"
    # l_in_path_net ="/scratch/mblab/dabid/proj_net/output/yeast/section_5/res_kem_ldbpgenie3_atomic_10cv_tf313_target6112/seed_0/tmp_combine/network_construction/supported/net_lasso.tsv,/scratch/mblab/dabid/proj_net/output/yeast/section_5/res_kem_ldbpgenie3_atomic_10cv_tf313_target6112/seed_0/tmp_combine/network_construction/supported/net_bart.tsv"
    # nbr_reg = 2
    # slurm_ntasks = 2
    # seed = 1
    # p_in_reg = '/scratch/mblab/dabid/proj_net/output/yeast/section_5/res_kem_ldbpgenie3_atomic_10cv_tf313_target6112/seed_0/tmp_combine/reg.tsv'
    
    # get data from optparse
    p_in_binding = opt$p_in_binding
    l_in_name_net = opt$l_in_name_net
    l_in_path_net = opt$l_in_path_net
    nbr_reg = opt$in_nbr_reg
    slurm_ntasks = opt$slurm_ntasks
    p_out_pred = opt$p_out_pred
    seed = opt$seed
    
    # read data
    # read binding data
    df_binding = read.csv(p_in_binding, header=FALSE, sep='\t')  # label
    # extract list of regulators
    l_reg = unique(df_binding[, 1])
    
    # read evidence scores
    l_in_name_net = strsplit(l_in_name_net, ",")[[1]]
    l_in_path_net = strsplit(l_in_path_net, ",")[[1]]
    nbr_source_info = length(l_in_path_net)  # number of features
    l_source_info_df = list()
    for (i in seq(nbr_source_info)){
        name = l_in_name_net[i]
        path = l_in_path_net[i]
        l_source_info_df[[name]] = read.csv(path, header=FALSE, sep='\t')
    }
    
    # load library
    library("Rmpi")
    set.seed(seed)
    l_tf_indexes = sample(seq(length(l_reg)), length(l_reg), replace=FALSE) # randomize tfs
    idx_per_train = suppressWarnings(split(l_tf_indexes, seq(integer(length(l_reg)/nbr_reg))))  # reg indexes per training
    idx_per_slave = suppressWarnings(split(seq(length(idx_per_train)), seq(slurm_ntasks))) # reg indexes per training per slave
    
    mpi.spawn.Rslaves(nslaves=slurm_ntasks)
    
    mpi.bcast.Robj2slave(df_binding)
    mpi.bcast.Robj2slave(l_source_info_df)
    mpi.bcast.Robj2slave(idx_per_train)
    mpi.bcast.Robj2slave(nbr_reg)
    mpi.bcast.Robj2slave(l_reg)
    mpi.bcast.Robj2slave(train_integrate)
    l_slave = mpi.remote.exec(train_integrate
                              , idx_per_slave
                              , simplify=TRUE
                              , comm=1
                              , ret=TRUE)
    mpi.close.Rslaves()
    
    # collect results from slaves and concatenate results
    df_net = l_slave[[1]]
    for (slave_idx in seq(2, slurm_ntasks, 1)){
        df_net = rbind(df_net, l_slave[[slave_idx]])
    }
    # write np3 predictions
    write.table(
        file=file(p_out_pred)
        , x=df_net
        , row.names=FALSE, col.names=FALSE, sep='\t', quote=FALSE)
    
    
    
}