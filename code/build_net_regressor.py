def define_model(model_name):
    from sklearn import ensemble
    from sklearn import neighbors
    from sklearn import neural_network
    from sklearn import tree
    from sklearn import gaussian_process
    
    if model_name == 'ada_boost':
        model = ensemble.AdaBoostRegressor(random_state=0)
    elif model_name == 'bagging':
        model = ensemble.BaggingRegressor(n_jobs=-1)
    elif model_name == 'extra_trees':
        model = ensemble.ExtraTreesRegressor(n_jobs=-1)
    elif model_name == 'gradient_boosting':
        model = ensemble.GradientBoostingRegressor(random_state=0)
    elif model_name == 'random_forest':
        model = ensemble.RandomForestRegressor(n_jobs=-1, random_state=0)
    elif model_name == 'stacking':
        model = ensemble.StackingRegressor(
            estimators=[('b', ensemble.BaggingRegressor(n_jobs=-1))
                        , ('tr', ensemble.ExtraTreesRegressor(n_jobs=-1))]
            , final_estimator=ensemble.RandomForestRegressor(n_jobs=-1, random_state=0)
            , n_jobs=-1)
    elif model_name == 'voting':
        model = ensemble.VotingRegressor(
            [('rf', ensemble.RandomForestRegressor(n_jobs=-1, random_state=0))
             , ('b', ensemble.BaggingRegressor(n_jobs=-1))
             , ('tr', ensemble.ExtraTreesRegressor(n_jobs=-1))
            ], n_jobs=-1)
    elif model_name == 'kneighbors':
        model = neighbors.KNeighborsRegressor(n_jobs=-1)
    elif model_name == 'radius_neighbors':
        model = neighbors.RadiusNeighborsRegressor(n_jobs=-1)
    elif model_name == 'mlp':
        model = neural_network.MLPRegressor(random_state=0)
    elif model_name == 'decision_tree':
        model = tree.DecisionTreeRegressor(random_state=0)
    elif model_name == 'gaussian_process':
        model = gaussian_process.GaussianProcessRegressor(random_state=0)
    else:
        print(model_name, 'this model is not considered')
        exit()
    
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
             , p_out_net):
    
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
    model = define_model(model_name)
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

        model.fit(df_expr_reg_allowed.T, df_expr_target.loc[target, :])
        predict_q0 = model.predict(df_q0_allowed)
        predict_q100 = model.predict(df_q100_allowed)
        df_net= concat([df_net, DataFrame(predict_q0-predict_q100, columns=[target])]
                        , axis='columns')
        
    df_net.index = l_reg
    df_net.to_csv(p_out_net + '_indexed.tsv', header=True, index=True, sep='\t')
    df_net.to_csv(p_out_net + '_unindexed.tsv', header=False, index=False, sep='\t')
        
if __name__ == '__main__':
    from argparse import ArgumentParser

    parser = ArgumentParser()

    parser.add_argument('--p_expr_target')
    parser.add_argument('--p_expr_reg')
    parser.add_argument('--model_name')
    parser.add_argument('--p_out_net')


    args = parser.parse_args()
    
    df_net = build_net(p_expr_target=args.p_expr_target
                       , p_expr_reg=args.p_expr_reg
                       , model_name=args.model_name
                       , p_out_net=args.p_out_net)