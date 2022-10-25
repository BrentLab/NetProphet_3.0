# helper function
def write_training_testing_sets(l_in_name_net
                                , l_in_path_net
                                , d_net_name__df
                                , d_fold__l_target_training
                                , d_fold__l_target_testing
                                , df_binding
                                , fold
                                , p_out_dir):
    # for all source of info
    for net_name, p_net in zip(l_in_name_net, l_in_path_net):
        if p_net == "NONE":  # if the path of network is an empty string, skip it. 
            continue
        # write training set
        df_train_net = d_net_name__df[net_name].loc[d_net_name__df[net_name]['TARGET'].isin(d_fold__l_target_training[fold]), :]
        df_train_net.to_csv(p_out_dir + 'fold' + str(fold) + '_train_' + net_name + '.tsv', header=False, index=False, sep='\t')
        # write testing set
        df_test_net = d_net_name__df[net_name].loc[d_net_name__df[net_name]['TARGET'].isin(d_fold__l_target_testing[fold]), :]
        df_test_net.to_csv(p_out_dir + 'fold' + str(fold) + '_test_' + net_name + '.tsv', header=False, index=False, sep='\t')
    
    # for binding data
    df_train_binding = df_binding.loc[df_binding['TARGET'].isin(d_fold__l_target_training[fold]), :]
    df_train_binding.to_csv(p_out_dir + 'fold' + str(fold) + '_train_binding.tsv', header=False, index=False, sep='\t')
    # write testing set
    df_test_binding = df_binding.loc[df_binding['TARGET'].isin(d_fold__l_target_testing[fold]), :]
    df_test_binding.to_csv(p_out_dir + 'fold' + str(fold) + '_test_binding.tsv', header=False, index=False, sep='\t')
    
    
def select_write_training_testing_sets_for_cv_folds(l_in_name_net
                                                     , l_in_path_net
                                                     , p_in_net_binding
                                                     , p_out_dir
                                                     , seed
                                                     , nbr_fold):
    """
    Select training and testing sets with folds cross validation fashion
    The selection is based on stratified sampling
    The file for training and testing sets are written in the p_output folder
    @param: l_t_name_p_in_net: lasso, de, and binding network. 
                               binding network is mandatory with name 'binding'
    """
    from json import load
    import sys
    from pandas import read_csv, Series, pivot_table, melt
    import numpy as np
    import os 

    # --------------------------------------------------- #
    # |          *** Initialize Parameters ***          | #
    # --------------------------------------------------- #
    d_net_name__df = {}  # a dictionary for input networks such lasso and de
    if not os.path.exists(p_out_dir):  # create the output folder if it doesn't exist
        os.makedirs(p_out_dir)
    # -------------------------------------------------------- #
    # |           *** Read Networks from files ***           | #
    # -------------------------------------------------------- #
    for net_name, p_net in zip(l_in_name_net, l_in_path_net):
        if p_net == "NONE":  # if the path of network is an empty string, skip it. 
            continue
        d_net_name__df[net_name] = read_csv(p_net, header=None, sep='\t')
        if len(d_net_name__df[net_name].columns) > 3:  # this is a matrix, melt it
            d_net_name__df[net_name] = read_csv(p_net, header=0, index_col=0, sep='\t')
            l_target = list(df_net_name.columns)
            d_net_name__df[net_name] = melt(d_net_name__df[net_name].reset_index(), id_vars='index', value_vars=l_target)
        d_net_name__df[net_name].columns = ['REGULATOR', 'TARGET', 'VALUE']
    
    # binding data
    df_binding = read_csv(p_in_net_binding, header=None, sep='\t')  
    if len(df_binding.columns) > 3:  # this is a matrix, melt it
        df_binding = read_csv(p_in_net_binding, header=0, index_col=0, sep='\t')
        l_target = list(df_net_name.columns)
        df_binding = melt(df_binding.reset_index(), id_vars='index', value_vars=l_target)
    df_binding.columns = ['REGULATOR', 'TARGET', 'VALUE']
    # -------------------------------------------------------------- #
    # |      *** Select targets for training and testing ***       | #
    # -------------------------------------------------------------- #
    d_fold__l_target_training, d_fold__l_target_testing = select_target_for_training_testing(
                                                                df_binding=df_binding
                                                                , p_out_dir=p_out_dir
                                                                , s=seed
                                                                , nbr_fold=nbr_fold
                                                                )

    # ---------------------------------------------------------- #
    # |      *** Write into the files Training/Testing ***     | #
    # ---------------------------------------------------------- #
    import multiprocessing as mp
    
    pool = mp.Pool(min([mp.cpu_count(), 4]))
    pool.starmap(write_training_testing_sets, [(l_in_name_net, l_in_path_net, d_net_name__df, d_fold__l_target_training, d_fold__l_target_testing, df_binding, i, p_out_dir) for i in range(nbr_fold)])
    pool.close()
    pool.join()
    
    
def select_target_for_training_testing(df_binding
                                       , p_out_dir
                                       , s
                                       , nbr_fold
                                      ):
    from random import shuffle, seed
    from pandas import Series
    
    l_target = list(set(df_binding.loc[:, 'TARGET']))
    seed(s)
    shuffle(l_target)
    nbr_target_per_fold = int(len(l_target)/nbr_fold)
    d_fold__l_target_testing, d_fold__l_target_training = {}, {}
    for fold in range(nbr_fold):
        start_idx = int(fold*nbr_target_per_fold)
        stop_idx = int((fold+1)*nbr_target_per_fold)
        d_fold__l_target_testing[fold] = l_target[start_idx:stop_idx]
        d_fold__l_target_training[fold] = [t for t in l_target if not t in d_fold__l_target_testing[fold]]
    
    # write the target for the training and testing sets
    for fold in range(nbr_fold):
        Series(d_fold__l_target_training[fold], name='target').to_csv(p_out_dir + 'fold' + str(fold) + '_train_target', header=False, index=False)
        Series(d_fold__l_target_testing[fold], name='target').to_csv(p_out_dir + 'fold' + str(fold) + '_test_target', header=False, index=False)

    return d_fold__l_target_training, d_fold__l_target_testing
    
def main():
    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument('--l_in_name_net', '-l_in_name_net',
                        help='list of name of networks such as binding and lasso')
    parser.add_argument('--l_in_path_net', '-l_in_path_net', help='list of paths of networks that names were provided')
    parser.add_argument('--p_in_net_binding', '-p_in_net_binding')
    parser.add_argument('--nbr_fold', '-nbr_fold', type=int, help='number of folds for dividing data in CV such as 10-fold')
    parser.add_argument('--p_out_dir', '-p_out_dir', help='path of output directory for the CV-folds data')
    parser.add_argument('--seed', '-seed', help='seed for selection', type=int, nargs='?', default=0)
    

    args = parser.parse_args()

    select_write_training_testing_sets_for_cv_folds(l_in_name_net=args.l_in_name_net.split(',')
                                             , l_in_path_net=args.l_in_path_net.split(',')
                                             , p_in_net_binding=args.p_in_net_binding
                                             , p_out_dir=args.p_out_dir
                                             , seed=args.seed
                                             , nbr_fold=args.nbr_fold)


if __name__ == '__main__':
    main()