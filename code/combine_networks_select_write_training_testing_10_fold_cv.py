from json import load

def select_write_training_testing_10_fold_cv(l_net_name
                                             , l_p_net
                                             , p_out_dir
                                             , exclude_tf
                                             , seed
                                             , p_reg
                                             , p_target
                                             , p_src_code
                                             ):
    # have l_p_net instead of p_lasso and p_de
    """
    Select training and testing sets with 10-fold cross validation fashion
    The selection is based on stratified sampling
    The file for training and testing sets are written in the p_output folder
    @param: l_t_name_p_in_net: lasso, de, and binding network. 
                               binding network is mandatory with name 'binding'
    """
    from json import load
    import sys
   
    sys.path.insert(1, p_src_code+'code')  # include the path of code of netprophet project
    from pandas import read_csv, Series, pivot_table, melt
    import numpy as np

    from helper import read_csv_indexed
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
    for net_name, p_net in zip(l_net_name, l_p_net):
        if p_net == "NONE":  # if the path of network is an empty string, skip it. 
            continue
        d_net_name__df[net_name] = read_csv(p_net, header=None, sep='\t')
        if len(d_net_name__df[net_name].columns) > 3:  # this is a matrix, melt it
            l_target = list(read_csv(p_target, header=None)[0])
            l_reg = list(read_csv(p_reg, header=None)[0])
            d_net_name__df[net_name] = read_csv_indexed(p_df=p_net, p_index=p_reg, p_column=p_target)
            d_net_name__df[net_name] = melt(d_net_name__df[net_name].reset_index(), id_vars='index', value_vars=l_target)
        d_net_name__df[net_name].columns = ['REGULATOR', 'TARGET', 'VALUE']
            
    # ---------------------------------------------------------- #
    # |      *** Select reg for training and testing ***       | #
    # ---------------------------------------------------------- #
    d_fold__l_reg_training, d_fold__l_reg_testing = select_reg_for_training_testing(
                                                                df_binding=d_net_name__df['binding']
                                                                , p_out_dir=p_out_dir
                                                                , s=seed
                                                                , exclude_tf=exclude_tf
                                                                , p_src_code=p_src_code
                                                                )

    # ---------------------------------------------------------- #
    # |      *** Write into the files Training/Testing ***     | #
    # ---------------------------------------------------------- #
    for fold in range(10):
        for net_name, p_net in zip(l_net_name, l_p_net):
            if p_net == "NONE":  # if the path of network is an empty string, skip it. 
                continue
            # write training set
            df_train_net = d_net_name__df[net_name].loc[d_net_name__df[net_name]['REGULATOR'].isin(d_fold__l_reg_training[fold]), :]
            df_train_net.to_csv(p_out_dir + 'fold' + str(fold) + '_train_' + net_name + '.tsv', header=False, index=False, sep='\t')
            # write testing set
            df_test_net = d_net_name__df[net_name].loc[d_net_name__df[net_name]['REGULATOR'].isin(d_fold__l_reg_testing[fold]), :]
            df_test_net.to_csv(p_out_dir + 'fold' + str(fold) + '_test_' + net_name + '.tsv', header=False, index=False, sep='\t')


def select_reg_for_training_testing(df_binding
                                    , p_out_dir
                                    , s
                                    , exclude_tf
                                    , p_src_code
                                    ):
    """
    Select the regulators for the training and testing sets. Given the binding data, a stratified 
    list of training and testing for 10-fold of CV is created. The stratification is based on the 
    number of targets per TF 
    """

    import sys
    from json import load
    from random import seed, sample

    # d_run_config__value = load(open(P_CONFIG, 'r'))
    sys.path.insert(1, p_src_code+'code')  # include the path of code of netprophet project
    from pandas import Series

    if exclude_tf == 'ON':
        df_binding = df_binding[df_binding.VALUE == 1]

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
    FLAG_DEBUG = 'OFF'
    if FLAG_DEBUG == 'ON':
        exclude_tf = 'OFF'
        select_write_training_testing_10_fold_cv(l_net_name=['binding', 'lasso', 'de']
                                                 , l_p_net=[
                '/Users/dhohaabid/Documents/netprophet3.0/net_out/zev_feed_netprophet_seed0_10cv_seed0_by_20k_15k_10k/top_20000_cc_exo_chip_exclusive.tsv'
                ,
                '/Users/dhohaabid/Documents/netprophet3.0/net_out/zev_feed_netprophet_seed0_10cv_seed0_by_20k_15k_10k/top_20000_zev_lasso_expr.tsv'
                ,
                '/Users/dhohaabid/Documents/netprophet3.0/net_out/zev_feed_netprophet_seed0_10cv_seed0_by_20k_15k_10k/top_20000_zev_de_shrunken.tsv']
                                                 ,
                                                 p_out_dir='/Users/dhohaabid/Documents/netprophet3.0/net_out/zev_feed_netprophet_seed0_10cv_seed0_by_20k_15k_10k_tryme2/'
                                                 , exclude_tf=exclude_tf
                                                 , seed=1
                                                 , p_reg=None
                                                 , p_target=None)

    else:
        from argparse import ArgumentParser

        parser = ArgumentParser()
        parser.add_argument('--l_net_name', '-l_net_name', nargs='+',
                            help='list of name of networks such as binding and lasso')
        parser.add_argument('--l_p_net', '-l_p_net', nargs='+', help='list of paths of networks that names were provided')
        parser.add_argument('--p_out_dir', '-p_out_dir', help='path of output directory for the 10-fold data')
        parser.add_argument('--exclude_tf', '-exclude_tf', help='flag to exclude tf with no supported events at top edges'
                            , default='OFF')
        parser.add_argument('--seed', '-seed', help='seed for selection', type=int, nargs='?', default=0)
        parser.add_argument('--flag_debug', '-flag_debug', nargs='+', default='OFF')
        parser.add_argument('--p_reg', '-p_reg', nargs='?', default=None, help='file of list of regulators, only needed when the input networks is matrix')
        parser.add_argument('--p_target', '-p_target', nargs='?', default=None, help='file of list of target genes, only needed when the input networks is matrix')
        parser.add_argument('--p_src_code', '-p_src_code', help='path of source code for netprophet')

        args = parser.parse_args()

        select_write_training_testing_10_fold_cv(l_net_name=args.l_net_name
                                                 , l_p_net=args.l_p_net
                                                 , p_out_dir=args.p_out_dir
                                                 , exclude_tf=args.exclude_tf
                                                 , seed=args.seed
                                                 , p_reg=args.p_reg
                                                 , p_target=args.p_target
                                                 , p_src_code=args.p_src_code
                                                )


if __name__ == '__main__':
    main()
