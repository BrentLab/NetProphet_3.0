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

create_sign_string = function(row){
  c = ""
  for (r in row){
    if (r>0){
      c = paste(c, 'P', sep='')
    } else if (r<0){
      c = paste(c, 'N', sep='')
    }else{
      c = paste(c, 'Z', sep='')
    }
  }
  c
}

# ===================================================== #
# |          *** End Helper functions ***             | #
# ===================================================== #



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
                           , l_name_net){
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
    l_sign = apply(df_source_info, 1, create_sign_string)  # create the sign matrix using the helper function create_sign_string
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

                                                                          
read_data = function(l_name_net
                     , l_path_net
                     , model_name
                     , sep='\t'){
    

  
}

if (sys.nframe() == 0){
    library("optparse")
    library("fastDummies")
    
    opt_parser = OptionParser(option_list=list(
      make_option(c("--l_name_net"))
      , make_option(c("--l_path_net"))
      , make_option(c("--sep"), type="character", default='\t')
      , make_option(c("--model_name"), type="character")
    ))
    
    opt = parse_args(opt_parser, positional_arguments=TRUE)$options  
    
    l_name_net=opt$l_name_net
    l_path_net=opt$l_path_net
    model_name=opt$model_name
    sep=opt$sep
  
    # Main function
    l_name_net = strsplit(l_name_net, ",")[[1]]
    l_path_net = strsplit(l_path_net, ",")[[1]]
    
    nbr_net = length(l_path_net)
    l_source_info_df = list()
    for (i in seq(nbr_net)){
        name = l_name_net[i]
        path = l_path_net[i]
        l_source_info_df[[name]] = unlist(read.csv(path, header=FALSE, sep=sep)[3])
    }
    df_source_info = data.frame(l_source_info_df)
    rownames(df_source_info) = NULL

    if (model_name == "dummy_transform"){
        df = dummy_transform(df_source_info
                             , l_name_net)
    } else if (model_name == "transform"){
        df = transform(df_source_info
                       , l_name_net)
    }

    df
    
    # End Main function
}

