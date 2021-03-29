# helper function
def write_training_testing_sets(l_in_name_net
                                , l_in_path_net
                                , d_net_name__df
                                , d_fold__l_reg_training
                                , d_fold__l_reg_testing
                                , df_binding
                                , fold
                                , p_out_dir):
    # for all source of info
    for net_name, p_net in zip(l_in_name_net, l_in_path_net):
        if p_net == "NONE":  # if the path of network is an empty string, skip it. 
            continue
        # write training set
        df_train_net = d_net_name__df[net_name].loc[d_net_name__df[net_name]['REGULATOR'].isin(d_fold__l_reg_training[fold]), :]
        df_train_net.to_csv(p_out_dir + 'fold' + str(fold) + '_train_' + net_name + '.tsv', header=False, index=False, sep='\t')
        # write testing set
        df_test_net = d_net_name__df[net_name].loc[d_net_name__df[net_name]['REGULATOR'].isin(d_fold__l_reg_testing[fold]), :]
        df_test_net.to_csv(p_out_dir + 'fold' + str(fold) + '_test_' + net_name + '.tsv', header=False, index=False, sep='\t')
    
    # for binding data
    df_train_binding = df_binding.loc[df_binding['REGULATOR'].isin(d_fold__l_reg_training[fold]), :]
    df_train_binding.to_csv(p_out_dir + 'fold' + str(fold) + '_train_binding.tsv', header=False, index=False, sep='\t')
    # write testing set
    df_test_binding = df_binding.loc[df_binding['REGULATOR'].isin(d_fold__l_reg_testing[fold]), :]
    df_test_binding.to_csv(p_out_dir + 'fold' + str(fold) + '_test_binding.tsv', header=False, index=False, sep='\t')

def select_write_training_testing_10_fold_cv(l_in_name_net
                                             , l_in_path_net
                                             , p_in_net_binding
                                             , p_out_dir
                                             , seed):
    """
    Select training and testing sets with 10-fold cross validation fashion
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
    # ---------------------------------------------------------- #
    # |      *** Select reg for training and testing ***       | #
    # ---------------------------------------------------------- #
    d_fold__l_reg_training, d_fold__l_reg_testing = select_reg_for_training_testing(
                                                                df_binding=df_binding
                                                                , p_out_dir=p_out_dir
                                                                , s=seed
                                                                )

    # ---------------------------------------------------------- #
    # |      *** Write into the files Training/Testing ***     | #
    # ---------------------------------------------------------- #
    import multiprocessing as mp
    
    pool = mp.Pool(min([mp.cpu_count(), 4]))
    pool.starmap(write_training_testing_sets, [(l_in_name_net, l_in_path_net, d_net_name__df, d_fold__l_reg_training, d_fold__l_reg_testing, df_binding, i, p_out_dir) for i in range(10)])
    pool.close()
    pool.join()

    
def select_reg_for_training_testing(df_binding
                                    , p_out_dir
                                    , s
                                    ):
    """
    Select the regulators for the training and testing sets. Given the binding data, a stratified 
    list of training and testing for 10-fold of CV is created. The stratification is based on the 
    number of targets per TF 
    """

    import sys
    from json import load
    from random import seed, sample
    from pandas import Series

    df_binding_grouped = df_binding.groupby('REGULATOR').sum()

    # sort grouped regulators by number of target genes
    df_binding_grouped_sorted = df_binding_grouped.sort_values(ascending=False, by='VALUE')
    # initialize general variables
    nbr_cutoff = int(df_binding_grouped_sorted.shape[0]/10)
    size_last_cutoff = int(df_binding_grouped_sorted.shape[0]%10)
    d_fold__l_reg_training = {0:[], 1:[], 2:[], 3:[], 4:[], 5:[], 6:[], 7:[], 8:[], 9:[]}
    d_fold__l_reg_testing = {0:[], 1:[], 2:[], 3:[], 4:[], 5:[], 6:[], 7:[], 8:[], 9:[]}
    # stratify the regulator based on the number of target genes
    for i in range(nbr_cutoff):
        # extract index start and end for cutoff
        if i == nbr_cutoff - 1:  # if last cutoff
            idx_start, idx_end = i*10, i*10+10+size_last_cutoff
        else:
            idx_start, idx_end = i*10, i*10+10
        # extract list of regulators for that cutoff
        l_reg_cutoff = list(df_binding_grouped_sorted.iloc[idx_start:idx_end, :].index)
        # randomly permute the items of this list
        seed(s)
        l_reg_cutoff = sample(l_reg_cutoff, len(l_reg_cutoff))
        # select regulators for training and testing
        for idx_reg, reg in enumerate(l_reg_cutoff):  # populate the list of regulators for testing
            d_fold__l_reg_testing[idx_reg%10].append(reg)
        for fold in range(10):  # populate the list of regulators for training
            d_fold__l_reg_training[fold] += [r for r in l_reg_cutoff if (r not in d_fold__l_reg_testing[fold]) and (int(df_binding_grouped_sorted[df_binding_grouped_sorted.index == r].VALUE) != 0)]

    # write the regulators for the training and testing sets
    for fold in range(10):
        Series(d_fold__l_reg_training[fold], name='reg').to_csv(p_out_dir + 'fold' + str(fold) + '_train_reg', header=False, index=False)
        Series(d_fold__l_reg_testing[fold], name='reg').to_csv(p_out_dir + 'fold' + str(fold) + '_test_reg', header=False, index=False)
    return d_fold__l_reg_training, d_fold__l_reg_testing


def main():
    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument('--l_in_name_net', '-l_in_name_net',
                        help='list of name of networks such as binding and lasso')
    parser.add_argument('--l_in_path_net', '-l_in_path_net', help='list of paths of networks that names were provided')
    parser.add_argument('--p_in_net_binding', '-p_in_net_binding')
    parser.add_argument('--p_out_dir', '-p_out_dir', help='path of output directory for the 10-fold data')
    parser.add_argument('--seed', '-seed', help='seed for selection', type=int, nargs='?', default=0)

    args = parser.parse_args()

    select_write_training_testing_10_fold_cv(l_in_name_net=args.l_in_name_net.split(',')
                                     , l_in_path_net=args.l_in_path_net.split(',')
                                     , p_in_net_binding=args.p_in_net_binding
                                     , p_out_dir=args.p_out_dir
                                     , seed=args.seed)

if __name__ == '__main__':
    main()
