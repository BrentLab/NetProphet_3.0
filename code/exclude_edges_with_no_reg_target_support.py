"""
This module take the list of binding events and a set of networks
such LASSO, DE, and BART, and exclude from them edges with regulators
and target that do not have any binding event
"""

def exclude_edges_with_no_reg_target_support(p_binding_event
                                             , l_net_name
                                             , l_p_net
                                             , p_target
                                             , p_reg
                                             , p_out_dir):
    from pandas import read_csv
    
    df_binding_event = read_csv(p_binding_event, header=0, sep='\t')
    l_binding_reg = list(set(list(df_binding_event.REGULATOR)))
    l_binding_target = list(set(list(df_binding_event.TARGET)))
    
    l_target = list(read_csv(p_target, header=None)[0])
    l_reg = list(read_csv(p_reg, header=None)[0])
    
    for name_net, p_net in zip(l_net_name, l_p_net):
        if p_net == "NONE":  # if the path of network is an empty string, skip it
            continue
        df_net = read_csv(p_net, header=None, sep='\t')
        if len(df_net.columns.to_list()) > len(l_target):
            df_net = df_net.dropna(axis='columns')
        df_net.index = l_reg
        df_net.columns = l_target
        if len(df_net.columns) > 3:
            from pandas import melt
            df_net = melt(df_net.reset_index(), id_vars='index', value_vars=l_target)
        df_net.columns = ['REGULATOR', 'TARGET', 'VALUE']
        df_net = df_net[df_net.REGULATOR.isin(l_binding_reg) & df_net.TARGET.isin(l_binding_target)]
        df_net.to_csv(p_out_dir + 'net_' + name_net + '.tsv', header=False, index=False, sep='\t')


def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--p_binding_event', '-p_binding_event', help='path of file of binding event |REGULATOR|TARGET|')
    parser.add_argument('--l_net_name', '-l_net_name', nargs='+', help='list of names for network to curate')
    parser.add_argument('--l_p_net', '-l_p_net', nargs='+', help='list of paths for networks to curate')
    parser.add_argument('--p_target', '-p_target', help='file of list of target genes')
    parser.add_argument('--p_reg', '-p_reg', help='file of list of regulators')
    parser.add_argument('--p_out_dir', '-p_out_dir', help='path of output directory for curated networks')
    
    args = parser.parse_args()
    
    exclude_edges_with_no_reg_target_support(p_binding_event=args.p_binding_event
                                             , l_net_name=args.l_net_name
                                             , l_p_net=args.l_p_net
                                             , p_target=args.p_target
                                             , p_reg=args.p_reg
                                             , p_out_dir=args.p_out_dir
                                            )
if __name__ == '__main__':
    main()