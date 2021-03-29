def split_networks_based_on_binding_support(l_in_name_net
                                            , l_in_path_net
                                            , p_in_net_binding
                                            , p_in_binding_event
                                            , p_out_dir
                                           ):
    from pandas import read_csv
    from os import mkdir, path
    
    df_binding_event = read_csv(p_in_binding_event, header=0, sep='\t')
    l_reg_binding_event = list(set(df_binding_event.REGULATOR.to_list()))
    
    l_in_name_net = l_in_name_net.split(',')
    l_in_path_net = l_in_path_net.split(',')
    
    # binding
    if p_in_net_binding != 'NONE':
        df_net_binding = read_csv(p_in_net_binding, header=None, sep='\t')
        df_net_binding.columns = ['REGULATOR', 'TARGET', 'VALUE']
        # support
        df_net_binding_support = df_net_binding[df_net_binding.REGULATOR.isin(l_reg_binding_event)]
        if df_net_binding_support.shape[0] > 0:
            if not path.exists(p_out_dir + 'supported'):
                mkdir(p_out_dir + 'supported')
            df_net_binding_support.to_csv(p_out_dir + 'supported/net_binding.tsv', header=False, index=False, sep='\t')
        # unsupport
        df_net_binding_unsupport = df_net_binding[~df_net_binding.REGULATOR.isin(l_reg_binding_event)]
        if df_net_binding_unsupport.shape[0] > 0:
            if not path.exists(p_out_dir + 'unsupported'):
                mkdir(p_out_dir + 'unsupported')
            df_net_binding_unsupport.to_csv(p_out_dir + 'unsupported/net_binding.tsv', header=False, index=False, sep='\t')
    # other nets        
    for n, p in zip(l_in_name_net, l_in_path_net):
        df_net = read_csv(p, header=None, sep='\t')
        df_net.columns = ['REGULATOR', 'TARGET', 'VALUE']
        # support
        df_net_support = df_net[df_net.REGULATOR.isin(l_reg_binding_event)]
        if df_net_support.shape[0] > 0:
            if not path.exists(p_out_dir + 'supported'):
                mkdir(p_out_dir + 'supported')
            df_net_support.to_csv(p_out_dir + 'supported/net_' + n + '.tsv', header=False, index=False, sep='\t')
        # unsupport
        df_net_unsupport = df_net[~df_net.REGULATOR.isin(l_reg_binding_event)]
        if df_net_unsupport.shape[0] > 0:
            if not path.exists(p_out_dir + 'unsupported'):
                mkdir(p_out_dir + 'unsupported')
            df_net_unsupport.to_csv(p_out_dir + 'unsupported/net_'+ n +'.tsv', header=False, index=False, sep='\t')
            
    
def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--l_in_name_net')
    parser.add_argument('--l_in_path_net')
    parser.add_argument('--p_in_net_binding', '-p_in_net_binding', nargs='?', default='NONE', help='path of BINDING network')
    parser.add_argument('--p_in_binding_event', '-p_in_binding_event', help='path of file for binding event')
    parser.add_argument('--p_out_dir', '-p_out_dir', help='path of output directory')
    
    args = parser.parse_args()
    
    split_networks_based_on_binding_support(l_in_name_net=args.l_in_name_net
                                            , l_in_path_net=args.l_in_path_net
                                            , p_in_net_binding=args.p_in_net_binding
                                            , p_in_binding_event=args.p_in_binding_event
                                            , p_out_dir=args.p_out_dir
                                           )

if __name__ == '__main__':
    main()