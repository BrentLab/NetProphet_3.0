def normalize_source_of_information(method
                                    , p_net_lasso_ref='NONE'
                                    , p_net_de_ref='NONE'
                                    , p_net_bart_ref='NONE'
                                    , p_net_pwm_ref='NONE'
                                    , p_net_lasso='NONE'
                                    , p_net_de='NONE'
                                    , p_net_bart='NONE'
                                    , p_net_pwm='NONE'
                                    , p_out_dir=None):

    from pandas import read_csv, melt, pivot_table
    import numpy as np
    
    for net_name, p_net in zip(['lasso', 'de', 'bart', 'pwm']
                               , [p_net_lasso, p_net_de, p_net_bart, p_net_pwm]):
        if p_net == "NONE":
            continue   
        df_net = read_csv(p_net, header=0, index_col=0, sep='\t')

        if method == 'smallest':
            ar_net = np.array(df_net.abs()).flatten()
            scale = ar_net[ar_net>0].min()
            if scale != 0:
                df_net = df_net/scale
            else:
                print('scale is equal zero for network: ', net_name)
        elif method == 'std':
            ar_net = np.array(df_net)
            scale = np.std(ar_net)
            if scale != 0:
                df_net = df_net/scale
            else:
                print('scale is equal zero for network: ', net_name)
        elif method == 'non_zero_90th':
            ar_net = np.array(df_net.abs()).flatten()
            ar_net = ar_net[ar_net > 0]
            scale = np.percentile(ar_net, 90)
            if scale != 0:
                df_net = df_net/scale
            else:
                print('scale is equal zero for network: ', net_name)
        elif method == 'non_zero_std':
            ar_net = np.array(df_net.abs()).flatten()
            ar_net = ar_net[ar_net > 0]
            scale = np.std(ar_net)
            if scale != 0:
                df_net = df_net/scale
            else:
                print('scale is equal zero for network: ', net_name)
        elif method == 'quantile':
            nbr_bins=10000
            # translated network
            df_net_trans = read_csv(p_net_lasso, header=0, index_col=0, sep='\t')
            l_target_trans = df_net_trans.columns.to_list()
            l_reg = df_net_trans.index.to_list()
            df_net_trans = melt(df_net_trans.reset_index(), id_vars='index', value_vars=l_target_trans)
            df_net_trans.columns = ['REGULATOR', 'TARGET', 'VALUE']
            df_net_trans.VALUE = df_net_trans.VALUE.abs()
            df_net_trans = df_net_trans.loc[df_net_trans.VALUE > 0, :]
            df_net_trans = df_net_trans.sort_values(ascending=False, by='VALUE')
            # reference network
            df_net_ref = read_csv(p_net_lasso_ref, header=0, index_col=0, sep='\t')
            l_target = df_net_ref.columns.to_list()
            df_net_ref = melt(df_net_ref.reset_index(), id_vars='index', value_vars=l_target)
            df_net_ref.columns = ['REGULATOR', 'TARGET', 'VALUE']
            df_net_ref.VALUE = df_net_ref.VALUE.abs()
            df_net_ref = df_net_ref.loc[df_net_ref.VALUE > 0, :]
            df_net_ref = df_net_ref.sort_values(ascending=False, by='VALUE')
            # calculate steps
            st = int(df_net_trans.shape[0]/nbr_bins)  # step size for translated network
            sr = int(df_net_ref.shape[0]/nbr_bins)  # step size for reference network

            df_net_norm = df_net_trans.copy()
            for i in range(nbr_bins):
                t_start, t_end = i*st, (i+1)*st  # start and end of bin in translated network
                r_start, r_end = i*sr, (i+1)*sr  # start and end of bin in reference network
                df_net_norm.iloc[t_start:t_end, 2] = df_net_norm.iloc[t_start:t_end, 2] - df_net_norm.iloc[t_end-1, 2]
                diff_step_ref = df_net_ref.iloc[r_start, 2]-df_net_ref.iloc[r_end-1, 2]
                df_net_norm.iloc[t_start:t_end, 2] = df_net_norm.iloc[t_start:t_end, 2]*diff_step_ref/df_net_norm.iloc[t_start, 2]
                df_net_norm.iloc[t_start:t_end, 2] = df_net_norm.iloc[t_start:t_end, 2] + df_net_ref.iloc[r_end-1, 2]
                if i == nbr_bins-1:  # the last bin is bigger than the step
                    t_start, t_end = i*st, df_net_norm.shape[0]  # start and end of bin in translated network
                    r_start, r_end = i*sr, df_net_ref.shape[0]  # start and end of bin in reference network
                    df_net_norm.iloc[t_start:t_end, 2] = df_net_norm.iloc[t_start:t_end, 2] - df_net_norm.iloc[t_end-1, 2]
                    diff_step_ref = df_net_ref.iloc[r_start, 2]-df_net_ref.iloc[r_end-1, 2]
                    df_net_norm.iloc[t_start:t_end, 2] = \
                                            df_net_norm.iloc[t_start:t_end,2]*diff_step_ref/df_net_norm.iloc[t_start,2]
                    df_net_norm.iloc[t_start:t_end, 2] = df_net_norm.iloc[t_start:t_end, 2] + df_net_ref.iloc[r_end-1, 2]

            # write the transformed network
            df_net = pivot_table(df_net_norm, index=['REGULATOR'], columns=['TARGET'], values='VALUE', fill_value=0)
            df_net = df_net.reindex(l_reg, axis='index', fill_value=0)
            df_net = df_net.reindex(l_target_trans, axis='columns', fill_value=0)
        else:
            print(method, ': this method is not considered')
            
        # write transformed networks
        if p_out_dir:
            df_net.to_csv(p_out_dir + 'net_' + net_name + '.tsv', header=True, index=True, sep='\t', index_label=False)
    return df_net
        

def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--p_net_lasso_ref', '-p_net_lasso_ref', default="NONE", nargs="?", help='path of LASSO network for ref')
    parser.add_argument('--p_net_de_ref', '-p_net_de_ref', default="NONE", nargs="?", help='path of DE network for ref')
    parser.add_argument('--p_net_bart_ref', '-p_net_bart_ref', default="NONE", nargs="?", help='path of BART network for ref')
    parser.add_argument('--p_net_pwm_ref', '-p_net_pwm_ref', default="NONE", nargs="?", help='path of PWM network for ref') 
    parser.add_argument('--p_net_lasso', '-p_net_lasso', default="NONE", nargs="?", help='path of LASSO network')
    parser.add_argument('--p_net_de', '-p_net_de', default="NONE", nargs="?", help='path of DE network')
    parser.add_argument('--p_net_bart', '-p_net_bart', default="NONE", nargs="?", help='path of BART network')
    parser.add_argument('--p_net_pwm', '-p_net_pwm', default="NONE", nargs="?", help='path of PWM network')
    parser.add_argument('--method', '-method', default='smallest', help='string for the method of transformation')
    parser.add_argument('--p_out_dir', '-p_out_dir', help='path of output directory for transformed source of information')
    
    args = parser.parse_args()
    
    normalize_source_of_information(p_net_lasso_ref=args.p_net_lasso_ref
                                    , p_net_de_ref=args.p_net_de_ref
                                    , p_net_bart_ref=args.p_net_bart_ref
                                    , p_net_pwm_ref=args.p_net_pwm_ref
                                    , p_net_lasso=args.p_net_lasso
                                    , p_net_de=args.p_net_de
                                    , p_net_bart=args.p_net_bart
                                    , p_net_pwm=args.p_net_pwm
                                    , method=args.method
                                    , p_out_dir=args.p_out_dir)

if __name__ == '__main__':
    main()
