def select_write_training_testing_1_fold_cv(p_net_binding
                                            , l_net_name
                                            , l_p_net
                                            , seed
                                            , nbr_reg
                                            , p_out_dir):
    from pandas import read_csv, melt, Series
    from os import path, mkdir
    
    # if output directory does not exist, create it
    if not path.exists(p_out_dir):
        mkdir(p_out_dir)
        
    # read the binding network
    df_binding = read_csv(p_net_binding, header=None, sep='\t', low_memory=False)
    if len(df_binding.columns.to_list()) > 3:
        df_binding = read_csv(p_net_binding, header=0, index_col=0, sep='\t')
        l_target = df_binding.columns.to_list()
        df_binding = melt(df_binding.reset_index(), id_vars='index', value_vars=l_target)
    df_binding.columns = ['REGULATOR', 'TARGET', 'VALUE']

    # retrieve the list of regulators that will be used for the training
    l_reg_training, l_reg_testing = \
                    select_reg_for_training(df_binding=df_binding
                                           , p_out_dir=p_out_dir
                                           , s=seed
                                           , nbr_reg=nbr_reg)
    # write binding data for training  
    df_binding_training = df_binding.loc[df_binding.REGULATOR.isin(l_reg_training), :]
    df_binding_training.to_csv(p_out_dir + 'train_binding.tsv', header=False, index=False, sep='\t')
    
    # extract the training/testing for other networks: lasso, de, etc.
    for net_name, p_net in zip(l_net_name, l_p_net):
        if p_net == "NONE":
            continue
        df_net = read_csv(p_net, header=None, sep='\t', low_memory=False)
        if len(df_net.columns.to_list()) > 3: # this is a matrix, melt it
            df_net = read_csv(p_net, header=0, index_col=0, sep='\t')
            l_target = df_net.columns.to_list()
            df_net = melt(df_net.reset_index(), id_vars='index', value_vars=l_target)
        df_net.columns = ['REGULATOR', 'TARGET', 'VALUE']

        # write training data
        Series(l_reg_training, name='regulator').to_csv(p_out_dir + 'train_reg', header=False, index=False, sep='\t')
        df_training = df_net.loc[df_net.REGULATOR.isin(l_reg_training), :]
        df_training.to_csv(p_out_dir + 'train_' + net_name + '.tsv', header=False, index=False, sep='\t')

        # write testing data
        Series(l_reg_testing, name='regulator').to_csv(p_out_dir + 'test_reg', header=False, index=False, sep='\t')
        df_testing = df_net.loc[df_net.REGULATOR.isin(l_reg_testing), :]
        df_testing.to_csv(p_out_dir + 'test_' + net_name + '.tsv', header=False, index=False, sep='\t')


def select_reg_for_training(df_binding
                           , p_out_dir
                           , s
                           , nbr_reg):
    
    from random import seed, sample
    
    df_binding_grouped = df_binding.groupby('REGULATOR').sum()
    l_binding_reg_all = list(df_binding_grouped.index)
    df_binding_grouped_sorted = df_binding_grouped.sort_values(ascending=False, by='VALUE')
    df_binding_grouped_sorted = df_binding_grouped_sorted[df_binding_grouped_sorted.VALUE > 0]  # take only regulators that have at least a target gene
    l_binding_reg = list(df_binding_grouped_sorted.index)
    nbr_cutoff = int(len(l_binding_reg)/nbr_reg)
    l_reg_training, l_reg_testing = [], []
    seed(s)
    for i in range(nbr_reg):
        reg_idx = sample(range(nbr_cutoff*i, nbr_cutoff*i+nbr_cutoff, 1), 1)[0]
        l_reg_training.append(l_binding_reg[reg_idx])
    
    l_reg_testing = [reg for reg in l_binding_reg_all if not reg in l_reg_training]
    
    return l_reg_training, l_reg_testing


def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    
    parser.add_argument('--p_in_net_binding', '-p_in_net_binding', help='path of network for binding')
    parser.add_argument('--l_in_name_net', '-l_in_name_net', help='list of name of networks such as binding, lasso, de, etc')
    parser.add_argument('--l_in_path_net', '-l_in_path_net', help='list of paths of networks that names were provided in l_net_name')
    parser.add_argument('--seed', '-seed', help='seed for selection of training and testing', type=int)
    parser.add_argument('--p_out_dir', '-p_out_dir', help='path of directory for output')
    parser.add_argument('--in_nbr_reg', '-in_nbr_reg', type=int, help='integer: number of regulators that will be used for the training')
    
    args = parser.parse_args()
    
    select_write_training_testing_1_fold_cv(p_net_binding=args.p_in_net_binding
                                            , l_net_name=args.l_in_name_net.split(',')
                                            , l_p_net=args.l_in_path_net.split(',')
                                            , seed=args.seed
                                            , nbr_reg=args.in_nbr_reg
                                            , p_out_dir=args.p_out_dir)


if __name__ == '__main__':
    main()