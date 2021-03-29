def split_networks_based_on_perturbed_reg(l_in_name_net
                                          , l_in_path_net
                                          , p_in_net_binding
                                          , p_out_dir
                                         ):
    from pandas import read_csv, melt
    from os import mkdir, path
    
    l_in_name_net = l_in_name_net.split(',')
    l_in_path_net = l_in_path_net.split(',')
    
    p_net_de = [l_in_path_net[i] for i, net in enumerate(l_in_name_net) if net == 'de']
    if p_net_de:
        p_net_de = p_net_de[0]
        if not path.exists(p_out_dir + 'with_de/'):
            mkdir(p_out_dir + 'with_de/')
        df_net_de = read_csv(p_net_de, header=0, index_col=0, sep='\t')
        l_target = df_net_de.columns.to_list()
        l_reg_de = df_net_de.index.to_list()
        df_net_de_melt = melt(df_net_de.reset_index(), id_vars='index', value_vars=l_target)
        df_net_de_melt.to_csv(p_out_dir + 'with_de/net_de.tsv', header=False, index=False, sep='\t')
        
        # binding net
        if p_in_net_binding != 'NONE':
            df_net_binding = read_csv(p_in_net_binding, header=0, index_col=0, sep='\t')
            l_reg = df_net_binding.index.to_list()
            df_net_binding_with_de = df_net_binding[df_net_binding.index.isin(l_reg_de)]
            df_net_binding_with_de = df_net_binding_with_de.reindex(l_reg_de, axis='index')
            df_net_binding_with_de_melt = melt(df_net_binding_with_de.reset_index(), id_vars='index', value_vars=l_target)
            df_net_binding_with_de_melt.to_csv(p_out_dir + 'with_de/net_binding.tsv', header=False, index=False, sep='\t')
        
        # other net   
        for n, p in zip(l_in_name_net, l_in_path_net):
            df_net = read_csv(p, header=0, index_col=0, sep='\t')
            l_reg = df_net.index.to_list()
            df_net_with_de = df_net.loc[l_reg_de, :]
            df_net_with_de = df_net_with_de.reindex(l_reg_de, axis='index')
            df_net_with_de_melt = melt(df_net_with_de.reset_index(), id_vars='index', value_vars=l_target)
            df_net_with_de_melt.to_csv(p_out_dir + 'with_de/net_' + n + '.tsv', header=False, index=False, sep='\t') 
    
        if len(l_reg) > len(l_reg_de):
            l_reg_no_de = [i for i in l_reg if i not in l_reg_de]
            if not path.exists(p_out_dir + 'without_de/'):
                mkdir(p_out_dir + 'without_de/')
            # binding
            if p_in_net_binding != 'NONE':
                df_net_binding_without_de = df_net_binding.loc[l_reg_no_de, :]
                df_net_binding_without_de = df_net_binding.reindex(l_reg_no_de, axis='index')
                df_net_binding_without_de_melt = melt(df_net_binding_without_de.reset_index(), id_vars='index', value_vars=l_target)
                df_net_binding_without_de_melt.to_csv(p_out_dir + 'without_de/net_binding.tsv', header=False, index=False, sep='\t')
            for n, p in zip(l_in_name_net, l_in_path_net):
                df_net_without_de = df_net.loc[l_reg_no_de, :]
                df_net_without_de = df_net_without_de.reindex(l_reg_no_de, axis='index')
                df_net_without_de_melt = melt(df_net_without_de.reset_index(), id_vars='index', value_vars=l_target)
                df_net_without_de_melt.to_csv(p_out_dir + 'without_de/net_' + n + '.tsv', header=False, index=False, sep='\t')
    else:  # without perturbation
        mkdir(p_out_dir + 'without_de/')
        # binding
        if p_in_net_binding != 'NONE':
            df_net_binding = read_csv(p_in_net_binding, header=0, index_col=0, sep='\t')
            l_target = df_net_binding.columns.to_list()
            df_net_binding_melt = melt(df_net_binding.reset_index(), id_vars='index', value_vars=l_target)
            df_net_binding_melt.to_csv(p_out_dir + 'without_de/net_binding.tsv', header=False, index=False, sep='\t')
        
        for n, p in zip(l_in_name_net, l_in_path_net):
            df_net = read_csv(p, header=0, index_col=0, sep='\t')
            l_target = df_net.columns.to_list()
            df_net_melt = melt(df_net.reset_index(), id_vars='index', value_vars=l_target)
            df_net_melt.to_csv(p_out_dir + 'without_de/net_' + n + '.tsv', header=False, index=False, sep='\t')
    
def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--l_in_name_net')
    parser.add_argument('--l_in_path_net')
    parser.add_argument('--p_in_net_binding', '-p_in_net_binding', nargs='?', default='NONE', help='path of BINDING network')
    parser.add_argument('--p_out_dir', '-p_out_dir', help='path of output directory')
    
    args = parser.parse_args()
    
    split_networks_based_on_perturbed_reg(l_in_name_net=args.l_in_name_net
                                         , l_in_path_net=args.l_in_path_net
                                         , p_in_net_binding=args.p_in_net_binding
                                         , p_out_dir=args.p_out_dir
                                         )

if __name__ == '__main__':
    main()