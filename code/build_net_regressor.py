def fit_model(model_name
              , df_x
              , df_y
              , flag_optimize
              , seed
             ):
    
    # ================================================= #
    # |             *** Random Forest ***             | #
    # ================================================= #
    if model_name == 'random_forest':
        from sklearn.ensemble import RandomForestRegressor
    
        if flag_optimize == 'OFF':
            # create the model
            model = RandomForestRegressor(random_state=seed, n_jobs=-1, n_estimators=1000)

            # fit the model
            model.fit(df_x, df_y)

        elif flag_optimize == 'ON':
            from sklearn.model_selection import GridSearchCV

            # create grid for search
            nbr_reg = int(df_x.shape[1])
            param_grid = {
                'min_samples_leaf': [3, 6],
                'min_samples_split': [2, 6],
                'n_estimators': [50, 100, 200, 300],
                'warm_start': [True]
                
                }

            # create model
            model = RandomForestRegressor(random_state=seed, n_jobs=-1)

            # Instantiate the grid search model
            grid_search = GridSearchCV(
                estimator=model
                , param_grid=param_grid
                , cv=5
                , n_jobs=-1
                , verbose=3
            )

            # fit the grid search
            grid_search.fit(df_x, df_y)

            model = grid_search.best_estimator_
        
    # ================================================= #
    # |              *** Extra Trees ***              | #
    # ================================================= #
    elif model_name == 'extra_trees':
        pass
    return model
    
def prepare_data(p_expr_target
                , p_expr_reg):
    from pandas import read_csv, DataFrame
    
    df_expr_target = read_csv(p_expr_target, header=0, index_col=0, sep='\t')
    df_expr_reg = read_csv(p_expr_reg, header=0, index_col=0, sep='\t')
    l_target = list(df_expr_target.index)
    l_reg = list(df_expr_reg.index)
    
    # prepare df_allowed
    df_allowed = DataFrame([[False for i in range(len(l_target))] for j in range(len(l_reg))]
                           , index=l_reg
                           , columns=l_target)
    for reg in l_reg:
        try:
            df_allowed.loc[reg, reg] = True
        except KeyError:
            continue
        
    # prepare q0 and q100 for testing
    df_q0 = DataFrame([df_expr_reg.T.median() for i in range(len(l_reg))]
         , index=df_expr_reg.index)
    df_q100 = DataFrame([df_expr_reg.T.median() for i in range(len(l_reg))]
             , index=df_expr_reg.index)
    
    for reg in l_reg:
        df_q0.loc[reg, reg] = df_expr_reg.T.min()[reg]
        df_q100.loc[reg, reg] = df_expr_reg.T.max()[reg]
        
    return df_expr_target, df_expr_reg, l_reg, l_target, df_allowed, df_q0, df_q100
    
def build_net(p_expr_target
              , p_expr_reg
              , model_name
              , flag_optimize
              , p_out_net
              , seed
              , p_src_code
             ):
    
    from pandas import read_csv, DataFrame, concat
    
    # prepare data
    df_expr_target, \
    df_expr_reg, \
    l_reg, \
    l_target, \
    df_allowed, \
    df_q0, df_q100 = prepare_data(p_expr_target
                                  , p_expr_reg)
    
    
    # define the model
    df_net = DataFrame()
    for target in l_target:
        # check if all reg are allowed
        l_reg_not_allowed = list(df_allowed.loc[:, target][df_allowed.loc[:, target] == True].index)
        df_expr_reg_allowed = df_expr_reg.copy()
        df_q0_allowed = df_q0.copy()
        df_q100_allowed = df_q100.copy()
        
        if l_reg_not_allowed:
            df_expr_reg_allowed.loc[l_reg_not_allowed, :] = 0
            df_q0_allowed.loc[l_reg_not_allowed, :] = 0
            df_q0_allowed.loc[:, l_reg_not_allowed] = 0
            df_q100_allowed.loc[l_reg_not_allowed, :] = 0
            df_q100_allowed.loc[:, l_reg_not_allowed] = 0

        model = fit_model(model_name=model_name
                          , df_x=df_expr_reg_allowed.T
                          , df_y=df_expr_target.loc[target, :]
                          , flag_optimize=flag_optimize
                          , seed=seed
                         )
        predict_q0 = model.predict(df_q0_allowed)
        predict_q100 = model.predict(df_q100_allowed)
        
#         # normalize the difference
#         df_predict_q0_q100 = DataFrame([predict_q0, predict_q100], index=['q0', 'q100']).T
#         df_predict_max = df_predict_q0_q100.abs().T.max()
#         df_predict_max = df_predict_max.replace(0, 1)
#         df_predict = DataFrame(predict_q100-predict_q0).divide(df_predict_q0_q100.loc[:, 'q0'], axis='index')
#         df_predict.columns = [target]
        df_net= concat([df_net, DataFrame(predict_q100-predict_q0, columns=[target])], axis='columns')
        # df_net= concat([df_net, df_predict], axis='columns')
        
    df_net.index = l_reg
    df_net.to_csv(p_out_net + '_indexed.tsv', header=True, index=True, sep='\t')
    df_net.to_csv(p_out_net + '_unindexed.tsv', header=False, index=False, sep='\t')
        
if __name__ == '__main__':
    from argparse import ArgumentParser

    parser = ArgumentParser()

    parser.add_argument('--p_expr_target')
    parser.add_argument('--p_expr_reg')
    parser.add_argument('--model_name')
    parser.add_argument('--flag_optimize', nargs='?', default='OFF')
    parser.add_argument('--p_out_net')
    parser.add_argument('--seed')
    parser.add_argument('--p_src_code')


    args = parser.parse_args()
    
    df_net = build_net(p_expr_target=args.p_expr_target
                       , p_expr_reg=args.p_expr_reg
                       , model_name=args.model_name
                       , flag_optimize=args.flag_optimize
                       , p_out_net=args.p_out_net
                       , seed=args.seed
                       , p_src_code=args.p_src_code
                      )