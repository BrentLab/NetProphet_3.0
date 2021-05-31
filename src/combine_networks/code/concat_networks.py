def concat_networks(p_in_dir_data
                    , p_in_dir_pred
                    , p_out_file
                    , file_suffix
                    , flag_matrix
                    , p_in_reg
                    , p_in_target
                    , flag_method
                    , l_p_in_net
                    , nbr_fold
                   ):
    from pandas import read_csv, concat, DataFrame, pivot_table
    from json import load
    if flag_method == 'with_and_without_de':
        df_net_with_de = read_csv(l_p_in_net[0], header=None, sep='\t')
        df_net_with_de.index = [(reg, target) for reg, target in zip(list(df_net_with_de.iloc[:, 0])
                                                                     , list(df_net_with_de.iloc[:, 1]))]
        df_net_without_de = read_csv(l_p_in_net[1], header=None, sep='\t')
        df_net_without_de.index = [(reg, target) for reg, target in zip(list(df_net_without_de.iloc[:, 0]), list(df_net_without_de.iloc[:, 1]))]
        # remove edges that were predicted using DE network
        df_net_without_de_filtered = df_net_without_de.loc[~df_net_without_de.index.isin(df_net_with_de.index), :]
        df_net_all = concat([df_net_with_de, df_net_without_de_filtered], axis='index')
        df_net_all.to_csv(p_out_file, header=False, index=False, sep='\t')
        
    if flag_method == 'a':
        df_net_all = DataFrame()
        for p_df_net in l_p_in_net:
            if p_df_net != 'NONE':
                df_net = read_csv(p_df_net, header=None, sep='\t')
                df_net_all = concat([df_net, df_net_all], axis='index')
        df_net_all.to_csv(p_out_file, header=False, index=False, sep='\t')
    elif flag_method == 'concat_cv':
        # concatenate the sub-networks
        df_net = DataFrame()
        for i in range(nbr_fold):
            p_pred_test = p_in_dir_pred + "fold" + str(i) + (file_suffix if file_suffix else "_pred_test.tsv")
            df = read_csv(p_pred_test, header=None, sep="\t")
            if len(list(df.columns)) > 3:  # matrix format
                l_reg = list(read_csv(p_in_dir_data + "fold" + str(i) + "_test_reg", header=None, sep="\t")[0])
                df.index = l_reg
            df_net = concat([df_net, df], axis="index")

        if len(list(df.columns)) > 3:  # reindex the matrix in case of matrix
            # extract info about regulators from config file
            # d_run_config__value = load(open(P_CONFIG, 'r'))
            #  p_reg = d_run_config__value['p_reg']
            l_reg_all = list(read_csv(p_reg, header=None)[0])
            df_net = df_net.reindex(l_reg_all, axis='index')
        elif flag_matrix == "ON":
            df_net.columns = ['REGULATOR', 'TARGET', 'VALUE']
            df_net = pivot_table(df_net, values='VALUE', index=['REGULATOR'], columns=['TARGET'])
            l_reg = list(read_csv(p_in_reg, header=None)[0])
            l_target = list(read_csv(p_in_target, header=None)[0])
            df_net = df_net.reindex(l_reg, axis='index', fill_value=0)
            df_net = df_net.reindex(l_target, axis='columns', fill_value=0) 
        df_net.to_csv(p_out_file, header=False, index=False, sep='\t')


def main():
    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument("--p_in_dir_data", "-p_in_dir_data", nargs='?', default=None, help="path of input directory of training/testing files")
    parser.add_argument("--p_in_dir_pred", "--p_in_dir_pred", nargs='?', default=None, help="path of input directory of model and predictions")
    parser.add_argument("--p_out_file", "-p_out_file", help="path of output directory")
    parser.add_argument("--file_suffix", "-file_suffix", nargs='?', default=None,
                        help="suffix of files for concatenation")
    parser.add_argument("--flag_matrix", "-flag_matrix", nargs="?", default="OFF"
                        , help="ON or OFF, for outputing matrix network or not")
    parser.add_argument("--p_in_reg", "-p_in_reg", nargs='?', default=None, help="path of file for regulators")
    parser.add_argument("--p_in_target", "-p_in_target", nargs='?', default=None, help="path of file for targets")
    parser.add_argument('--flag_method', '-flag_method', nargs='?', default='concat_cv', help='a for separate files or b for 10-fold CV files')
    parser.add_argument('--nbr_fold', '-nbr_fold', nargs='?', type=int, default=10, help='number of fold for concat_cv')
    parser.add_argument('--l_p_in_net', '-l_p_in_net', nargs='+', default=None, help='list of network files to concatenate')
    
    args = parser.parse_args()

    concat_networks(p_in_dir_data=args.p_in_dir_data
                    , p_in_dir_pred=args.p_in_dir_pred
                    , p_out_file=args.p_out_file
                    , file_suffix=args.file_suffix
                    , flag_matrix=args.flag_matrix
                    , p_in_reg=args.p_in_reg
                    , p_in_target=args.p_in_target
                    , flag_method=args.flag_method
                    , l_p_in_net=args.l_p_in_net
                    , nbr_fold=args.nbr_fold
                    )


if __name__ == "__main__":
    main()
