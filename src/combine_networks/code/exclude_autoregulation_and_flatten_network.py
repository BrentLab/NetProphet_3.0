def exclude_autoregulation_and_flatten_network(p_in_net_binding
                                               , l_in_name_net
                                               , l_in_path_net
                                               , p_out_dir
                                              ):
    from pandas import read_csv, melt
    
    l_in_name_net=l_in_name_net.split(',') + ['binding']
    l_in_path_net=l_in_path_net.split(',') + [p_in_net_binding]
    for name_net, path_net in zip(l_in_name_net, l_in_path_net):
        if path_net == 'NONE':
            continue
        df_net = read_csv(path_net, header=0, index_col=0, sep='\t')
        
        # flatten network
        df_net_melted = melt(df_net.reset_index(), id_vars='index', value_vars=df_net.columns)
        
        # exclude edges of autoregulation
        df_net_melted = df_net_melted.loc[df_net_melted.iloc[:, 0] != df_net_melted.iloc[:, 1], :]
        
        # write network
        df_net_melted.to_csv(p_out_dir + 'net_' + name_net + '.tsv', header=False, index=False, sep='\t')


def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    
    parser.add_argument('--p_in_net_binding', '-p_in_net_binding', help='path for binding path')
    parser.add_argument('--l_in_name_net', '-l_in_name_net', help='string of list of network names')
    parser.add_argument('--l_in_path_net', '-l_in_path_net', help='string of path of networks')
    parser.add_argument('--p_out_dir', '-p_out_dir', help='path of output directory')
    
    args = parser.parse_args()
    
    exclude_autoregulation_and_flatten_network(p_in_net_binding=args.p_in_net_binding
                                               , l_in_name_net=args.l_in_name_net
                                               , l_in_path_net=args.l_in_path_net
                                               , p_out_dir=args.p_out_dir
                                               )
    
if __name__ == '__main__':
    main()