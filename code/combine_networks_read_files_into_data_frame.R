# =================================================== #
# |                *** Only dummy***                | #
# =================================================== #
only_dummy_ldbp = function(l_lasso
                      , l_de
                      , l_bart
                      , l_pwm){
  df = data.frame(pos_pos_pos=as.integer(l_lasso>0 & l_de>0 & l_bart>0)
                  , pos_pos_neg=as.integer(l_lasso>0 & l_de>0 & l_bart<0)
                  , pos_neg_pos=as.integer(l_lasso>0 & l_de<0 & l_bart>0)
                  , pos_neg_neg=as.integer(l_lasso>0 & l_de<0 & l_bart<0)
                  , neg_neg_neg=as.integer(l_lasso<0 & l_de<0 & l_bart<0)
                  , neg_neg_pos=as.integer(l_lasso<0 & l_de<0 & l_bart>0)
                  , neg_pos_pos=as.integer(l_lasso<0 & l_de>0 & l_bart>0)
                  , neg_pos_neg=as.integer(l_lasso<0 & l_de>0 & l_bart<0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0)
                  , z_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
                  , z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0))
  df
}

only_dummy_lbp = function(l_lasso
                          , l_bart
                          , l_pwm
){
  df = data.frame(pos_pos=as.integer(l_lasso>0 & l_bart>0)
                  , pos_neg=as.integer(l_lasso>0 & l_bart<0)
                  , nz_z=as.integer(l_lasso!=0 & l_bart==0)
                  , neg_neg=as.integer(l_lasso<0 & l_bart<0)
                  , neg_pos=as.integer(l_lasso<0 & l_bart>0)
                  , z_nz=as.integer(l_lasso==0 & l_bart!=0))
  df
}

# =================================================== #
# |            *** atomic transform***              | #
# =================================================== #
atomic_transform_ldbp = function(l_lasso
                                  , l_de
                                  , l_bart
                                  , l_pwm){
    df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                      , sqrt_de=sapply(unlist(l_de), function(x) abs(x)^0.5)
                      , square_bart=sapply(unlist(l_bart), function(x) x^2)
                      , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                      , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                      , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
                    )
    df
}

atomic_transform_lbp = function(l_lasso
                                 , l_bart
                                 , l_pwm){
    df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                      , square_bart=sapply(unlist(l_bart), function(x) x^2)
                      , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                      , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                      , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
                    )
    df 
}

# =================================================== #
# |                *** atomic ***                   | #
# =================================================== #
atomic_ldbp = function(l_lasso
                      , l_de
                      , l_bart
                      , l_pwm){
    df = data.frame(lasso=unlist(abs(l_lasso))
                    , de=unlist(abs(l_de))
                    , bart=unlist(abs(l_bart))
                    , pwm=unlist(abs(l_pwm))
                    )
    df
}

atomic_lbp = function(l_lasso
                     , l_bart
                     , l_pwm){
    df = data.frame(lasso=unlist(abs(l_lasso))
                    , bart=unlist(abs(l_bart))
                    , pwm=unlist(abs(l_pwm))
                    )
    df 
}

# =================================================== #
# |             *** transform_v4 ***                | #
# =================================================== #
dummy_ldbp_transform_v4 = function(l_lasso
                                   , l_de
                                   , l_bart
                                   , l_pwm){
  
  interact_lasso_de = abs(l_lasso*l_de)
  interact_lasso_bart = abs(l_lasso*l_bart)
  interact_bart_de = abs(l_bart*l_de)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , sqrt_de=sapply(unlist(l_de), function(x) abs(x)^0.5)
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                  , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
                  
                  # , sqrt_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^0.5)
                  # , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  # , sqrt_interact_bart_de=sapply(unlist(interact_bart_de), function(x) abs(x)^0.5)
                  
                  , pos_pos_pos=as.integer(l_lasso>0 & l_de>0 & l_bart>0)
                  , pos_pos_neg=as.integer(l_lasso>0 & l_de>0 & l_bart<0)
                  , pos_neg_pos=as.integer(l_lasso>0 & l_de<0 & l_bart>0)
                  , pos_neg_neg=as.integer(l_lasso>0 & l_de<0 & l_bart<0)
                  , neg_neg_neg=as.integer(l_lasso<0 & l_de<0 & l_bart<0)
                  , neg_neg_pos=as.integer(l_lasso<0 & l_de<0 & l_bart>0)
                  , neg_pos_pos=as.integer(l_lasso<0 & l_de>0 & l_bart>0)
                  , neg_pos_neg=as.integer(l_lasso<0 & l_de>0 & l_bart<0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0)
                  # , z_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
                  # , z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0))
  df
}
dummy_lbp_transform_v4 = function(l_lasso
                                  , l_bart
                                  , l_pwm){
  interact_lasso_bart = abs(l_lasso*l_bart)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                  , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
                  
                  # , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  
                  , pos_pos=as.integer(l_lasso>0 & l_bart>0)
                  , pos_neg=as.integer(l_lasso>0 & l_bart<0)
                  # , nz_z=as.integer(l_lasso!=0 & l_bart==0)
                  , neg_neg=as.integer(l_lasso<0 & l_bart<0)
                  , neg_pos=as.integer(l_lasso<0 & l_bart>0)
                  # , z_nz=as.integer(l_lasso==0 & l_bart!=0)
                  )
  df
}
dummy_ldb_transform_v4 = function(l_lasso
                                  , l_de
                                  , l_bart){
  interact_lasso_de = abs(l_lasso*l_de)
  interact_lasso_bart = abs(l_lasso*l_bart)
  interact_bart_de = abs(l_bart*l_de)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , sqrt_de=sapply(unlist(l_de), function(x) abs(x)^0.5)
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  
                  # , sqrt_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^0.5)
                  # , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  # , sqrt_interact_bart_de=sapply(unlist(interact_bart_de), function(x) abs(x)^0.5)
                  
                  , pos_pos_pos=as.integer(l_lasso>0 & l_de>0 & l_bart>0)
                  , pos_pos_neg=as.integer(l_lasso>0 & l_de>0 & l_bart<0)
                  , pos_neg_pos=as.integer(l_lasso>0 & l_de<0 & l_bart>0)
                  , pos_neg_neg=as.integer(l_lasso>0 & l_de<0 & l_bart<0)
                  , neg_neg_neg=as.integer(l_lasso<0 & l_de<0 & l_bart<0)
                  , neg_neg_pos=as.integer(l_lasso<0 & l_de<0 & l_bart>0)
                  , neg_pos_pos=as.integer(l_lasso<0 & l_de>0 & l_bart>0)
                  , neg_pos_neg=as.integer(l_lasso<0 & l_de>0 & l_bart<0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0)
                  # , z_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
                  # , z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0))
  df
}
dummy_lb_transform_v4 = function(l_lasso
                                 , l_bart){
  interact_lasso_bart = abs(l_lasso*l_bart)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  
                  # , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  
                  , pos_pos=as.integer(l_lasso>0 & l_bart>0)
                  , pos_neg=as.integer(l_lasso>0 & l_bart<0)
                  # , nz_z=as.integer(l_lasso!=0 & l_bart==0)
                  , neg_neg=as.integer(l_lasso<0 & l_bart<0)
                  , neg_pos=as.integer(l_lasso<0 & l_bart>0)
                  # , z_nz=as.integer(l_lasso==0 & l_bart!=0)
                  )
  df
}


# =================================================== #
# |             *** transform_v3 ***                | #
# =================================================== #
dummy_ldbp_transform_v3 = function(l_lasso
                                   , l_de
                                   , l_bart
                                   , l_pwm){
  
#   interact_lasso_de_bart = abs(l_lasso*l_de*l_bart)
#   interact_lasso_de = abs(l_lasso*l_de)
#   interact_lasso_bart = abs(l_lasso*l_bart)
#   interact_bart_de = abs(l_bart*l_de)
  interact_lasso_de = abs(l_lasso * sapply(unlist(l_de), function(x) abs(x)^0.5))
  interact_lasso_bart = abs(l_lasso * sapply(unlist(l_bart), function(x) abs(x)^0.5))
  interact_bart_de = abs(sapply(unlist(l_bart), function(x) abs(x)^0.5) * sapply(unlist(l_de), function(x) abs(x)^0.5))                                             
                                           
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , log_de=sapply(unlist(l_de), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                  , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
#                   , square_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) abs(x)^2)
#                   , sqrt_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^0.5)
#                   , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^2)
#                   , sqrt_interact_bart_de=sapply(unlist(interact_bart_de), function(x) abs(x)^0.5)
                  # , interact_lasso_de=unlist(interact_lasso_de)
                  # , interact_lasso_bart=unlist(interact_lasso_bart)
                  # , interact_bart_de=unlist(interact_bart_de)
                                      
                  , pos_pos_pos=as.integer(l_lasso>0 & l_de>0 & l_bart>0)
                  , pos_pos_neg=as.integer(l_lasso>0 & l_de>0 & l_bart<0)
                  , pos_neg_pos=as.integer(l_lasso>0 & l_de<0 & l_bart>0)
                  , pos_neg_neg=as.integer(l_lasso>0 & l_de<0 & l_bart<0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0)
                  , neg_neg_neg=as.integer(l_lasso<0 & l_de<0 & l_bart<0)
                  , neg_neg_pos=as.integer(l_lasso<0 & l_de<0 & l_bart>0)
                  , neg_pos_pos=as.integer(l_lasso<0 & l_de>0 & l_bart>0)
                  , neg_pos_neg=as.integer(l_lasso<0 & l_de>0 & l_bart<0)
                  , z_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
                  , z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0))
  df
}
dummy_lbp_transform_v3 = function(l_lasso
                                  , l_bart
                                  , l_pwm){
  interact_lasso_bart = abs(l_lasso*l_bart)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                  , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
                  
#                   , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^2)
                  # , interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)

                  , pos_pos=as.integer(l_lasso>0 & l_bart>0)
                  , pos_neg=as.integer(l_lasso>0 & l_bart<0)
                  , nz_z=as.integer(l_lasso!=0 & l_bart==0)
                  , neg_neg=as.integer(l_lasso<0 & l_bart<0)
                  , neg_pos=as.integer(l_lasso<0 & l_bart>0)
                  , z_nz=as.integer(l_lasso==0 & l_bart!=0))
  df
}
dummy_ldb_transform_v3 = function(l_lasso
                                  , l_de
                                  , l_bart){
#   interact_lasso_de_bart = abs(l_lasso*l_de*l_bart)
#   interact_lasso_de = abs(l_lasso*l_de)
#   interact_lasso_bart = abs(l_lasso*l_bart)
#   interact_bart_de = abs(l_bart*l_de)
  interact_lasso_de = abs(l_lasso * sapply(unlist(l_de), function(x) abs(x)^0.5))
  interact_lasso_bart = abs(l_lasso * sapply(unlist(l_bart), function(x) abs(x)^0.5))
  interact_bart_de = abs(sapply(unlist(l_bart), function(x) abs(x)^0.5) * sapply(unlist(l_de), function(x) abs(x)^0.5))
                                                                                 
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , log_de=sapply(unlist(l_de), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  
#                   , square_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) abs(x)^2)
#                   , sqrt_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^0.5)
#                   , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^2)
#                   , sqrt_interact_bart_de=sapply(unlist(interact_bart_de), function(x) abs(x)^0.5)
                  
                  # , interact_lasso_de=unlist(interact_lasso_de)
                  # , interact_lasso_bart=unlist(interact_lasso_bart)
                  # , interact_bart_de=unlist(interact_bart_de)
                                     
                  , pos_pos_pos=as.integer(l_lasso>0 & l_de>0 & l_bart>0)
                  , pos_pos_neg=as.integer(l_lasso>0 & l_de>0 & l_bart<0)
                  , pos_neg_pos=as.integer(l_lasso>0 & l_de<0 & l_bart>0)
                  , pos_neg_neg=as.integer(l_lasso>0 & l_de<0 & l_bart<0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0)
                  , neg_neg_neg=as.integer(l_lasso<0 & l_de<0 & l_bart<0)
                  , neg_neg_pos=as.integer(l_lasso<0 & l_de<0 & l_bart>0)
                  , neg_pos_pos=as.integer(l_lasso<0 & l_de>0 & l_bart>0)
                  , neg_pos_neg=as.integer(l_lasso<0 & l_de>0 & l_bart<0)
                  , z_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
                  , z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0))
  df
}
dummy_lb_transform_v3 = function(l_lasso
                                 , l_bart){
  interact_lasso_bart = abs(l_lasso*l_bart)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  
#                   , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^2)
                  # , interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                                               
                  , pos_pos=as.integer(l_lasso>0 & l_bart>0)
                  , pos_neg=as.integer(l_lasso>0 & l_bart<0)
                  , nz_z=as.integer(l_lasso!=0 & l_bart==0)
                  , neg_neg=as.integer(l_lasso<0 & l_bart<0)
                  , neg_pos=as.integer(l_lasso<0 & l_bart>0)
                  , z_nz=as.integer(l_lasso==0 & l_bart!=0))
  df
}




# =================================================== #
# |             *** transform_v2 ***                | #
# =================================================== #
dummy_ldbp_transform_v2 = function(l_lasso
                                   , l_de
                                   , l_bart
                                   , l_pwm){
  
  interact_lasso_de_bart = abs(l_lasso*l_de*l_bart)
  interact_lasso_de = abs(l_lasso*l_de)
  interact_lasso_bart = abs(l_lasso*l_bart)
  interact_bart_de = abs(l_bart*l_de)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , log_de=sapply(unlist(l_de), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                  , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)

                  , log_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) log(abs(x)+1))
                  , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) log(abs(x)+1))
                  , log_interact_bart_de=sapply(unlist(interact_bart_de), function(x) log(abs(x)+1))
                  
                  , pos_pos_pos=as.integer(l_lasso>0 & l_de>0 & l_bart>0)
                  , pos_pos_neg=as.integer(l_lasso>0 & l_de>0 & l_bart<0)
                  , pos_neg_pos=as.integer(l_lasso>0 & l_de<0 & l_bart>0)
                  , pos_neg_neg=as.integer(l_lasso>0 & l_de<0 & l_bart<0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0)
                  , neg_neg_neg=as.integer(l_lasso<0 & l_de<0 & l_bart<0)
                  , neg_neg_pos=as.integer(l_lasso<0 & l_de<0 & l_bart>0)
                  , neg_pos_pos=as.integer(l_lasso<0 & l_de>0 & l_bart>0)
                  , neg_pos_neg=as.integer(l_lasso<0 & l_de>0 & l_bart<0)
                  , z_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
                  , z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0))
  df
}
dummy_lbp_transform_v2 = function(l_lasso
                                  , l_bart
                                  , l_pwm){
  interact_lasso_bart = abs(l_lasso*l_bart)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                  , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
                
                  , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) log(abs(x)+1))
                  
                  , pos_pos=as.integer(l_lasso>0 & l_bart>0)
                  , pos_neg=as.integer(l_lasso>0 & l_bart<0)
                  , nz_z=as.integer(l_lasso!=0 & l_bart==0)
                  , neg_neg=as.integer(l_lasso<0 & l_bart<0)
                  , neg_pos=as.integer(l_lasso<0 & l_bart>0)
                  , z_nz=as.integer(l_lasso==0 & l_bart!=0))
  df
}
dummy_ldb_transform_v2 = function(l_lasso
                                  , l_de
                                  , l_bart){
  interact_lasso_de_bart = abs(l_lasso*l_de*l_bart)
  interact_lasso_de = abs(l_lasso*l_de)
  interact_lasso_bart = abs(l_lasso*l_bart)
  interact_bart_de = abs(l_bart*l_de)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , log_de=sapply(unlist(l_de), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  
                  , log_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) log(abs(x)+1))
                  , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) log(abs(x)+1))
                  , log_interact_bart_de=sapply(unlist(interact_bart_de), function(x) log(abs(x)+1))
                  
                  , pos_pos_pos=as.integer(l_lasso>0 & l_de>0 & l_bart>0)
                  , pos_pos_neg=as.integer(l_lasso>0 & l_de>0 & l_bart<0)
                  , pos_neg_pos=as.integer(l_lasso>0 & l_de<0 & l_bart>0)
                  , pos_neg_neg=as.integer(l_lasso>0 & l_de<0 & l_bart<0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0)
                  , neg_neg_neg=as.integer(l_lasso<0 & l_de<0 & l_bart<0)
                  , neg_neg_pos=as.integer(l_lasso<0 & l_de<0 & l_bart>0)
                  , neg_pos_pos=as.integer(l_lasso<0 & l_de>0 & l_bart>0)
                  , neg_pos_neg=as.integer(l_lasso<0 & l_de>0 & l_bart<0)
                  , z_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
                  , z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0))
  df
}
dummy_lb_transform_v2 = function(l_lasso
                                 , l_bart){
  interact_lasso_bart = abs(l_lasso*l_bart)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  
                  , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) log(abs(x)+1))
                  
                  , pos_pos=as.integer(l_lasso>0 & l_bart>0)
                  , pos_neg=as.integer(l_lasso>0 & l_bart<0)
                  , nz_z=as.integer(l_lasso!=0 & l_bart==0)
                  , neg_neg=as.integer(l_lasso<0 & l_bart<0)
                  , neg_pos=as.integer(l_lasso<0 & l_bart>0)
                  , z_nz=as.integer(l_lasso==0 & l_bart!=0))
  df
}


# =================================================== #
# |             *** transform_v1 ***                | #
# =================================================== #
dummy_ldbp_transform_v1 = function(l_lasso
                                   , l_de
                                   , l_bart
                                   , l_pwm){
  
  interact_lasso_de = abs(l_lasso*l_de)
  interact_lasso_bart = abs(l_lasso*l_bart)
  interact_bart_de = abs(l_bart*l_de)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , sqrt_de=sapply(unlist(l_de), function(x) abs(x)^0.5)
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                  , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
                  
                  , sqrt_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^0.5)
                  , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  , sqrt_interact_bart_de=sapply(unlist(interact_bart_de), function(x) abs(x)^0.5)
                  
                  , pos_pos_pos=as.integer(l_lasso>0 & l_de>0 & l_bart>0)
                  , pos_pos_neg=as.integer(l_lasso>0 & l_de>0 & l_bart<0)
                  , pos_neg_pos=as.integer(l_lasso>0 & l_de<0 & l_bart>0)
                  , pos_neg_neg=as.integer(l_lasso>0 & l_de<0 & l_bart<0)
                  , neg_neg_neg=as.integer(l_lasso<0 & l_de<0 & l_bart<0)
                  , neg_neg_pos=as.integer(l_lasso<0 & l_de<0 & l_bart>0)
                  , neg_pos_pos=as.integer(l_lasso<0 & l_de>0 & l_bart>0)
                  , neg_pos_neg=as.integer(l_lasso<0 & l_de>0 & l_bart<0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0)
                  , z_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
                  , z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0))
  df
}
dummy_lbp_transform_v1 = function(l_lasso
                                  , l_bart
                                  , l_pwm){
  interact_lasso_bart = abs(l_lasso*l_bart)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                  , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
                  
                  , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  
                  , pos_pos=as.integer(l_lasso>0 & l_bart>0)
                  , pos_neg=as.integer(l_lasso>0 & l_bart<0)
                  , nz_z=as.integer(l_lasso!=0 & l_bart==0)
                  , neg_neg=as.integer(l_lasso<0 & l_bart<0)
                  , neg_pos=as.integer(l_lasso<0 & l_bart>0)
                  , z_nz=as.integer(l_lasso==0 & l_bart!=0))
  df
}
dummy_ldb_transform_v1 = function(l_lasso
                                  , l_de
                                  , l_bart){
  interact_lasso_de = abs(l_lasso*l_de)
  interact_lasso_bart = abs(l_lasso*l_bart)
  interact_bart_de = abs(l_bart*l_de)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , sqrt_de=sapply(unlist(l_de), function(x) abs(x)^0.5)
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  
                  , sqrt_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^0.5)
                  , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  , sqrt_interact_bart_de=sapply(unlist(interact_bart_de), function(x) abs(x)^0.5)
                  
                  , pos_pos_pos=as.integer(l_lasso>0 & l_de>0 & l_bart>0)
                  , pos_pos_neg=as.integer(l_lasso>0 & l_de>0 & l_bart<0)
                  , pos_neg_pos=as.integer(l_lasso>0 & l_de<0 & l_bart>0)
                  , pos_neg_neg=as.integer(l_lasso>0 & l_de<0 & l_bart<0)
                  , neg_neg_neg=as.integer(l_lasso<0 & l_de<0 & l_bart<0)
                  , neg_neg_pos=as.integer(l_lasso<0 & l_de<0 & l_bart>0)
                  , neg_pos_pos=as.integer(l_lasso<0 & l_de>0 & l_bart>0)
                  , neg_pos_neg=as.integer(l_lasso<0 & l_de>0 & l_bart<0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0)
                  , z_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
                  , z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0))
  df
}
dummy_lb_transform_v1 = function(l_lasso
                                 , l_bart){
  interact_lasso_bart = abs(l_lasso*l_bart)
  
  df = data.frame(log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  
                  , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  
                  , pos_pos=as.integer(l_lasso>0 & l_bart>0)
                  , pos_neg=as.integer(l_lasso>0 & l_bart<0)
                  , nz_z=as.integer(l_lasso!=0 & l_bart==0)
                  , neg_neg=as.integer(l_lasso<0 & l_bart<0)
                  , neg_pos=as.integer(l_lasso<0 & l_bart>0)
                  , z_nz=as.integer(l_lasso==0 & l_bart!=0))
  df
}


# =================================================== #
# |             *** transform_v0 ***                | #
# =================================================== #
dummy_ldbp_transform_v0 = function(l_lasso
                              , l_de
                              , l_bart
                              , l_pwm){
  
  interact_lasso_de_bart = abs(l_lasso*l_de*l_bart)
  interact_lasso_de = abs(l_lasso*l_de)
  interact_lasso_bart = abs(l_lasso*l_bart)
  interact_bart_de = abs(l_bart*l_de)
  
  df = data.frame(sqrt_lasso=sapply(unlist(l_lasso), function(x) abs(x)^0.5)
                  , log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , sqrt_de=sapply(unlist(l_de), function(x) abs(x)^0.5)
                  , log_de=sapply(unlist(l_de), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                  , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
                  
                  , interact_lasso_de_bart=unlist(interact_lasso_de_bart)
                  , interact_lasso_de=unlist(interact_lasso_de)
                  , interact_lasso_bart=unlist(interact_lasso_bart)
                  , interact_bart_de=unlist(interact_bart_de)
                  
                  , log_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) log(abs(x)+1))
                  , log_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) log(abs(x)+1))
                  , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) log(abs(x)+1))
                  , log_interact_bart_de=sapply(unlist(interact_bart_de), function(x) log(abs(x)+1))
                  
                  , square_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) abs(x)^2)
                  , square_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^2)
                  , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^2)
                  , square_interact_bart_de=sapply(unlist(interact_bart_de), function(x) abs(x)^2)
                  
                  , sqrt_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) abs(x)^0.5)
                  , sqrt_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^0.5)
                  , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  , sqrt_interact_bart_de=sapply(unlist(interact_bart_de), function(x) abs(x)^0.5)
  
                  , pos_pos_pos=as.integer(l_lasso>0 & l_de>0 & l_bart>0)
                  , pos_pos_neg=as.integer(l_lasso>0 & l_de>0 & l_bart<0)
                  , nz_nz_z=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0)
                  , pos_neg_pos=as.integer(l_lasso>0 & l_de<0 & l_bart>0)
                  , pos_neg_neg=as.integer(l_lasso>0 & l_de<0 & l_bart<0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0)
                  , nz_z_z=as.integer(l_lasso!=0 & l_de==0 & l_bart==0)
                  , neg_neg_neg=as.integer(l_lasso<0 & l_de<0 & l_bart<0)
                  , neg_neg_pos=as.integer(l_lasso<0 & l_de<0 & l_bart>0)
                  , neg_pos_pos=as.integer(l_lasso<0 & l_de>0 & l_bart>0)
                  , neg_pos_neg=as.integer(l_lasso<0 & l_de>0 & l_bart<0)
                  , z_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
                  , z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0))
  df
}
dummy_lbp_transform_v0 = function(l_lasso
                             , l_bart
                             , l_pwm){
  interact_lasso_bart = abs(l_lasso*l_bart)
  
  df = data.frame(sqrt_lasso=sapply(unlist(l_lasso), function(x) abs(x)^0.5)
                  , log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                  , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
                  
                  , interact_lasso_bart=unlist(interact_lasso_bart)
                  , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) log(abs(x)+1))
                  , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^2)
                  , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  
                  
                  , pos_pos=as.integer(l_lasso>0 & l_bart>0)
                  , pos_neg=as.integer(l_lasso>0 & l_bart<0)
                  , nz_z=as.integer(l_lasso!=0 & l_bart==0)
                  , neg_neg=as.integer(l_lasso<0 & l_bart<0)
                  , neg_pos=as.integer(l_lasso<0 & l_bart>0)
                  , z_nz=as.integer(l_lasso==0 & l_bart!=0))
  df
}
dummy_ldb_transform_v0 = function(l_lasso
                       , l_de
                       , l_bart){
  interact_lasso_de_bart = abs(l_lasso*l_de*l_bart)
  interact_lasso_de = abs(l_lasso*l_de)
  interact_lasso_bart = abs(l_lasso*l_bart)
  interact_bart_de = abs(l_bart*l_de)
  
  df = data.frame(sqrt_lasso=sapply(unlist(l_lasso), function(x) abs(x)^0.5)
                  , log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , sqrt_de=sapply(unlist(l_de), function(x) abs(x)^0.5)
                  , log_de=sapply(unlist(l_de), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  
                  , interact_lasso_de_bart=unlist(interact_lasso_de_bart)
                  , interact_lasso_de=unlist(interact_lasso_de)
                  , interact_lasso_bart=unlist(interact_lasso_bart)
                  , interact_bart_de=unlist(interact_bart_de)
                  
                  , log_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) log(abs(x)+1))
                  , log_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) log(abs(x)+1))
                  , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) log(abs(x)+1))
                  , log_interact_bart_de=sapply(unlist(interact_bart_de), function(x) log(abs(x)+1))
                  
                  , square_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) abs(x)^2)
                  , square_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^2)
                  , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^2)
                  , square_interact_bart_de=sapply(unlist(interact_bart_de), function(x) abs(x)^2)
                  
                  , sqrt_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) abs(x)^0.5)
                  , sqrt_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^0.5)
                  , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  , sqrt_interact_bart_de=sapply(unlist(interact_bart_de), function(x) abs(x)^0.5)
                  
                  , pos_pos_pos=as.integer(l_lasso>0 & l_de>0 & l_bart>0)
                  , pos_pos_neg=as.integer(l_lasso>0 & l_de>0 & l_bart<0)
                  , nz_nz_z=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0)
                  , pos_neg_pos=as.integer(l_lasso>0 & l_de<0 & l_bart>0)
                  , pos_neg_neg=as.integer(l_lasso>0 & l_de<0 & l_bart<0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0)
                  , nz_z_z=as.integer(l_lasso!=0 & l_de==0 & l_bart==0)
                  , neg_neg_neg=as.integer(l_lasso<0 & l_de<0 & l_bart<0)
                  , neg_neg_pos=as.integer(l_lasso<0 & l_de<0 & l_bart>0)
                  , neg_pos_pos=as.integer(l_lasso<0 & l_de>0 & l_bart>0)
                  , neg_pos_neg=as.integer(l_lasso<0 & l_de>0 & l_bart<0)
                  , z_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
                  , z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0))
  df
}
dummy_lb_transform_v0 = function(l_lasso
                            , l_bart){
  interact_lasso_bart = abs(l_lasso*l_bart)
  
  df = data.frame(sqrt_lasso=sapply(unlist(l_lasso), function(x) abs(x)^0.5)
                  , log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  
                  , interact_lasso_bart=unlist(interact_lasso_bart)
                  , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) log(abs(x)+1))
                  , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^2)
                  , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  
                  , pos_pos=as.integer(l_lasso>0 & l_bart>0)
                  , pos_neg=as.integer(l_lasso>0 & l_bart<0)
                  , nz_z=as.integer(l_lasso!=0 & l_bart==0)
                  , neg_neg=as.integer(l_lasso<0 & l_bart<0)
                  , neg_pos=as.integer(l_lasso<0 & l_bart>0)
                  , z_nz=as.integer(l_lasso==0 & l_bart!=0))
  df
}

# =================================================== #
# |                  *** dummy ***                  | #
# =================================================== #
dummy_ldbp = function(l_lasso
                      , l_de
                      , l_bart
                      , l_pwm){
  # LASSO x DE x BART x PWM
  interact_lasso_de_bart_pwm = abs(l_lasso*l_de*l_bart*l_pwm)
  # LASSO x DE x BART
  interact_lasso_de_bart = abs(l_lasso*l_de*l_bart)
  # LASSO x DE x PWM
  interact_lasso_de_pwm = abs(l_lasso*l_de*l_pwm)
  # LASSO x BART x PWM
  interact_lasso_bart_pwm = abs(l_lasso*l_bart*l_pwm)
  # DE x BART x PWM 
  interact_de_bart_pwm = abs(l_de*l_bart*l_pwm)
  # LASSO x DE
  interact_lasso_de = abs(l_lasso*l_de)
  # LASSO x BART
  interact_lasso_bart = abs(l_lasso*l_bart)
  # LASSO x PWM
  interact_lasso_pwm = abs(l_lasso*l_pwm)
  # DE x BART
  interact_de_bart = abs(l_de*l_bart)
  # DE x PWM
  interact_de_pwm = abs(l_de*l_pwm)
  # BART x PWM
  interact_bart_pwm = abs(l_bart*l_pwm)
  
  df = data.frame(lasso=abs(unlist(l_lasso))
                           , de=abs(unlist(l_de))
                           , bart=abs(unlist(l_bart))
                           , pwm=unlist(l_pwm)
                           , interact_lasso_de_bart_pwm=unlist(interact_lasso_de_bart_pwm)
                           , interact_lasso_de_bart=unlist(interact_lasso_de_bart)
                           , interact_lasso_de_pwm=unlist(interact_lasso_de_pwm)
                           , interact_de_bart_pwm=unlist(interact_de_bart_pwm)
                           , interact_lasso_bart_pwm=unlist(interact_lasso_bart_pwm)
                           , interact_lasso_de=unlist(interact_lasso_de)
                           , interact_lasso_bart=unlist(interact_lasso_bart)
                           , interact_lasso_pwm=unlist(interact_lasso_pwm)
                           , interact_de_bart=unlist(interact_de_bart)
                           , interact_de_pwm=unlist(interact_de_pwm)
                           , interact_bart_pwm=unlist(interact_bart_pwm)
                           
                           , pos_pos_pos_nz=as.integer(l_lasso>0 & l_de>0 & l_bart>0 & l_pwm != 0)
                           , pos_pos_neg_nz=as.integer(l_lasso>0 & l_de>0 & l_bart<0 & l_pwm != 0)
                           , nz_nz_z_nz=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0 & l_pwm != 0)
                           , pos_neg_pos_nz=as.integer(l_lasso>0 & l_de<0 & l_bart>0 & l_pwm != 0)
                           , pos_neg_neg_nz=as.integer(l_lasso>0 & l_de<0 & l_bart<0 & l_pwm != 0)
                           , nz_z_nz_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0 & l_pwm != 0)
                           , nz_z_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart==0 & l_pwm != 0)
                           , neg_neg_neg_nz=as.integer(l_lasso<0 & l_de<0 & l_bart<0 & l_pwm != 0)
                           , neg_neg_pos_nz=as.integer(l_lasso<0 & l_de<0 & l_bart>0 & l_pwm != 0)
                           , neg_pos_pos_nz=as.integer(l_lasso<0 & l_de>0 & l_bart>0 & l_pwm != 0)
                           , neg_pos_neg_nz=as.integer(l_lasso<0 & l_de>0 & l_bart<0 & l_pwm != 0)
                           , z_z_nz_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0 & l_pwm != 0)
                           , z_nz_z_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart==0 & l_pwm != 0)
                           , z_nz_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0 & l_pwm != 0)
                           
                           , pos_pos_pos_z=as.integer(l_lasso>0 & l_de>0 & l_bart>0 & l_pwm == 0)
                           , pos_pos_neg_z=as.integer(l_lasso>0 & l_de>0 & l_bart<0 & l_pwm == 0)
                           , nz_nz_z_z=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0 & l_pwm == 0)
                           , pos_neg_pos_z=as.integer(l_lasso>0 & l_de<0 & l_bart>0 & l_pwm == 0)
                           , pos_neg_neg_z=as.integer(l_lasso>0 & l_de<0 & l_bart<0 & l_pwm == 0)
                           , nz_z_nz_z=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0 & l_pwm == 0)
                           , nz_z_z_z=as.integer(l_lasso!=0 & l_de==0 & l_bart==0 & l_pwm == 0)
                           , neg_neg_neg_z=as.integer(l_lasso<0 & l_de<0 & l_bart<0 & l_pwm == 0)
                           , neg_neg_pos_z=as.integer(l_lasso<0 & l_de<0 & l_bart>0 & l_pwm == 0)
                           , neg_pos_pos_z=as.integer(l_lasso<0 & l_de>0 & l_bart>0 & l_pwm == 0)
                           , neg_pos_neg_z=as.integer(l_lasso<0 & l_de>0 & l_bart<0 & l_pwm == 0)
                           , z_z_nz_z=as.integer(l_lasso==0 & l_de==0 & l_bart!=0 & l_pwm == 0)
                           , z_nz_z_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0 & l_pwm == 0)
                           , z_nz_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0 & l_pwm == 0))
  df
}

dummy_lbp = function(l_lasso
                     , l_bart
                     , l_pwm){
  # LASSO x BART x PWM
  interact_lasso_bart_pwm = abs(l_lasso*l_bart*l_pwm)
  # LASSO x BART
  interact_lasso_bart = abs(l_lasso*l_bart)
  # LASSO x PWM
  interact_lasso_pwm = abs(l_lasso*l_pwm)
  # BART x PWM
  interact_bart_pwm = abs(l_bart*l_pwm)
  
  df = data.frame(lasso=abs(unlist(l_lasso))
                   , bart=abs(unlist(l_bart))
                   , pwm=unlist(l_pwm)
                   , interact_lasso_bart_pwm=unlist(interact_lasso_bart_pwm)
                   , interact_lasso_bart=unlist(interact_lasso_bart)
                   , interact_lasso_pwm=unlist(interact_lasso_pwm)
                   , interact_bart_pwm=unlist(interact_bart_pwm)
                   
                   , pos_pos_nz=as.integer(l_lasso>0 & l_bart>0 & l_pwm != 0)
                   , pos_neg_nz=as.integer(l_lasso>0 & l_bart<0 & l_pwm != 0)
                   , nz_z_nz=as.integer(l_lasso!=0 & l_bart==0 & l_pwm != 0)
                   , neg_neg_nz=as.integer(l_lasso<0 & l_bart<0 & l_pwm != 0)
                   , neg_pos_nz=as.integer(l_lasso<0 & l_bart>0 & l_pwm != 0)
                   , z_nz_nz=as.integer(l_lasso==0 & l_bart!=0 & l_pwm != 0)
                   , z_z_nz=as.integer(l_lasso==0 & l_bart==0 & l_pwm != 0)
                   
                   , pos_pos_z=as.integer(l_lasso>0 & l_bart>0 & l_pwm == 0)
                   , pos_neg_z=as.integer(l_lasso>0 & l_bart<0 & l_pwm == 0)
                   , nz_z_z=as.integer(l_lasso!=0 & l_bart==0 & l_pwm == 0)
                   , neg_neg_z=as.integer(l_lasso<0 & l_bart<0 & l_pwm == 0)
                   , neg_pos_z=as.integer(l_lasso<0 & l_bart>0 & l_pwm == 0)
                   , z_nz_z=as.integer(l_lasso==0 & l_bart!=0 & l_pwm == 0))
  df
}

dummy_ldb = function(l_lasso
                     , l_de
                     , l_bart){
  # LASSO x DE x BART
  interact_lasso_de_bart = abs(l_lasso*l_de*l_bart)
  # LASSO x DE
  interact_lasso_de = abs(l_lasso*l_de)
  # LASSO x BART
  interact_lasso_bart = abs(l_lasso*l_bart)
  # DE x BART
  interact_de_bart = abs(l_de*l_bart)
  
  df = data.frame(lasso=abs(unlist(l_lasso))
                 , de=abs(unlist(l_de))
                 , bart=abs(unlist(l_bart))
                 , interact_lasso_de_bart=unlist(interact_lasso_de_bart)
                 , interact_lasso_de=unlist(interact_lasso_de)
                 , interact_lasso_bart=unlist(interact_lasso_bart)
                 , interact_de_bart=unlist(interact_de_bart)
                 
                 , pos_pos_pos=as.integer(l_lasso>0 & l_de>0 & l_bart>0)
                 , pos_pos_neg=as.integer(l_lasso>0 & l_de>0 & l_bart<0)
                 , nz_nz_z=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0)
                 , pos_neg_pos=as.integer(l_lasso>0 & l_de<0 & l_bart>0)
                 , pos_neg_neg=as.integer(l_lasso>0 & l_de<0 & l_bart<0)
                 , nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0)
                 , nz_z_z=as.integer(l_lasso!=0 & l_de==0 & l_bart==0)
                 , neg_neg_neg=as.integer(l_lasso<0 & l_de<0 & l_bart<0)
                 , neg_neg_pos=as.integer(l_lasso<0 & l_de<0 & l_bart>0)
                 , neg_pos_pos=as.integer(l_lasso<0 & l_de>0 & l_bart>0)
                 , neg_pos_neg=as.integer(l_lasso<0 & l_de>0 & l_bart<0)
                 , z_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
                 , z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
                 , z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0))
  df
}

dummy_lb = function(l_lasso
                    , l_bart){
  # LASSO x BART
  interact_lasso_bart = abs(l_lasso*l_bart)
  colnames(interact_lasso_bart) = "interact_lasso_bart"
  
  df = data.frame(lasso=abs(unlist(l_lasso))
                   , bart=abs(unlist(l_bart))
                   , interact_lasso_bart=unlist(interact_lasso_bart)
                   , pos_pos=as.integer(l_lasso>0 & l_bart>0)
                   , pos_neg=as.integer(l_lasso>0 & l_bart<0)
                   , nz_z=as.integer(l_lasso!=0 & l_bart==0)
                   , neg_neg=as.integer(l_lasso<0 & l_bart<0)
                   , neg_pos=as.integer(l_lasso<0 & l_bart>0)
                   , z_nz=as.integer(l_lasso==0 & l_bart!=0))
  df
}

# =================================================== #
# |           *** dummy_transform ***               | #
# =================================================== #

dummy_ldbp_transform = function(l_lasso
                      , l_de
                      , l_bart
                      , l_pwm){
  # LASSO x DE x BART x PWM
  interact_lasso_de_bart_pwm = abs(l_lasso*l_de*l_bart*l_pwm)
  # LASSO x DE x BART
  interact_lasso_de_bart = abs(l_lasso*l_de*l_bart)
  # LASSO x DE x PWM
  interact_lasso_de_pwm = abs(l_lasso*l_de*l_pwm)
  # LASSO x BART x PWM
  interact_lasso_bart_pwm = abs(l_lasso*l_bart*l_pwm)
  # DE x BART x PWM 
  interact_de_bart_pwm = abs(l_de*l_bart*l_pwm)
  # LASSO x DE
  interact_lasso_de = abs(l_lasso*l_de)
  # LASSO x BART
  interact_lasso_bart = abs(l_lasso*l_bart)
  # LASSO x PWM
  interact_lasso_pwm = abs(l_lasso*l_pwm)
  # DE x BART
  interact_de_bart = abs(l_de*l_bart)
  # DE x PWM
  interact_de_pwm = abs(l_de*l_pwm)
  # BART x PWM
  interact_bart_pwm = abs(l_bart*l_pwm)
  
  df = data.frame(lasso=abs(unlist(l_lasso))
                   , square_lasso=sapply(unlist(l_lasso), function(x) x^2)
                   , sqrt_lasso=sapply(unlist(l_lasso), function(x) abs(x)^0.5)
                   , log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                   
                   , de=abs(unlist(l_de))
                   , square_de=sapply(unlist(l_de), function(x) x^2)
                   , sqrt_de=sapply(unlist(l_de), function(x) abs(x)^0.5)
                   , log_de=sapply(unlist(l_de), function(x) log(abs(x)+1))
                   
                   , bart=abs(unlist(l_bart))
                   , square_bart=sapply(unlist(l_bart), function(x) x^2)
                   , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                   , log_bart=sapply(unlist(l_bart), function(x) log(abs(x)+1))
                   
                   , pwm=unlist(l_pwm)
                   , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                   , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
                   , log_pwm=sapply(unlist(l_pwm), function(x) log(abs(x)+1))
                   
                   , interact_lasso_de_bart_pwm=unlist(interact_lasso_de_bart_pwm)
                   , square_interact_lasso_de_bart_pwm=sapply(unlist(interact_lasso_de_bart_pwm), function(x) x^2)
                   , sqrt_interact_lasso_de_bart_pwm=sapply(unlist(interact_lasso_de_bart_pwm), function(x) abs(x)^0.5)
                   , log_interact_lasso_de_bart_pwm=sapply(unlist(interact_lasso_de_bart_pwm), function(x) log(abs(x)+1))
                   
                   , interact_lasso_de_bart=unlist(interact_lasso_de_bart)
                   , square_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) x^2)
                   , sqrt_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) abs(x)^0.5)
                   , log_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) log(abs(x)+1))
                   
                   , interact_lasso_de_pwm=unlist(interact_lasso_de_pwm)
                   , square_interact_lasso_de_pwm=sapply(unlist(interact_lasso_de_pwm), function(x) x^2)
                   , sqrt_interact_lasso_de_pwm=sapply(unlist(interact_lasso_de_pwm), function(x) abs(x)^0.5)
                   , log_interact_lasso_de_pwm=sapply(unlist(interact_lasso_de_pwm), function(x) log(abs(x)+1))
                   
                   , interact_de_bart_pwm=unlist(interact_de_bart_pwm)
                   , square_interact_de_bart_pwm=sapply(unlist(interact_de_bart_pwm), function(x) x^2)
                   , sqrt_interact_de_bart_pwm=sapply(unlist(interact_de_bart_pwm), function(x) abs(x)^0.5)
                   , log_interact_de_bart_pwm=sapply(unlist(interact_de_bart_pwm), function(x) log(abs(x)+1))
                   
                   , interact_lasso_bart_pwm=unlist(interact_lasso_bart_pwm)
                   , square_interact_lasso_bart_pwm=sapply(unlist(interact_lasso_bart_pwm), function(x) x^2)
                   , sqrt_interact_lasso_bart_pwm=sapply(unlist(interact_lasso_bart_pwm), function(x) abs(x)^0.5)
                   , log_interact_lasso_bart_pwm=sapply(unlist(interact_lasso_bart_pwm), function(x) log(abs(x)+1))
                   
                   , interact_lasso_de=unlist(interact_lasso_de)
                   , square_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) x^2)
                   , sqrt_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^0.5)
                   , log_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) log(abs(x)+1))
                   
                   , interact_lasso_bart=unlist(interact_lasso_bart)
                   , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) x^2)
                   , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                   , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) log(abs(x)+1))
                   
                   , interact_lasso_pwm=unlist(interact_lasso_pwm)
                   , square_interact_lasso_pwm=sapply(unlist(interact_lasso_pwm), function(x) x^2)
                   , sqrt_interact_lasso_pwm=sapply(unlist(interact_lasso_pwm), function(x) abs(x)^0.5)
                   , log_interact_lasso_pwm=sapply(unlist(interact_lasso_pwm), function(x) log(abs(x)+1))
                   
                   , interact_de_bart=unlist(interact_de_bart)
                   , square_interact_de_bart=sapply(unlist(interact_de_bart), function(x) x^2)
                   , sqrt_interact_de_bart=sapply(unlist(interact_de_bart), function(x) abs(x)^0.5)
                   , log_interact_de_bart=sapply(unlist(interact_de_bart), function(x) log(abs(x)+1))
                   
                   , interact_de_pwm=unlist(interact_de_pwm)
                   , square_interact_de_pwm=sapply(unlist(interact_de_pwm), function(x) x^2)
                   , sqrt_interact_de_pwm=sapply(unlist(interact_de_pwm), function(x) abs(x)^0.5)
                   , log_interact_de_pwm=sapply(unlist(interact_de_pwm), function(x) log(abs(x)+1))
                   
                   , interact_bart_pwm=unlist(interact_bart_pwm)
                   , square_interact_bart_pwm=sapply(unlist(interact_bart_pwm), function(x) x^2)
                   , sqrt_interact_bart_pwm=sapply(unlist(interact_bart_pwm), function(x) abs(x)^0.5)
                   , log_interact_bart_pwm=sapply(unlist(interact_bart_pwm), function(x) log(abs(x)+1))
                   
                   , pos_pos_pos_nz=as.integer(l_lasso>0 & l_de>0 & l_bart>0 & l_pwm != 0)
                   , pos_pos_neg_nz=as.integer(l_lasso>0 & l_de>0 & l_bart<0 & l_pwm != 0)
                   , nz_nz_z_nz=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0 & l_pwm != 0)
                   , pos_neg_pos_nz=as.integer(l_lasso>0 & l_de<0 & l_bart>0 & l_pwm != 0)
                   , pos_neg_neg_nz=as.integer(l_lasso>0 & l_de<0 & l_bart<0 & l_pwm != 0)
                   , nz_z_nz_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0 & l_pwm != 0)
                   , nz_z_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart==0 & l_pwm != 0)
                   , neg_neg_neg_nz=as.integer(l_lasso<0 & l_de<0 & l_bart<0 & l_pwm != 0)
                   , neg_neg_pos_nz=as.integer(l_lasso<0 & l_de<0 & l_bart>0 & l_pwm != 0)
                   , neg_pos_pos_nz=as.integer(l_lasso<0 & l_de>0 & l_bart>0 & l_pwm != 0)
                   , neg_pos_neg_nz=as.integer(l_lasso<0 & l_de>0 & l_bart<0 & l_pwm != 0)
                   , z_z_nz_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0 & l_pwm != 0)
                   , z_nz_z_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart==0 & l_pwm != 0)
                   , z_nz_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0 & l_pwm != 0)
                   
                   , pos_pos_pos_z=as.integer(l_lasso>0 & l_de>0 & l_bart>0 & l_pwm == 0)
                   , pos_pos_neg_z=as.integer(l_lasso>0 & l_de>0 & l_bart<0 & l_pwm == 0)
                   , nz_nz_z_z=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0 & l_pwm == 0)
                   , pos_neg_pos_z=as.integer(l_lasso>0 & l_de<0 & l_bart>0 & l_pwm == 0)
                   , pos_neg_neg_z=as.integer(l_lasso>0 & l_de<0 & l_bart<0 & l_pwm == 0)
                   , nz_z_nz_z=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0 & l_pwm == 0)
                   , nz_z_z_z=as.integer(l_lasso!=0 & l_de==0 & l_bart==0 & l_pwm == 0)
                   , neg_neg_neg_z=as.integer(l_lasso<0 & l_de<0 & l_bart<0 & l_pwm == 0)
                   , neg_neg_pos_z=as.integer(l_lasso<0 & l_de<0 & l_bart>0 & l_pwm == 0)
                   , neg_pos_pos_z=as.integer(l_lasso<0 & l_de>0 & l_bart>0 & l_pwm == 0)
                   , neg_pos_neg_z=as.integer(l_lasso<0 & l_de>0 & l_bart<0 & l_pwm == 0)
                   , z_z_nz_z=as.integer(l_lasso==0 & l_de==0 & l_bart!=0 & l_pwm == 0)
                   , z_nz_z_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0 & l_pwm == 0)
                   , z_nz_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0 & l_pwm == 0))
  df
}

                                                   
dummy_ldbpn_transform = function(l_lasso
                                  , l_de
                                  , l_bart
                                  , l_pwm
                                  , l_new
                                ){
  # LASSO x DE x BART x PWM x NEW
  interact_lasso_de_bart_pwm_new = abs(l_lasso*l_de*l_bart*l_pwm*l_new)
  
  # LASSO x DE x BART x PWM
  interact_lasso_de_bart_pwm = abs(l_lasso*l_de*l_bart*l_pwm)
  # LASSO x DE x BART x NEW
  interact_lasso_de_bart_new = abs(l_lasso*l_de*l_bart*l_new)
  # LASSO x DE x NEW x PWM
  interact_lasso_de_new_pwm = abs(l_lasso*l_de*l_new*l_pwm)  
  # LASSO x NEW x BART x PWM
  interact_lasso_new_bart_pwm = abs(l_lasso*l_new*l_bart*l_pwm)
  # NEW x DE x BART x PWM
  interact_new_de_bart_pwm = abs(l_new*l_de*l_bart*l_pwm)
    
  # LASSO x DE x BART
  interact_lasso_de_bart = abs(l_lasso*l_de*l_bart)
  # LASSO x DE x PWM
  interact_lasso_de_pwm = abs(l_lasso*l_de*l_pwm)
  # LASSO x BART x PWM
  interact_lasso_bart_pwm = abs(l_lasso*l_bart*l_pwm)
  # DE x BART x PWM 
  interact_de_bart_pwm = abs(l_de*l_bart*l_pwm)
  # NEW x LASSO x DE
  interact_new_lasso_de = abs(l_new*l_lasso*l_de)
  # NEW x LASSO x BART
  interact_new_lasso_bart = abs(l_new*l_lasso*l_bart)
  # NEW x LASSO X PWM
  interact_new_lasso_pwm = abs(l_new*l_lasso*l_pwm)
  # NEW x DE x BART
  interact_new_de_bart = abs(l_new*l_de*l_bart)
  # NEW x DE x PWM
  interact_new_de_pwm = abs(l_new*l_de*l_pwm)
  # NEW x BART x PWM
  interact_new_bart_pwm = abs(l_new*l_bart*l_pwm)
  
  # LASSO x DE
  interact_lasso_de = abs(l_lasso*l_de)
  # LASSO x BART
  interact_lasso_bart = abs(l_lasso*l_bart)
  # LASSO x PWM
  interact_lasso_pwm = abs(l_lasso*l_pwm)
  # DE x BART
  interact_de_bart = abs(l_de*l_bart)
  # DE x PWM
  interact_de_pwm = abs(l_de*l_pwm)
  # BART x PWM
  interact_bart_pwm = abs(l_bart*l_pwm)
  # NEW x LASSO
  interact_new_lasso = abs(l_new*l_lasso)
  # NEW x DE
  interact_new_de = abs(l_new*l_de)
  # NEW x BART
  interact_new_bart = abs(l_new*l_bart)
  # NEW x PWM
  interact_new_pwm = abs(l_new*l_pwm)
  
  df = data.frame(lasso=abs(unlist(l_lasso))
                   , square_lasso=sapply(unlist(l_lasso), function(x) x^2)
                   , sqrt_lasso=sapply(unlist(l_lasso), function(x) abs(x)^0.5)
                   , log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                   
                   , de=abs(unlist(l_de))
                   , square_de=sapply(unlist(l_de), function(x) x^2)
                   , sqrt_de=sapply(unlist(l_de), function(x) abs(x)^0.5)
                   , log_de=sapply(unlist(l_de), function(x) log(abs(x)+1))
                   
                   , bart=abs(unlist(l_bart))
                   , square_bart=sapply(unlist(l_bart), function(x) x^2)
                   , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                   , log_bart=sapply(unlist(l_bart), function(x) log(abs(x)+1))
                   
                   , pwm=unlist(l_pwm)
                   , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                   , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
                   , log_pwm=sapply(unlist(l_pwm), function(x) log(abs(x)+1))
                   
                   , new=unlist(l_new)
                   , square_new=sapply(unlist(l_new), function(x) x^2)
                   , sqrt_new=sapply(unlist(l_new), function(x) abs(x)^0.5)
                   , log_new=sapply(unlist(l_new), function(x) log(abs(x)+1))
                   
                   , interact_lasso_de_bart_pwm_new=unlist(interact_lasso_de_bart_pwm_new)
                   , square_interact_lasso_de_bart_pwm_new=sapply(unlist(interact_lasso_de_bart_pwm_new), function(x) x^2)
                   , sqrt_interact_lasso_de_bart_pwm_new=sapply(unlist(interact_lasso_de_bart_pwm_new), function(x) abs(x)^0.5)
                   , log_interact_lasso_de_bart_pwm_new=sapply(unlist(interact_lasso_de_bart_pwm_new), function(x) log(abs(x)+1))
                   
                   , interact_lasso_de_bart_pwm=unlist(interact_lasso_de_bart_pwm)
                   , square_interact_lasso_de_bart_pwm=sapply(unlist(interact_lasso_de_bart_pwm), function(x) x^2)
                   , sqrt_interact_lasso_de_bart_pwm=sapply(unlist(interact_lasso_de_bart_pwm), function(x) abs(x)^0.5)
                   , log_interact_lasso_de_bart_pwm=sapply(unlist(interact_lasso_de_bart_pwm), function(x) log(abs(x)+1))
                   
                   , interact_lasso_de_bart_new=unlist(interact_lasso_de_bart_new)
                   , square_interact_lasso_de_bart_new=sapply(unlist(interact_lasso_de_bart_new), function(x) x^2)
                   , sqrt_interact_lasso_de_bart_new=sapply(unlist(interact_lasso_de_bart_new), function(x) abs(x)^0.5)
                   , log_interact_lasso_de_bart_new=sapply(unlist(interact_lasso_de_bart_new), function(x) log(abs(x)+1))
                   
                   , interact_lasso_de_new_pwm=unlist(interact_lasso_de_new_pwm)
                   , square_interact_lasso_de_new_pwm=sapply(unlist(interact_lasso_de_new_pwm), function(x) x^2)
                   , sqrt_interact_lasso_de_new_pwm=sapply(unlist(interact_lasso_de_new_pwm), function(x) abs(x)^0.5)
                   , log_interact_lasso_de_new_pwm=sapply(unlist(interact_lasso_de_new_pwm), function(x) log(abs(x)+1))
                   
                   , interact_lasso_new_bart_pwm=unlist(interact_lasso_new_bart_pwm)
                   , square_interact_lasso_new_bart_pwm=sapply(unlist(interact_lasso_new_bart_pwm), function(x) x^2)
                   , sqrt_interact_lasso_new_bart_pwm=sapply(unlist(interact_lasso_new_bart_pwm), function(x) abs(x)^0.5)
                   , log_interact_lasso_new_bart_pwm=sapply(unlist(interact_lasso_new_bart_pwm), function(x) log(abs(x)+1))
                   
                   , interact_new_de_bart_pwm=unlist(interact_new_de_bart_pwm)
                   , square_interact_new_de_bart_pwm=sapply(unlist(interact_new_de_bart_pwm), function(x) x^2)
                   , sqrt_interact_new_de_bart_pwm=sapply(unlist(interact_new_de_bart_pwm), function(x) abs(x)^0.5)
                   , log_interact_new_de_bart_pwm=sapply(unlist(interact_new_de_bart_pwm), function(x) log(abs(x)+1))                                
                   # x 3         
                   , interact_lasso_de_bart=unlist(interact_lasso_de_bart)
                   , square_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) x^2)
                   , sqrt_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) abs(x)^0.5)
                   , log_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) log(abs(x)+1))
                   
                   , interact_lasso_de_pwm=unlist(interact_lasso_de_pwm)
                   , square_interact_lasso_de_pwm=sapply(unlist(interact_lasso_de_pwm), function(x) x^2)
                   , sqrt_interact_lasso_de_pwm=sapply(unlist(interact_lasso_de_pwm), function(x) abs(x)^0.5)
                   , log_interact_lasso_de_pwm=sapply(unlist(interact_lasso_de_pwm), function(x) log(abs(x)+1))
                   
                   , interact_de_bart_pwm=unlist(interact_de_bart_pwm)
                   , square_interact_de_bart_pwm=sapply(unlist(interact_de_bart_pwm), function(x) x^2)
                   , sqrt_interact_de_bart_pwm=sapply(unlist(interact_de_bart_pwm), function(x) abs(x)^0.5)
                   , log_interact_de_bart_pwm=sapply(unlist(interact_de_bart_pwm), function(x) log(abs(x)+1))
                   
                   , interact_lasso_bart_pwm=unlist(interact_lasso_bart_pwm)
                   , square_interact_lasso_bart_pwm=sapply(unlist(interact_lasso_bart_pwm), function(x) x^2)
                   , sqrt_interact_lasso_bart_pwm=sapply(unlist(interact_lasso_bart_pwm), function(x) abs(x)^0.5)
                   , log_interact_lasso_bart_pwm=sapply(unlist(interact_lasso_bart_pwm), function(x) log(abs(x)+1))
                   
                   , interact_new_de_bart=unlist(interact_new_de_bart)
                   , square_interact_new_de_bart=sapply(unlist(interact_new_de_bart), function(x) x^2)
                   , sqrt_interact_new_de_bart=sapply(unlist(interact_new_de_bart), function(x) abs(x)^0.5)
                   , log_interact_new_de_bart=sapply(unlist(interact_new_de_bart), function(x) log(abs(x)+1))                                     
                   , interact_new_de_pwm=unlist(interact_new_de_pwm)
                   , square_interact_new_de_pwm=sapply(unlist(interact_new_de_pwm), function(x) x^2)
                   , sqrt_interact_new_de_pwm=sapply(unlist(interact_new_de_pwm), function(x) abs(x)^0.5)
                   , log_interact_new_de_pwm=sapply(unlist(interact_new_de_pwm), function(x) log(abs(x)+1))
                   
                   , interact_new_bart_pwm=unlist(interact_new_bart_pwm)
                   , square_interact_new_bart_pwm=sapply(unlist(interact_new_bart_pwm), function(x) x^2)
                   , sqrt_interact_new_bart_pwm=sapply(unlist(interact_new_bart_pwm), function(x) abs(x)^0.5)
                   , log_interact_new_bart_pwm=sapply(unlist(interact_new_bart_pwm), function(x) log(abs(x)+1))
                   
                   , interact_new_lasso_bart=unlist(interact_new_lasso_bart)
                   , square_interact_new_lasso_bart=sapply(unlist(interact_new_lasso_bart), function(x) x^2)
                   , sqrt_interact_new_lasso_bart=sapply(unlist(interact_new_lasso_bart), function(x) abs(x)^0.5)
                   , log_interact_new_lasso_bart=sapply(unlist(interact_new_lasso_bart), function(x) log(abs(x)+1))  
                                                       
                   , interact_new_lasso_pwm=unlist(interact_new_lasso_pwm)
                   , square_interact_new_lasso_pwm=sapply(unlist(interact_new_lasso_pwm), function(x) x^2)
                   , sqrt_interact_new_lasso_pwm=sapply(unlist(interact_new_lasso_pwm), function(x) abs(x)^0.5)
                   , log_interact_new_lasso_pwm=sapply(unlist(interact_new_lasso_pwm), function(x) log(abs(x)+1))  
                                                       
                   , interact_new_lasso_de=unlist(interact_new_lasso_de)
                   , square_interact_new_lasso_de=sapply(unlist(interact_new_lasso_de), function(x) x^2)
                   , sqrt_interact_new_lasso_de=sapply(unlist(interact_new_lasso_de), function(x) abs(x)^0.5)
                   , log_interact_new_lasso_de=sapply(unlist(interact_new_lasso_de), function(x) log(abs(x)+1))  
                                                       
                   # x 2
                   , interact_lasso_de=unlist(interact_lasso_de)
                   , square_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) x^2)
                   , sqrt_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^0.5)
                   , log_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) log(abs(x)+1))
                   
                   , interact_lasso_bart=unlist(interact_lasso_bart)
                   , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) x^2)
                   , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                   , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) log(abs(x)+1))
                   
                   , interact_lasso_pwm=unlist(interact_lasso_pwm)
                   , square_interact_lasso_pwm=sapply(unlist(interact_lasso_pwm), function(x) x^2)
                   , sqrt_interact_lasso_pwm=sapply(unlist(interact_lasso_pwm), function(x) abs(x)^0.5)
                   , log_interact_lasso_pwm=sapply(unlist(interact_lasso_pwm), function(x) log(abs(x)+1))
                   
                   , interact_de_bart=unlist(interact_de_bart)
                   , square_interact_de_bart=sapply(unlist(interact_de_bart), function(x) x^2)
                   , sqrt_interact_de_bart=sapply(unlist(interact_de_bart), function(x) abs(x)^0.5)
                   , log_interact_de_bart=sapply(unlist(interact_de_bart), function(x) log(abs(x)+1))
                   
                   , interact_de_pwm=unlist(interact_de_pwm)
                   , square_interact_de_pwm=sapply(unlist(interact_de_pwm), function(x) x^2)
                   , sqrt_interact_de_pwm=sapply(unlist(interact_de_pwm), function(x) abs(x)^0.5)
                   , log_interact_de_pwm=sapply(unlist(interact_de_pwm), function(x) log(abs(x)+1))
                   
                   , interact_bart_pwm=unlist(interact_bart_pwm)
                   , square_interact_bart_pwm=sapply(unlist(interact_bart_pwm), function(x) x^2)
                   , sqrt_interact_bart_pwm=sapply(unlist(interact_bart_pwm), function(x) abs(x)^0.5)
                   , log_interact_bart_pwm=sapply(unlist(interact_bart_pwm), function(x) log(abs(x)+1))
                   
                   , interact_new_de=unlist(interact_new_de)
                   , square_interact_new_de=sapply(unlist(interact_new_de), function(x) x^2)
                   , sqrt_interact_new_de=sapply(unlist(interact_new_de), function(x) abs(x)^0.5)
                   , log_interact_new_de=sapply(unlist(interact_new_de), function(x) log(abs(x)+1))
                   
                   , interact_new_bart=unlist(interact_new_bart)
                   , square_interact_new_bart=sapply(unlist(interact_new_bart), function(x) x^2)
                   , sqrt_interact_new_bart=sapply(unlist(interact_new_bart), function(x) abs(x)^0.5)
                   , log_interact_new_bart=sapply(unlist(interact_new_bart), function(x) log(abs(x)+1))
                   
                   , interact_new_pwm=unlist(interact_new_pwm)
                   , square_interact_new_pwm=sapply(unlist(interact_new_pwm), function(x) x^2)
                   , sqrt_interact_new_pwm=sapply(unlist(interact_new_pwm), function(x) abs(x)^0.5)
                   , log_interact_new_pwm=sapply(unlist(interact_new_pwm), function(x) log(abs(x)+1))
                                                 
                   , interact_new_lasso=unlist(interact_new_lasso)
                   , square_interact_new_lasso=sapply(unlist(interact_new_lasso), function(x) x^2)
                   , sqrt_interact_new_lasso=sapply(unlist(interact_new_lasso), function(x) abs(x)^0.5)
                   , log_interact_new_lasso=sapply(unlist(interact_new_lasso), function(x) log(abs(x)+1))
                   
                   # dummy
                   , pos_pos_pos_pos_nz=as.integer(l_lasso>0 & l_de>0 & l_bart>0 & l_new>0 & l_pwm!= 0)
                   , pos_pos_pos_neg_nz=as.integer(l_lasso>0 & l_de>0 & l_bart>0 & l_new<0 & l_pwm!= 0)                          
                                                   
                   , pos_pos_neg_pos_nz=as.integer(l_lasso>0 & l_de>0 & l_bart<0 & l_new>0 & l_pwm != 0)
                   , pos_pos_neg_neg_nz=as.integer(l_lasso>0 & l_de>0 & l_bart<0 & l_new<0 & l_pwm != 0)                        
                                                   
                   , nz_nz_z_nz_nz=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0 & l_new!=0 & l_pwm != 0)
                   , nz_nz_z_z_nz=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0 & l_new==0 & l_pwm != 0)
                                                   
                   , pos_neg_pos_pos_nz=as.integer(l_lasso>0 & l_de<0 & l_bart>0 & l_new>0 & l_pwm != 0)
                   , pos_neg_pos_neg_nz=as.integer(l_lasso>0 & l_de<0 & l_bart>0 & l_new<0 & l_pwm != 0)
                                                   
                   , pos_neg_neg_pos_nz=as.integer(l_lasso>0 & l_de<0 & l_bart<0 & l_new>0 & l_pwm != 0)
                   , pos_neg_neg_neg_nz=as.integer(l_lasso>0 & l_de<0 & l_bart<0 & l_new<0 & l_pwm != 0)                               
                   , nz_z_nz_nz_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0 & l_new!=0 & l_pwm != 0)
                   , nz_z_nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0 & l_new==0 & l_pwm != 0)                                
                   , nz_z_z_nz_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart==0 & l_new!=0 & l_pwm != 0)
                   , nz_z_z_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart==0 & l_new==0 & l_pwm != 0)                                
                   , neg_neg_neg_pos_nz=as.integer(l_lasso<0 & l_de<0 & l_bart<0 & l_new>0 & l_pwm != 0)
                   , neg_neg_neg_neg_nz=as.integer(l_lasso<0 & l_de<0 & l_bart<0 & l_new<0 & l_pwm != 0)                                
                   , neg_neg_pos_pos_nz=as.integer(l_lasso<0 & l_de<0 & l_bart>0 & l_new>0 & l_pwm != 0)
                   , neg_neg_pos_neg_nz=as.integer(l_lasso<0 & l_de<0 & l_bart>0 & l_new<0 & l_pwm != 0)                                
                   , neg_pos_pos_pos_nz=as.integer(l_lasso<0 & l_de>0 & l_bart>0 & l_new>0 & l_pwm != 0)
                   , neg_pos_pos_neg_nz=as.integer(l_lasso<0 & l_de>0 & l_bart>0 & l_new<0 & l_pwm != 0)                               
                   , neg_pos_neg_pos_nz=as.integer(l_lasso<0 & l_de>0 & l_bart<0 & l_new>0 & l_pwm != 0)
                   , neg_pos_neg_neg_nz=as.integer(l_lasso<0 & l_de>0 & l_bart<0 & l_new<0 & l_pwm != 0)                                
                   , z_z_nz_nz_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0 & l_new!=0 & l_pwm != 0)
                   , z_z_nz_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0 & l_new==0 & l_pwm != 0)                                
                   , z_nz_z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart==0 & l_new!=0 & l_pwm != 0)
                   , z_nz_z_z_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart==0 & l_new==0 & l_pwm != 0)                                
                   , z_nz_nz_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0 & l_new!=0 & l_pwm != 0)
                   , z_nz_nz_z_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0 & l_new==0 & l_pwm != 0)
                                                   
                   , pos_pos_pos_pos_z=as.integer(l_lasso>0 & l_de>0 & l_bart>0 & l_new>0 & l_pwm == 0)
                   , pos_pos_pos_neg_z=as.integer(l_lasso>0 & l_de>0 & l_bart>0 & l_new<0 & l_pwm == 0)                               
                   , pos_pos_neg_pos_z=as.integer(l_lasso>0 & l_de>0 & l_bart<0 & l_new>0 & l_pwm == 0)
                   , pos_pos_neg_neg_z=as.integer(l_lasso>0 & l_de>0 & l_bart<0 & l_new<0 & l_pwm == 0)                                
                   , nz_nz_z_nz_z=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0 & l_new!=0 & l_pwm == 0)
                   , nz_nz_z_z_z=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0 & l_new==0 & l_pwm == 0)
                                                   
                   , pos_neg_pos_pos_z=as.integer(l_lasso>0 & l_de<0 & l_bart>0 & l_new>0 & l_pwm == 0)
                   , pos_neg_pos_neg_z=as.integer(l_lasso>0 & l_de<0 & l_bart>0 & l_new<0 & l_pwm == 0)
                                                   
                   , pos_neg_neg_pos_z=as.integer(l_lasso>0 & l_de<0 & l_bart<0 & l_new>0 & l_pwm == 0)
                   , pos_neg_neg_neg_z=as.integer(l_lasso>0 & l_de<0 & l_bart<0 & l_new<0 & l_pwm == 0)
                                                   
                   , nz_z_nz_nz_z=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0 & l_new!=0 & l_pwm == 0)
                   , nz_z_nz_z_z=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0 & l_new==0 & l_pwm == 0)
                                                   
                   , nz_z_z_nz_z=as.integer(l_lasso!=0 & l_de==0 & l_bart==0 & l_new!=0 & l_pwm == 0)
                   , nz_z_z_z_z=as.integer(l_lasso!=0 & l_de==0 & l_bart==0 & l_new==0 & l_pwm == 0)
                                                   
                   , neg_neg_neg_pos_z=as.integer(l_lasso<0 & l_de<0 & l_bart<0 & l_new>0 & l_pwm == 0)
                   , neg_neg_neg_neg_z=as.integer(l_lasso<0 & l_de<0 & l_bart<0 & l_new<0 & l_pwm == 0)                                
                   , neg_neg_pos_pos_z=as.integer(l_lasso<0 & l_de<0 & l_bart>0 & l_new>0 & l_pwm == 0)
                   , neg_neg_pos_neg_z=as.integer(l_lasso<0 & l_de<0 & l_bart>0 & l_new<0 & l_pwm == 0)                                
                   , neg_pos_pos_pos_z=as.integer(l_lasso<0 & l_de>0 & l_bart>0 & l_new>0 & l_pwm == 0)
                   , neg_pos_pos_neg_z=as.integer(l_lasso<0 & l_de>0 & l_bart>0 & l_new<0 & l_pwm == 0)                               
                   , neg_pos_neg_pos_z=as.integer(l_lasso<0 & l_de>0 & l_bart<0 & l_new>0 & l_pwm == 0)
                   , neg_pos_neg_neg_z=as.integer(l_lasso<0 & l_de>0 & l_bart<0 & l_new<0 & l_pwm == 0)                                
                   , z_z_nz_nz_z=as.integer(l_lasso==0 & l_de==0 & l_bart!=0 & l_new!=0 & l_pwm == 0)
                   , z_z_nz_z_z=as.integer(l_lasso==0 & l_de==0 & l_bart!=0 & l_new==0 & l_pwm == 0)                                
                   , z_nz_z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0 & l_new!=0 & l_pwm == 0)
                   , z_nz_z_z_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0 & l_new==0 & l_pwm == 0)                                
                   , z_nz_nz_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0 & l_new!=0 & l_pwm == 0)
                   , z_nz_nz_z_z=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0 & l_new==0 & l_pwm == 0))
  df
}
                                                   
dummy_lbp_transform = function(l_lasso
                               , l_bart
                               , l_pwm){
  # LASSO x BART x PWM
  interact_lasso_bart_pwm = abs(l_lasso*l_bart*l_pwm)
  # LASSO x BART
  interact_lasso_bart = abs(l_lasso*l_bart)
  # LASSO x PWM
  interact_lasso_pwm = abs(l_lasso*l_pwm)
  # BART x PWM
  interact_bart_pwm = abs(l_bart*l_pwm)
  
  df = data.frame(lasso=abs(unlist(l_lasso))
                  , square_lasso=sapply(unlist(l_lasso), function(x) x^2)
                  , sqrt_lasso=sapply(unlist(l_lasso), function(x) abs(x)^0.5)
                  , log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  
                  , bart=abs(unlist(l_bart))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , log_bart=sapply(unlist(l_bart), function(x) log(abs(x)+1))
                  
                  , pwm=unlist(l_pwm)
                  , square_pwm=sapply(unlist(l_pwm), function(x) x^2)
                  , sqrt_pwm=sapply(unlist(l_pwm), function(x) abs(x)^0.5)
                  , log_pwm=sapply(unlist(l_pwm), function(x) log(abs(x)+1))
                  
                  , interact_lasso_bart_pwm=unlist(interact_lasso_bart_pwm)
                  , square_interact_lasso_bart_pwm=sapply(unlist(interact_lasso_bart_pwm), function(x) x^2)
                  , sqrt_interact_lasso_bart_pwm=sapply(unlist(interact_lasso_bart_pwm), function(x) abs(x)^0.5)
                  , log_interact_lasso_bart_pwm=sapply(unlist(interact_lasso_bart_pwm), function(x) log(abs(x)+1))
                  
                  , interact_lasso_bart=unlist(interact_lasso_bart)
                  , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) x^2)
                  , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) log(abs(x)+1))
                  
                  , interact_lasso_pwm=unlist(interact_lasso_pwm)
                  , square_interact_lasso_pwm=sapply(unlist(interact_lasso_pwm), function(x) x^2)
                  , sqrt_interact_lasso_pwm=sapply(unlist(interact_lasso_pwm), function(x) abs(x)^0.5)
                  , log_interact_lasso_pwm=sapply(unlist(interact_lasso_pwm), function(x) log(abs(x)+1))
                  
                  , interact_bart_pwm=unlist(interact_bart_pwm)
                  , square_interact_bart_pwm=sapply(unlist(interact_bart_pwm), function(x) x^2)
                  , sqrt_interact_bart_pwm=sapply(unlist(interact_bart_pwm), function(x) abs(x)^0.5)
                  , log_interact_bart_pwm=sapply(unlist(interact_bart_pwm), function(x) log(abs(x)+1))
                  
                  , pos_pos_nz=as.integer(l_lasso>0 & l_bart>0 & l_pwm != 0)
                  , pos_neg_nz=as.integer(l_lasso>0 & l_bart<0 & l_pwm != 0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_bart==0 & l_pwm != 0)
                  , neg_neg_nz=as.integer(l_lasso<0 & l_bart<0 & l_pwm != 0)
                  , neg_pos_nz=as.integer(l_lasso<0 & l_bart>0 & l_pwm != 0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_bart!=0 & l_pwm != 0)
                  , z_z_nz=as.integer(l_lasso==0 & l_bart==0 & l_pwm != 0)
                  
                  , pos_pos_z=as.integer(l_lasso>0 & l_bart>0 & l_pwm == 0)
                  , pos_neg_z=as.integer(l_lasso>0 & l_bart<0 & l_pwm == 0)
                  , nz_z_z=as.integer(l_lasso!=0 & l_bart==0 & l_pwm == 0)
                  , neg_neg_z=as.integer(l_lasso<0 & l_bart<0 & l_pwm == 0)
                  , neg_pos_z=as.integer(l_lasso<0 & l_bart>0 & l_pwm == 0)
                  , z_nz_z=as.integer(l_lasso==0 & l_bart!=0 & l_pwm == 0))
  df
}

dummy_ldb_transform = function(l_lasso
                               , l_de
                               , l_bart){
  # LASSO x DE x BART
  interact_lasso_de_bart = abs(l_lasso*l_de*l_bart)
  # LASSO x DE
  interact_lasso_de = abs(l_lasso*l_de)
  # LASSO x BART
  interact_lasso_bart = abs(l_lasso*l_bart)
  # DE x BART
  interact_de_bart = abs(l_de*l_bart)
  
  df = data.frame(lasso=abs(unlist(l_lasso))
                  , square_lasso=sapply(unlist(l_lasso), function(x) x^2)
                  , sqrt_lasso=sapply(unlist(l_lasso), function(x) abs(x)^0.5)
                  , log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  
                  , de=abs(unlist(l_de))
                  , square_de=sapply(unlist(l_de), function(x) x^2)
                  , sqrt_de=sapply(unlist(l_de), function(x) abs(x)^0.5)
                  , log_de=sapply(unlist(l_de), function(x) log(abs(x)+1))
                  
                  , bart=abs(unlist(l_bart))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , log_bart=sapply(unlist(l_bart), function(x) log(abs(x)+1))
                  
                  , interact_lasso_de_bart=unlist(interact_lasso_de_bart)
                  , square_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) x^2)
                  , sqrt_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) abs(x)^0.5)
                  , log_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) log(abs(x)+1))
                  
                  , interact_lasso_de=unlist(interact_lasso_de)
                  , square_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) x^2)
                  , sqrt_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^0.5)
                  , log_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) log(abs(x)+1))
                  
                  , interact_lasso_bart=unlist(interact_lasso_bart)
                  , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) x^2)
                  , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) log(abs(x)+1))
                  
                  , interact_de_bart=unlist(interact_de_bart)
                  , square_interact_de_bart=sapply(unlist(interact_de_bart), function(x) x^2)
                  , sqrt_interact_de_bart=sapply(unlist(interact_de_bart), function(x) abs(x)^0.5)
                  , log_interact_de_bart=sapply(unlist(interact_de_bart), function(x) log(abs(x)+1))
                  
                  , pos_pos_pos=as.integer(l_lasso>0 & l_de>0 & l_bart>0)
                  , pos_pos_neg=as.integer(l_lasso>0 & l_de>0 & l_bart<0)
                  , nz_nz_z=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0)
                  , pos_neg_pos=as.integer(l_lasso>0 & l_de<0 & l_bart>0)
                  , pos_neg_neg=as.integer(l_lasso>0 & l_de<0 & l_bart<0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0)
                  , nz_z_z=as.integer(l_lasso!=0 & l_de==0 & l_bart==0)
                  , neg_neg_neg=as.integer(l_lasso<0 & l_de<0 & l_bart<0)
                  , neg_neg_pos=as.integer(l_lasso<0 & l_de<0 & l_bart>0)
                  , neg_pos_pos=as.integer(l_lasso<0 & l_de>0 & l_bart>0)
                  , neg_pos_neg=as.integer(l_lasso<0 & l_de>0 & l_bart<0)
                  , z_z_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0)
                  , z_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0))
  df
}

dummy_lb_transform = function(l_lasso
                    , l_bart){
  # LASSO x BART
  interact_lasso_bart = abs(l_lasso*l_bart)
  
  df = data.frame(lasso=abs(unlist(l_lasso))
                  , square_lasso=sapply(unlist(l_lasso), function(x) x^2)
                  , sqrt_lasso=sapply(unlist(l_lasso), function(x) abs(x)^0.5)
                  , log_lasso=sapply(unlist(l_lasso), function(x) log(abs(x)+1))
                  
                  , bart=abs(unlist(l_bart))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , log_bart=sapply(unlist(l_bart), function(x) log(abs(x)+1))
                  
                  , interact_lasso_bart=unlist(interact_lasso_bart)
                  , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) x^2)
                  , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) log(abs(x)+1))
                  
                  , pos_pos=as.integer(l_lasso>0 & l_bart>0)
                  , pos_neg=as.integer(l_lasso>0 & l_bart<0)
                  , nz_z=as.integer(l_lasso!=0 & l_bart==0)
                  , neg_neg=as.integer(l_lasso<0 & l_bart<0)
                  , neg_pos=as.integer(l_lasso<0 & l_bart>0)
                  , z_nz=as.integer(l_lasso==0 & l_bart!=0))
  df
}

dummy_ldbp_only_pwm_dummy = function(l_lasso
                                    , l_de
                                    , l_bart
                                    , l_pwm){
  # LASSO x DE x BART
  interact_lasso_de_bart = abs(l_lasso*l_de*l_bart)
  # LASSO x DE
  interact_lasso_de = abs(l_lasso*l_de)
  # LASSO x BART
  interact_lasso_bart = abs(l_lasso*l_bart)
  # DE x BART
  interact_de_bart = abs(l_de*l_bart)
  
  df = data.frame(lasso=abs(unlist(l_lasso))
                  , de=abs(unlist(l_de))
                  , bart=abs(unlist(l_bart))
                  , interact_lasso_de_bart=unlist(interact_lasso_de_bart)
                  , interact_lasso_de=unlist(interact_lasso_de)
                  , interact_lasso_bart=unlist(interact_lasso_bart)
                  , interact_de_bart=unlist(interact_de_bart)
                  
                  , pos_pos_pos_nz=as.integer(l_lasso>0 & l_de>0 & l_bart>0 & l_pwm != 0)
                  , pos_pos_neg_nz=as.integer(l_lasso>0 & l_de>0 & l_bart<0 & l_pwm != 0)
                  , nz_nz_z_nz=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0 & l_pwm != 0)
                  , pos_neg_pos_nz=as.integer(l_lasso>0 & l_de<0 & l_bart>0 & l_pwm != 0)
                  , pos_neg_neg_nz=as.integer(l_lasso>0 & l_de<0 & l_bart<0 & l_pwm != 0)
                  , nz_z_nz_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0 & l_pwm != 0)
                  , nz_z_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart==0 & l_pwm != 0)
                  , neg_neg_neg_nz=as.integer(l_lasso<0 & l_de<0 & l_bart<0 & l_pwm != 0)
                  , neg_neg_pos_nz=as.integer(l_lasso<0 & l_de<0 & l_bart>0 & l_pwm != 0)
                  , neg_pos_pos_nz=as.integer(l_lasso<0 & l_de>0 & l_bart>0 & l_pwm != 0)
                  , neg_pos_neg_nz=as.integer(l_lasso<0 & l_de>0 & l_bart<0 & l_pwm != 0)
                  , z_z_nz_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0 & l_pwm != 0)
                  , z_nz_z_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart==0 & l_pwm != 0)
                  , z_nz_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0 & l_pwm != 0)
                  
                  , pos_pos_pos_z=as.integer(l_lasso>0 & l_de>0 & l_bart>0 & l_pwm == 0)
                  , pos_pos_neg_z=as.integer(l_lasso>0 & l_de>0 & l_bart<0 & l_pwm == 0)
                  , nz_nz_z_z=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0 & l_pwm == 0)
                  , pos_neg_pos_z=as.integer(l_lasso>0 & l_de<0 & l_bart>0 & l_pwm == 0)
                  , pos_neg_neg_z=as.integer(l_lasso>0 & l_de<0 & l_bart<0 & l_pwm == 0)
                  , nz_z_nz_z=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0 & l_pwm == 0)
                  , nz_z_z_z=as.integer(l_lasso!=0 & l_de==0 & l_bart==0 & l_pwm == 0)
                  , neg_neg_neg_z=as.integer(l_lasso<0 & l_de<0 & l_bart<0 & l_pwm == 0)
                  , neg_neg_pos_z=as.integer(l_lasso<0 & l_de<0 & l_bart>0 & l_pwm == 0)
                  , neg_pos_pos_z=as.integer(l_lasso<0 & l_de>0 & l_bart>0 & l_pwm == 0)
                  , neg_pos_neg_z=as.integer(l_lasso<0 & l_de>0 & l_bart<0 & l_pwm == 0)
                  , z_z_nz_z=as.integer(l_lasso==0 & l_de==0 & l_bart!=0 & l_pwm == 0)
                  , z_nz_z_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0 & l_pwm == 0)
                  , z_nz_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0 & l_pwm == 0))
  df
}

dummy_lbp_only_pwm_dummy = function(l_lasso
                                   , l_bart
                                   , l_pwm){
  # LASSO x BART
  interact_lasso_bart = abs(l_lasso*l_bart)
  
  df = data.frame(lasso=abs(unlist(l_lasso))
                  , bart=abs(unlist(l_bart))
                  , interact_lasso_bart=unlist(interact_lasso_bart)
                  
                  , pos_pos_nz=as.integer(l_lasso>0 & l_bart>0 & l_pwm != 0)
                  , pos_neg_nz=as.integer(l_lasso>0 & l_bart<0 & l_pwm != 0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_bart==0 & l_pwm != 0)
                  , neg_neg_nz=as.integer(l_lasso<0 & l_bart<0 & l_pwm != 0)
                  , neg_pos_nz=as.integer(l_lasso<0 & l_bart>0 & l_pwm != 0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_bart!=0 & l_pwm != 0)
                  , z_z_nz=as.integer(l_lasso==0 & l_bart==0 & l_pwm != 0)
                  
                  , pos_pos_z=as.integer(l_lasso>0 & l_bart>0 & l_pwm == 0)
                  , pos_neg_z=as.integer(l_lasso>0 & l_bart<0 & l_pwm == 0)
                  , nz_z_z=as.integer(l_lasso!=0 & l_bart==0 & l_pwm == 0)
                  , neg_neg_z=as.integer(l_lasso<0 & l_bart<0 & l_pwm == 0)
                  , neg_pos_z=as.integer(l_lasso<0 & l_bart>0 & l_pwm == 0)
                  , z_nz_z=as.integer(l_lasso==0 & l_bart!=0 & l_pwm == 0))
  df
}

dummy_ldbp_only_pwm_dummy_transform = function(l_lasso
                                              , l_de
                                              , l_bart
                                              , l_pwm){
  # LASSO x DE x BART
  interact_lasso_de_bart = abs(l_lasso*l_de*l_bart)
  # LASSO x DE
  interact_lasso_de = abs(l_lasso*l_de)
  # LASSO x BART
  interact_lasso_bart = abs(l_lasso*l_bart)
  # DE x BART
  interact_de_bart = abs(l_de*l_bart)
  
  df = data.frame(lasso=abs(unlist(l_lasso))
                  , square_lasso=sapply(unlist(l_lasso), function(x) x^2)
                  , sqrt_lasso=sapply(unlist(l_lasso), function(x) abs(x)^0.5)
                  , log_lasso=sapply(unlist(l_lasso), function(x) if (abs(x)==0) -20 else log(abs(x)))
                  
                  , de=abs(unlist(l_de))
                  , square_de=sapply(unlist(l_de), function(x) x^2)
                  , sqrt_de=sapply(unlist(l_de), function(x) abs(x)^0.5)
                  , log_de=sapply(unlist(l_de), function(x) if (abs(x)==0) -20 else log(abs(x)))
                  
                  , bart=abs(unlist(l_bart))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , log_bart=sapply(unlist(l_bart), function(x) if (abs(x)==0) -20 else log(abs(x)))
                  
                  , interact_lasso_de_bart=unlist(interact_lasso_de_bart)
                  , square_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) x^2)
                  , sqrt_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) abs(x)^0.5)
                  , log_interact_lasso_de_bart=sapply(unlist(interact_lasso_de_bart), function(x) if (abs(x)==0) -20 else log(abs(x)))
                  
                  , interact_lasso_de=unlist(interact_lasso_de)
                  , square_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) x^2)
                  , sqrt_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) abs(x)^0.5)
                  , log_interact_lasso_de=sapply(unlist(interact_lasso_de), function(x) if (abs(x)==0) -20 else log(abs(x)))
                  
                  , interact_lasso_bart=unlist(interact_lasso_bart)
                  , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) x^2)
                  , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) if (abs(x)==0) -20 else log(abs(x)))
                  
                  , interact_de_bart=unlist(interact_de_bart)
                  , square_interact_de_bart=sapply(unlist(interact_de_bart), function(x) x^2)
                  , sqrt_interact_de_bart=sapply(unlist(interact_de_bart), function(x) abs(x)^0.5)
                  , log_interact_de_bart=sapply(unlist(interact_de_bart), function(x) if (abs(x)==0) -20 else log(abs(x)))
                  
                  , pos_pos_pos_nz=as.integer(l_lasso>0 & l_de>0 & l_bart>0 & l_pwm != 0)
                  , pos_pos_neg_nz=as.integer(l_lasso>0 & l_de>0 & l_bart<0 & l_pwm != 0)
                  , nz_nz_z_nz=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0 & l_pwm != 0)
                  , pos_neg_pos_nz=as.integer(l_lasso>0 & l_de<0 & l_bart>0 & l_pwm != 0)
                  , pos_neg_neg_nz=as.integer(l_lasso>0 & l_de<0 & l_bart<0 & l_pwm != 0)
                  , nz_z_nz_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0 & l_pwm != 0)
                  , nz_z_z_nz=as.integer(l_lasso!=0 & l_de==0 & l_bart==0 & l_pwm != 0)
                  , neg_neg_neg_nz=as.integer(l_lasso<0 & l_de<0 & l_bart<0 & l_pwm != 0)
                  , neg_neg_pos_nz=as.integer(l_lasso<0 & l_de<0 & l_bart>0 & l_pwm != 0)
                  , neg_pos_pos_nz=as.integer(l_lasso<0 & l_de>0 & l_bart>0 & l_pwm != 0)
                  , neg_pos_neg_nz=as.integer(l_lasso<0 & l_de>0 & l_bart<0 & l_pwm != 0)
                  , z_z_nz_nz=as.integer(l_lasso==0 & l_de==0 & l_bart!=0 & l_pwm != 0)
                  , z_nz_z_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart==0 & l_pwm != 0)
                  , z_nz_nz_nz=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0 & l_pwm != 0)
                  
                  , pos_pos_pos_z=as.integer(l_lasso>0 & l_de>0 & l_bart>0 & l_pwm == 0)
                  , pos_pos_neg_z=as.integer(l_lasso>0 & l_de>0 & l_bart<0 & l_pwm == 0)
                  , nz_nz_z_z=as.integer(l_lasso!=0 & l_de!=0 & l_bart==0 & l_pwm == 0)
                  , pos_neg_pos_z=as.integer(l_lasso>0 & l_de<0 & l_bart>0 & l_pwm == 0)
                  , pos_neg_neg_z=as.integer(l_lasso>0 & l_de<0 & l_bart<0 & l_pwm == 0)
                  , nz_z_nz_z=as.integer(l_lasso!=0 & l_de==0 & l_bart!=0 & l_pwm == 0)
                  , nz_z_z_z=as.integer(l_lasso!=0 & l_de==0 & l_bart==0 & l_pwm == 0)
                  , neg_neg_neg_z=as.integer(l_lasso<0 & l_de<0 & l_bart<0 & l_pwm == 0)
                  , neg_neg_pos_z=as.integer(l_lasso<0 & l_de<0 & l_bart>0 & l_pwm == 0)
                  , neg_pos_pos_z=as.integer(l_lasso<0 & l_de>0 & l_bart>0 & l_pwm == 0)
                  , neg_pos_neg_z=as.integer(l_lasso<0 & l_de>0 & l_bart<0 & l_pwm == 0)
                  , z_z_nz_z=as.integer(l_lasso==0 & l_de==0 & l_bart!=0 & l_pwm == 0)
                  , z_nz_z_z=as.integer(l_lasso==0 & l_de!=0 & l_bart==0 & l_pwm == 0)
                  , z_nz_nz_z=as.integer(l_lasso==0 & l_de!=0 & l_bart!=0 & l_pwm == 0))
  df
}

dummy_lbp_only_pwm_dummy_transform = function(l_lasso
                                             , l_bart
                                             , l_pwm){
  # LASSO x BART
  interact_lasso_bart = abs(l_lasso*l_bart)
  
  df = data.frame(lasso=abs(unlist(l_lasso))
                  , square_lasso=sapply(unlist(l_lasso), function(x) x^2)
                  , sqrt_lasso=sapply(unlist(l_lasso), function(x) abs(x)^0.5)
                  , log_lasso=sapply(unlist(l_lasso), function(x) if (abs(x)==0) -20 else log(abs(x)))
                  
                  , bart=abs(unlist(l_bart))
                  , square_bart=sapply(unlist(l_bart), function(x) x^2)
                  , sqrt_bart=sapply(unlist(l_bart), function(x) abs(x)^0.5)
                  , log_bart=sapply(unlist(l_bart), function(x) if (abs(x)==0) -20 else log(abs(x)))
                  
                  , interact_lasso_bart=unlist(interact_lasso_bart)
                  , square_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) x^2)
                  , sqrt_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) abs(x)^0.5)
                  , log_interact_lasso_bart=sapply(unlist(interact_lasso_bart), function(x) if (abs(x)==0) -20 else log(abs(x)))
                  
                  , pos_pos_nz=as.integer(l_lasso>0 & l_bart>0 & l_pwm != 0)
                  , pos_neg_nz=as.integer(l_lasso>0 & l_bart<0 & l_pwm != 0)
                  , nz_z_nz=as.integer(l_lasso!=0 & l_bart==0 & l_pwm != 0)
                  , neg_neg_nz=as.integer(l_lasso<0 & l_bart<0 & l_pwm != 0)
                  , neg_pos_nz=as.integer(l_lasso<0 & l_bart>0 & l_pwm != 0)
                  , z_nz_nz=as.integer(l_lasso==0 & l_bart!=0 & l_pwm != 0)
                  , z_z_nz=as.integer(l_lasso==0 & l_bart==0 & l_pwm != 0)
                  
                  , pos_pos_z=as.integer(l_lasso>0 & l_bart>0 & l_pwm == 0)
                  , pos_neg_z=as.integer(l_lasso>0 & l_bart<0 & l_pwm == 0)
                  , nz_z_z=as.integer(l_lasso!=0 & l_bart==0 & l_pwm == 0)
                  , neg_neg_z=as.integer(l_lasso<0 & l_bart<0 & l_pwm == 0)
                  , neg_pos_z=as.integer(l_lasso<0 & l_bart>0 & l_pwm == 0)
                  , z_nz_z=as.integer(l_lasso==0 & l_bart!=0 & l_pwm == 0))
  df
}
read_data = function(model
                     , p_lasso=NULL
                     , p_de=NULL
                     , p_bart=NULL
                     , p_pwm=NULL
                     , p_new=NULL
                     , sep="\t"){
  if (!is.null(p_lasso) & p_lasso != "NONE"){
    df_lasso = read.csv(p_lasso, header=FALSE, sep=sep)
    if (length(colnames(df_lasso)) > 3){
      l_lasso = unlist(df_lasso)
    } else{
      l_lasso = df_lasso[3]
    }
  }
  
  if (!is.null(p_de) & p_de != "NONE"){
    df_de = read.csv(p_de, header=FALSE, sep=sep)
    if (length(colnames(df_de)) > 3){
      l_de = unlist(df_de)
    } else{
      l_de = df_de[3]
    }
  }
  
  if (!is.null(p_bart) & p_bart != "NONE"){
    df_bart = read.csv(p_bart, header=FALSE, sep=sep)
    if (length(colnames(df_bart)) > 3){
      l_bart = unlist(df_bart)
    } else{
      l_bart = df_bart[3]
    }
  }
  
  if (!is.null(p_pwm) & p_pwm != "NONE"){
    df_pwm = read.csv(p_pwm, header=FALSE, sep=sep)
    if (length(colnames(df_pwm)) > 3){
      l_pwm = unlist(df_pwm)
    } else{
      l_pwm = df_pwm[3]
    }
  }
  
  if (!is.null(p_new) & p_new != "NONE"){
    df_new = read.csv(p_new, header=FALSE, sep=sep)
    if (length(colnames(df_new)) > 3){
      l_new = unlist(df_new)
    } else{
      l_new = df_new[3]
    }
  }
    
  if (model == "dummy_ldbp"){
    df = dummy_ldbp(l_lasso=l_lasso
                   , l_de=l_de
                   , l_bart=l_bart
                   , l_pwm=l_pwm)
  } else if (model == "dummy_ldb"){
    df = dummy_ldb(l_lasso=l_lasso
                  , l_de=l_de
                  , l_bart=l_bart)
  } else if (model == "dummy_lbp"){
    df = dummy_lbp(l_lasso=l_lasso
                  , l_bart=l_bart
                  , l_pwm=l_pwm)
  } else if (model == "dummy_lb"){
    df = dummy_lb(l_lasso=l_lasso
                  , l_bart=l_bart)
  } else if (model == "dummy_ldbp_transform_v0"){
    df = dummy_ldbp_transform_v0(l_lasso=l_lasso
                      , l_de=l_de
                      , l_bart=l_bart
                      , l_pwm=l_pwm)
  } else if (model == "dummy_ldb_transform_v0"){
    df = dummy_ldb_transform_v0(l_lasso=l_lasso
                     , l_de=l_de
                     , l_bart=l_bart)
  } else if (model == "dummy_lbp_transform_v0"){
    df = dummy_lbp_transform_v0(l_lasso=l_lasso
                     , l_bart=l_bart
                     , l_pwm=l_pwm)
  } else if (model == "dummy_lb_transform_v0"){
    df = dummy_lb_transform_v0(l_lasso=l_lasso
                    , l_bart=l_bart)
  } else if (model == "dummy_ldbp_transform_v1"){
    df = dummy_ldbp_transform_v1(l_lasso=l_lasso
                                 , l_de=l_de
                                 , l_bart=l_bart
                                 , l_pwm=l_pwm)
  } else if (model == "dummy_ldb_transform_v1"){
    df = dummy_ldb_transform_v1(l_lasso=l_lasso
                                , l_de=l_de
                                , l_bart=l_bart)
  } else if (model == "dummy_lbp_transform_v1"){
    df = dummy_lbp_transform_v1(l_lasso=l_lasso
                                , l_bart=l_bart
                                , l_pwm=l_pwm)
  } else if (model == "dummy_lb_transform_v1"){
    df = dummy_lb_transform_v1(l_lasso=l_lasso
                               , l_bart=l_bart)
  } else if (model == "dummy_ldbp_transform_v2"){
    df = dummy_ldbp_transform_v2(l_lasso=l_lasso
                                 , l_de=l_de
                                 , l_bart=l_bart
                                 , l_pwm=l_pwm)
  } else if (model == "dummy_ldb_transform_v2"){
    df = dummy_ldb_transform_v2(l_lasso=l_lasso
                                , l_de=l_de
                                , l_bart=l_bart)
  } else if (model == "dummy_lbp_transform_v2"){
    df = dummy_lbp_transform_v2(l_lasso=l_lasso
                                , l_bart=l_bart
                                , l_pwm=l_pwm)
  } else if (model == "dummy_lb_transform_v2"){
    df = dummy_lb_transform_v2(l_lasso=l_lasso
                               , l_bart=l_bart)
  } else if (model == "dummy_ldbp_transform_v3"){
    df = dummy_ldbp_transform_v3(l_lasso=l_lasso
                                 , l_de=l_de
                                 , l_bart=l_bart
                                 , l_pwm=l_pwm)
  } else if (model == "dummy_ldb_transform_v3"){
    df = dummy_ldb_transform_v3(l_lasso=l_lasso
                                , l_de=l_de
                                , l_bart=l_bart)
  } else if (model == "dummy_lbp_transform_v3"){
    df = dummy_lbp_transform_v3(l_lasso=l_lasso
                                , l_bart=l_bart
                                , l_pwm=l_pwm)
  } else if (model == "dummy_lb_transform_v3"){
    df = dummy_lb_transform_v3(l_lasso=l_lasso
                               , l_bart=l_bart)
  } else if (model == "dummy_ldbp_transform"){
    df = dummy_ldbp_transform(l_lasso=l_lasso
                              , l_de=l_de
                              , l_bart=l_bart
                              , l_pwm=l_pwm)
  } else if (model == "dummy_ldbpn_transform"){
    df = dummy_ldbpn_transform(l_lasso=l_lasso
                              , l_de=l_de
                              , l_bart=l_bart
                              , l_pwm=l_pwm
                              , l_new=l_new
                              )
  } else if (model == "dummy_ldb_transform"){
    df = dummy_ldb_transform(l_lasso=l_lasso
                             , l_de=l_de
                             , l_bart=l_bart)
  } else if (model == "dummy_lbp_transform"){
    df = dummy_lbp_transform(l_lasso=l_lasso
                             , l_bart=l_bart
                             , l_pwm=l_pwm)
  } else if (model == "dummy_lb_transform"){
    df = dummy_lb_transform(l_lasso=l_lasso
                            , l_bart=l_bart)
  }else if (model == "detailed_ldbp"){
    df = detailed_ldbp(l_lasso=l_lasso
                   , l_de=l_de
                   , l_bart=l_bart
                   , l_pwm=l_pwm)
  } else if (model == "detailed_ldb"){
    df = detailed_ldb(l_lasso=l_lasso
                  , l_de=l_de
                  , l_bart=l_bart)
  } else if (model == "detailed_lbp"){
    df = detailed_lbp(l_lasso=l_lasso
                  , l_bart=l_bart
                  , l_pwm=l_pwm)
  } else if (model == "detailed_lb"){
    df = detailed_lb(l_lasso=l_lasso
                  , l_bart=l_bart)
  } else if (model == "dummy_ldbp_only_pwm_dummy"){
    df = dummy_ldbp_only_pwm_dummy(l_lasso=l_lasso
                                  , l_de=l_de
                                  , l_bart=l_bart
                                  , l_pwm=l_pwm)
  } else if (model == "dummy_lbp_only_pwm_dummy"){
    df = dummy_lbp_only_pwm_dummy(l_lasso=l_lasso
                                 , l_bart=l_bart
                                 , l_pwm=l_pwm)
  } else if (model == "dummy_ldbp_only_pwm_dummy_transform"){
    df = dummy_ldbp_only_pwm_dummy_transform(l_lasso=l_lasso
                                            , l_de=l_de
                                            , l_bart=l_bart
                                            , l_pwm=l_pwm)
  } else if (model == "dummy_lbp_only_pwm_dummy_transform"){
    df = dummy_lbp_only_pwm_dummy_transform(l_lasso=l_lasso
                                             , l_bart=l_bart
                                             , l_pwm=l_pwm)
  } else if (model == "atomic_ldbp"){
      df = atomic_ldbp(l_lasso=l_lasso
                      , l_de=l_de
                      , l_bart=l_bart
                      , l_pwm=l_pwm)
  } else if (model == "atomic_lbp"){
      df = atomic_lbp(l_lasso=l_lasso
                     , l_bart=l_bart
                     , l_pwm=l_pwm)
  } else if (model == "atomic_transform_ldbp"){
      df = atomic_transform_ldbp(l_lasso=l_lasso
                                  , l_de=l_de
                                  , l_bart=l_bart
                                  , l_pwm=l_pwm)
  } else if (model == "atomic_transform_lbp"){
      df = atomic_transform_lbp(l_lasso=l_lasso
                                 , l_bart=l_bart
                                 , l_pwm=l_pwm)
  } else if (model == "only_dummy_ldbp"){
    df = only_dummy_ldbp(l_lasso=l_lasso
                         , l_de=l_de
                         , l_bart=l_bart
                         , l_pwm=l_pwm)
  } else if (model == "only_dummy_lbp"){
    df = only_dummy_lbp(l_lasso=l_lasso
                        , l_bart=l_bart
                        , l_pwm=l_pwm)
  } else if (model == "dummy_ldbp_transform_v4"){
    df = dummy_ldbp_transform_v4(l_lasso=l_lasso
                                 , l_de=l_de
                                 , l_bart=l_bart
                                 , l_pwm=l_pwm)
  } else if (model == "dummy_ldb_transform_v4"){
    df = dummy_ldb_transform_v4(l_lasso=l_lasso
                                , l_de=l_de
                                , l_bart=l_bart)
  } else if (model == "dummy_lbp_transform_v4"){
    df = dummy_lbp_transform_v4(l_lasso=l_lasso
                                , l_bart=l_bart
                                , l_pwm=l_pwm)
  } else if (model == "dummy_lb_transform_v4"){
    df = dummy_lb_transform_v4(l_lasso=l_lasso
                               , l_bart=l_bart)
  }
  
  df
}