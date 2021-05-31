# ===================================================== #
# | Read source of information and prepare the design | #
# | matrix for training/testing a logistic regression | #
# | model. There are a number of different desing     | #
# | matrices transform, dummy_transform, reduced, etc | #
# ===================================================== #

# ===================================================== #
# |             *** Helper functions ***              | #
# ===================================================== #

# interactions
create_interaction = function(df_source_info, idx, col_name){
  df_interaction = data.frame(matrix(1, ncol=1, nrow=dim(df_source_info)))
  colnames(df_interaction) = c(col_name)
  for (i in idx){
    df_interaction = df_interaction*df_source_info[, i]
  }
  abs(df_interaction)
}

# for combination
create_sign_string = function(row
                              , str_sign){
    c = ""
    if (str_sign == 'PNZ'){
      for (r in row){
        if (r>0){
            c = paste(c, 'P', sep='')
        } else if (r<0){
            c = paste(c, 'N', sep='')
        } else {
            c = paste(c, 'Z', sep='')
        }
      }
    } else if (str_sign == 'PN'){
        for (r in row){
            if (r>0){
                c = paste(c, 'P', sep='')
            } else {
                c = paste(c, 'N', sep='')
            }
        }
    } else {
      q()
    }
  c
}

# ===================================================== #
# |          *** End Helper functions ***             | #
# ===================================================== #

dummy_no_interaction = function(df_source_info
                                , l_name_net
                                , str_sign){
  # dummy variables
  l_sign = apply(df_source_info, 1, create_sign_string, str_sign)  # create the sign matrix using the helper function create_sign_string
  df_sign = data.frame(l_sign)
  colnames(df_sign) = c("sign")
  df_dummy = dummy_cols(df_sign)
  s_zeros = "sign_"
  for (i in seq(dim(df_source_info)[2])){
    s_zeros = paste(s_zeros, "Z", sep="")
  }                                                                          
  df_dummy = df_dummy[, -c(which(colnames(df_dummy) == "sign"), which(colnames(df_dummy) == s_zeros)) ]
  
  cbind(abs(df_source_info), df_dummy)
  
}


# ===================================================== #
# |               *** Design Matrices ***             | #
# ===================================================== #

# ----------------------------------------------------- #
# |                  * transform *                    | #
# | source of information, their transformation,      | #
# | interaction of two, their transformation          | #
# ----------------------------------------------------- #

transform = function(df_source_info
                     , l_name_net){
    
    # interactions
    nbr_source_info = length(l_name_net)
    l_interaction = list()  # here the interactions will be stored
    combination_size = 2  # the number of elements in the interaction: 2 only interactions of two source of info are considered
    c = combn(seq_len(nbr_source_info), combination_size)  # 2 rows for indexes of source of info included in the interaction, columns the different interactions of 2 [2 x 6]
    
    # calculate the interactions from c
    for (i in seq(dim(c)[2])){
      idx = c[, i]  # take interaction by interaction
      col_name = 'i'  # prefix of the interaction column
      # build the column name of the interaction
      for (j in idx){
        col_name = paste(col_name, l_name_net[j], sep='_')
      }
      # concatenate all interactions
      l_interaction[col_name] = create_interaction(df_source_info, idx, col_name) 
    }
    
    df_interactions = data.frame(l_interaction)
    
    # transform atomic source info
    l_transformed_source_info = list()
    for (name in l_name_net){
      # log transformation
      l_transformed_source_info[[paste("log_", name, sep="")]] = sapply(unlist(df_source_info[, name]), function(x) log(abs(x)+1))
      # sqrt transformation
      l_transformed_source_info[[paste("sqrt_", name, sep="")]] = sapply(unlist(df_source_info[, name]), function(x) abs(x)^0.5)
      # square transformation
      l_transformed_source_info[[paste("square_", name, sep="")]] = sapply(unlist(df_source_info[, name]), function(x) x^2)
    }
    
    df_transformed_source_info = data.frame(l_transformed_source_info)
    
    # transform interactions
    l_transformed_interactions = list()
    col_names_interactions = colnames(df_interactions)
    
    for (i in seq_len(dim(df_interactions)[2])){
      col_name = col_names_interactions[i]
      # log transformation
      l_transformed_interactions[[paste("log_", col_name, sep="")]] = sapply(unlist(df_interactions[, col_name]), function(x) log(abs(x)+1))
      # sqrt transformation
      l_transformed_interactions[[paste("sqrt_", col_name, sep="")]] = sapply(unlist(df_interactions[, col_name]), function(x) abs(x)^0.5)
      # square transformation
      l_transformed_interactions[[paste("square_", col_name, sep="")]] = sapply(unlist(df_interactions[, col_name]), function(x) x^2)  
    }
    df_transformed_interactions = data.frame(l_transformed_interactions)
                                                                                
    cbind(abs(df_source_info), df_transformed_source_info, df_interactions, df_transformed_interactions)                                                                                    
}
                                                                                
# ----------------------------------------------------- #
# |                * End transform *                  | #
# ----------------------------------------------------- #                                                                         
                                                                                
                                                                                
# ----------------------------------------------------- #
# |               * dummy transform *                 | #
# | source of information, their transformation,      | #
# | all interactions, their transformation            | #
# ----------------------------------------------------- #

dummy_transform = function(df_source_info
                           , l_name_net
                           , str_sign){
    # interactions
    nbr_source_info = length(l_name_net)
    l_interaction = list()
    for (combination_size in seq(2, nbr_source_info-1, 1)){
        # combinatioin_size: how many elements in the iteraction: 2, 3, ..., nbr_source_info
        # c: a dataframe that includes the indexes of elements of interaction: 
        #    rows: indexes of elements, columns: the different interactions
        c = combn(seq_len(nbr_source_info), combination_size)
        for (i in seq(dim(c)[2])){
          idx = c[, i]
          col_name = 'i'
          for (j in idx){
            col_name = paste(col_name, l_name_net[j], sep='_')
          }
        l_interaction[col_name] = create_interaction(df_source_info, idx, col_name) 
        }
    }
    df_interactions = data.frame(l_interaction)
    
    # transform atomic source info
    l_transformed_source_info = list()
    for (name in l_name_net){
      l_transformed_source_info[[paste("log_", name, sep="")]] = sapply(unlist(df_source_info[, name]), function(x) log(abs(x)+1))
      l_transformed_source_info[[paste("sqrt_", name, sep="")]] = sapply(unlist(df_source_info[, name]), function(x) abs(x)^0.5)
      l_transformed_source_info[[paste("square_", name, sep="")]] = sapply(unlist(df_source_info[, name]), function(x) x^2)
    }
    df_transformed_source_info = data.frame(l_transformed_source_info)
    
    # transform interactions
    l_transformed_interactions = list()
    col_names_interactions = colnames(df_interactions)
    
    for (i in seq_len(dim(df_interactions)[2])){
      col_name = col_names_interactions[i]
      l_transformed_interactions[[paste("log_", col_name, sep="")]] = sapply(unlist(df_interactions[, col_name]), function(x) log(abs(x)+1))
      l_transformed_interactions[[paste("sqrt_", col_name, sep="")]] = sapply(unlist(df_interactions[, col_name]), function(x) abs(x)^0.5)
      l_transformed_interactions[[paste("square_", col_name, sep="")]] = sapply(unlist(df_interactions[, col_name]), function(x) x^2)  
    }
    df_transformed_interactions = data.frame(l_transformed_interactions)
    
    # dummy variables
    l_sign = apply(df_source_info, 1, create_sign_string, str_sign)  # create the sign matrix using the helper function create_sign_string
    df_sign = data.frame(l_sign)
    colnames(df_sign) = c("sign")
    df_dummy = dummy_cols(df_sign)
    s_zeros = "sign_"
    for (i in seq(dim(df_source_info)[2])){
        s_zeros = paste(s_zeros, "Z", sep="")
    }                                                                          
    df_dummy = df_dummy[, -c(which(colnames(df_dummy) == "sign"), which(colnames(df_dummy) == s_zeros)) ]
    
    cbind(abs(df_source_info), df_transformed_source_info, df_interactions, df_transformed_interactions, df_dummy)
    
}
# ----------------------------------------------------- #
# |             * End dummy transform *               | #
# ----------------------------------------------------- #
                                                                                
# ----------------------------------------------------- #
# |                    * reduced *                    | #
# | df_source_info should included: lasso, de, bart   | #
# | and pwm; or lasso, bart, and pwm.                 | #                             
# ----------------------------------------------------- # 
reduced = function(df_source_info
                  , l_name_net){
    l_design_matrix = list()
    
    # atomic and transformations
    for (name in l_name_net){
        if (name == "lasso"){
            l_lasso = unlist(df_source_info[, name])
            l_design_matrix[["lasso"]] = l_lasso
            l_design_matrix[["log_lasso"]] = sapply(l_lasso, function(x) log(abs(x) + 1))                                                        
        } else if (name == "de"){
            l_de = unlist(df_source_info[, name])
            l_design_matrix[["de"]] = l_de
            l_design_matrix[["sqrt_de"]] = sapply(l_de, function(x) abs(x)^0.5)
        } else if (name == "bart"){
            l_bart = unlist(df_source_info[, name])
            l_design_matrix[["bart"]] = l_bart
            l_design_matrix[["sqrt_bart"]] = sapply(l_bart, function(x) abs(x)^0.5)
            l_design_matrix[["square_bart"]] = sapply(l_bart, function(x) x^2)
        } else if (name == "pwm"){
            l_pwm = unlist(df_source_info[, name])
            l_design_matrix[["pwm"]] = l_pwm
            l_design_matrix[["sqrt_pwm"]] = sapply(l_pwm, function(x) abs(x)^0.5)
            l_design_matrix[["square_pwm"]] = sapply(l_pwm, function(x) x^2)
        }
    }
    
    # interactions of 2 and does not include pwm network
    combination_size = 2  # the number of elements in the interaction: 2 only interactions of two source of info are considered
    nbr_source_info = length(l_name_net) 
    if ('pwm' %in% l_name_net){                                                   
      df_source_info = df_source_info[, !names(df_source_info) %in% c('pwm')]
      nbr_source_info = length(l_name_net) - 1
    }
                                     
    c = combn(seq_len(nbr_source_info), combination_size)  # 2 rows for indexes of source of info included in the interaction, columns the different interactions of 2 [2 x 6]
   
    # calculate the interactions from c
    for (i in seq(dim(c)[2])){
      idx = c[, i]  # take interaction by interaction
      col_name = 'i'  # prefix of the interaction column
      # build the column name of the interaction
      for (j in idx){
        col_name = paste(col_name, l_name_net[j], sep='_')
      }
      # concatenate all interactions
      l_design_matrix[col_name] = create_interaction(df_source_info, idx, col_name) 
    }
    
    # dummy variables    
    if (nbr_source_info == 3){
        l_design_matrix[['pos_pos_pos']] = as.integer(l_lasso>0 & l_de>0 & l_bart>0)
        l_design_matrix[['pos_pos_neg']] = as.integer(l_lasso>0 & l_de>0 & l_bart<0)
        l_design_matrix[['pos_neg_pos']] = as.integer(l_lasso>0 & l_de<0 & l_bart>0)
        l_design_matrix[['pos_neg_neg']] = as.integer(l_lasso>0 & l_de<0 & l_bart<0)
        l_design_matrix[['neg_neg_neg']] = as.integer(l_lasso<0 & l_de<0 & l_bart<0)
        l_design_matrix[['neg_neg_pos']] = as.integer(l_lasso<0 & l_de<0 & l_bart>0)
        l_design_matrix[['neg_pos_pos']] = as.integer(l_lasso<0 & l_de>0 & l_bart>0)
        l_design_matrix[['neg_pos_neg']] = as.integer(l_lasso<0 & l_de>0 & l_bart<0)
        l_design_matrix[['nz_z_nz']]     = as.integer(l_lasso!=0 &  l_de==0 & l_bart!=0)
        l_design_matrix[['z_z_nz']]      = as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
        l_design_matrix[['z_nz_z']]      = as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
        l_design_matrix[['z_nz_nz']]     = as.integer(l_lasso==0 & l_de!=0 & l_bart!=0)
    } else if (nbr_source_info == 2){
        l_design_matrix[['pos_pos']] = as.integer(l_lasso>0 & l_de>0)
        l_design_matrix[['pos_neg']] = as.integer(l_lasso>0 & l_de<0)
        l_design_matrix[['neg_pos']] = as.integer(l_lasso<0 & l_de>0)
        l_design_matrix[['neg_neg']] = as.integer(l_lasso<0 & l_de<0)
        l_design_matrix[['nz_z']]    = as.integer(l_lasso!=0 & l_de==0)
        l_design_matrix[['z_nz']]    = as.integer(l_lasso==0 & l_de!=0)
    }                                   
    data.frame(l_design_matrix)                                                   
}
                                                                              
# ----------------------------------------------------- #
# |                  * End reduced *                  | #
# ----------------------------------------------------- #                                                                                 

atomic = function(df_source_info
                  , l_name_net){
    
    l_design_matrix = list()
    for (name_net in l_name_net){
        l_design_matrix[[name_net]] = df_source_info[, name_net] 
    }
    df = data.frame(l_design_matrix)
    df
}


atomic_sign = function(df_source_info
                        , l_name_net
                        , str_sign){
  
  create_dummy_sign = function(item, str_sign){
    s = ''
    if (str_sign == 'PN'){
      if (item > 0){
        s = 'P'
      } else {
        s = 'N'
      }
    } else if (str_sign == 'PNZ'){
      if (item > 0){
        s = 'P'
      } else if (item < 0){
        s = 'N'
      } else{
        s = 'Z'
      }
    }
  }
  l_design_matrix = list()
  for (name_net in l_name_net){
    l_design_matrix[[paste(name_net, 'sign',sep='_')]] = sapply(unlist(df_source_info[, name_net]), create_dummy_sign, str_sign)
  }
  df_design_matrix = dummy_cols(data.frame(l_design_matrix)
                                , remove_first_dummy=TRUE
                                , remove_selected_columns=TRUE)
  df_design_matrix = cbind(df_source_info, df_design_matrix)
  df_design_matrix
  
}

# ----------------------------------------------------- #
# |                * Main Function *                  | #
# ----------------------------------------------------- #         
read_data = function(model_name
                     , l_name_net
                     , l_path_net
                     , sep='\t'){
    library("fastDummies")
    nbr_net = length(l_path_net)
    l_source_info_df = list()
    for (i in seq(nbr_net)){
        name = l_name_net[i]
        path = l_path_net[i]
        l_source_info_df[[name]] = unlist(read.csv(path, header=FALSE, sep=sep)[3])
    }
    df_source_info = data.frame(l_source_info_df)
    rownames(df_source_info) = NULL

    if (model_name == "dummy_transform_pnz"){
        df = dummy_transform(df_source_info
                             , l_name_net
                             , 'PNZ')
    } else if (model_name == "dummy_transform_pn"){
        df = dummy_transform(df_source_info
                             , l_name_net
                             , 'PN')
    } else if (model_name == "transform"){
        df = transform(df_source_info
                       , l_name_net)
    } else if (model_name == "reduced"){
        df = reduced(df_source_info
                     , l_name_net)
    } else if (model_name == "atomic"){
      nbr_net = length(l_path_net)
      df = data.frame(unlist(read.csv(l_path_net[1], header=FALSE, sep=sep)[3]))
      for (i in seq(2, nbr_net, 1)){
        path = l_path_net[i]
        df = cbind(df,  unlist(read.csv(path, header=FALSE, sep=sep)[3]))
      }
      rownames(df) = NULL
      colnames(df) = l_name_net
      
    } else if (model_name == "dummy_no_interaction_pn"){
      df = dummy_no_interaction(df_source_info
                                , l_name_net
                                , 'PN')
    } else if (model_name == "atomic_sign_pn"){
      df = atomic_sign(df_source_info
                       , l_name_net
                       , 'PN')
    } else if (model_name == "atomic_sign_pnz"){
      df = atomic_sign(df_source_info
                       , l_name_net
                       , 'PNZ')
    }
    
    df
}
# ----------------------------------------------------- #
# |             * End Main Function *                 | #
# ----------------------------------------------------- #         
if (sys.nframe() == 0){
    library("optparse")
    
    opt_parser = OptionParser(option_list=list(
      make_option(c("--l_name_net"))
      , make_option(c("--l_path_net"))
      , make_option(c("--sep"), type="character", default='\t')
      , make_option(c("--model_name"), type="character")
    ))
    
    opt = parse_args(opt_parser, positional_arguments=TRUE)$options  
    
    # process arguments to prepare read_data input
    l_name_net=opt$l_name_net
    l_path_net=opt$l_path_net
    model_name=opt$model_name
    sep=opt$sep
    l_name_net = strsplit(l_name_net, ",")[[1]]
    l_path_net = strsplit(l_path_net, ",")[[1]]
    
    # call main function read_data
    read_data(model_name=model_name
              , l_name_net=l_name_net
              , l_path_net=l_path_net)
    
}


