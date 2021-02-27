def fit_model(df_x
              , df_y
              , flag_optimize
              , seed
              ):
    
    from sklearn.ensemble import RandomForestRegressor
    
    if flag_optimize == 'OFF':
        # create the model
        model = RandomForestRegressor(random_state=seed)
        
        # fit the model
        model.fit(df_x, df_y)
        
    elif flag_optimize == 'ON':
        from sklearn.model_selection import GridSearchCV
        
        # create grid for search
        param_grid = {
            'bootstrap': [True]
            , 'max_depth': [80, 90, 100, 110]
            , 'max_features': [2, 3]
            , 'min_samples_leaf': [3, 4, 5]
            , 'min_sample_split': [8, 10, 12]
            , 'n_estimators': [100, 200, 300, 1000]
            }
        
        # create model
        model = RandomForestRegressor(random_state=seed)
        
        # Instantiate the grid search model
        grid_search = GridSearchCV(
            estimator=model
            , param_grid=param_grid
            , cv=10
            , n_jobs=-1
            , verbose=2
        )
        
        # fit the grid search
        grid_search.fit(df_x, df_y)
        
        model = grid_search.best_estimator
        
    return model
    


if __name__ == '__main__':
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    
    parser.add_argument('--p_expr_target')
    parser.add_argument('--p_expr_reg')
    parser.add_argument('--flag_optimize', nargs='?', default='OFF')
    parser.add_argument('--p_out_net')
    parser.add_argument('--seed', nargs='?', default=0)
    parser.add_argument('--p_src_code')
    
    args = parser.parse_args()
    
    build_net(p_expr_target=args.p_expr_target
              , p_expr_reg=args.p_expr_reg
              , flag_optimize=args.flag_optimize
              , p_out_net=args.p_out_net
              , seed=args.seed
              , p_src_code=args.p_src_code
             )