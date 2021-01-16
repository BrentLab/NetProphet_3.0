def select_top_k_edges(p_rank_net
                       , l_net_name
                       , l_p_in_net
                       , l_out_net
                       , p_out_dir
                       , top
                       , p_reg=None
                       , p_target=None
                       , p_wd=''
                      ):
    """
    given a network (response) that will be used to sort the edges and select top k edges
    select these top k edges from all other networks in l_t_net_p. The top edges networks 
    will be written into tsv files (these are flatten networks | REGULATOR | TARGET | VALUE|)
    @param: p_net_respnse: the response network that will be used to sort the edges
    l_t_net_p: a list of tuples (network name, path of network)
    p_output: the output folder for the top k edges networks provided in l_t_net_p
    top_k: the number of top edges such 20,000
    """

    from helper import read_csv_indexed
    from pandas import melt, read_csv
    from json import load
 
    # read parameters from config file
    #d_config__values = load(open('/scratch/mblab/dabid/netprophet/net_config/run.conf', 'r'))
    #if not p_reg:
    #    p_reg = p_wd + d_config__values['p_reg']
    #if not p_target:
    #    p_target = p_wd + d_config__values['p_target']

    # extract list of reg and targets
    if p_target:
        l_target = list(read_csv(p_target, header=None)[0])
    if p_reg:
        l_reg = list(read_csv(p_reg, header=None)[0])

    # =============================================================== #
    # |        *** Read p_rank_net and select top edges ***         | #
    # =============================================================== #
    # read rank network (from which we extract the rank)
    df_rank_net = read_csv(p_rank_net, header=None, sep='\t')
    if len(df_rank_net.columns) > 3:  # the rank_net is matrix
        
        df_rank_net = read_csv_indexed(p_df=p_rank_net, p_index=p_reg, p_column=p_target)
        df_rank_net = melt(df_rank_net.reset_index(), id_vars='index', value_vars=l_target)
    # sort rank network and extract top edges
    df_rank_net.columns = ['REGULATOR', 'TARGET', 'VALUE']
    df_rank_net = df_rank_net.sort_values(ascending=False, by='VALUE')
    df_rank_net_top = df_rank_net.iloc[0:top, :]
    df_rank_net_top.index = [(reg, target) for reg, target in zip(df_rank_net_top.REGULATOR, df_rank_net_top.TARGET)]
    
    # ================================================================== #
    # |     *** Read the other networks and get the top k edges ***    | #
    # ================================================================== #

    d_net_name__df = {}
    for net_name, p_net, out_net in zip(l_net_name, l_p_in_net, l_out_net)  :
        if p_net == "NONE":  # if network path is an empty string, skip it.
            continue
        d_net_name__df[net_name] = read_csv(p_net, header=None, sep='\t')
        if len(list(d_net_name__df[net_name].columns)) > 3:
            # d_net_name__df[net_name] = read_csv_indexed(p_df=p_net, p_index=p_reg, p_column=p_target)
            d_net_name__df[net_name] = read_csv(p_df=p_net, header=0, index_col=0)
            d_net_name__df[net_name] = melt(d_net_name__df[net_name].reset_index(), id_vars='index', value_vars=l_target)
        d_net_name__df[net_name].columns = ['REGULATOR', 'TARGET', net_name]
        d_net_name__df[net_name].index = [(reg, target) for reg, target in zip(d_net_name__df[net_name].REGULATOR, d_net_name__df[net_name].TARGET)]
        d_net_name__df[net_name] = d_net_name__df[net_name][d_net_name__df[net_name].index.isin(df_rank_net_top.index)]
        d_net_name__df[net_name].reindex(df_rank_net_top.index, axis='index')
        # write the flatten top k networks
        import os
        if not os.path.exists(p_out_dir):
            os.mkdir(p_out_dir)
        d_net_name__df[net_name].to_csv(p_out_dir + out_net, header=False, index=False, sep='\t')
        

def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--p_in_top_net', '-p_in_top_net', help='The network that will be used to rank edges')
    parser.add_argument('--l_net_name', '-l_net_name', nargs='+', help='Networks names such as binding, lasso, and de')
    parser.add_argument('--l_p_in_net', '-l_p_in_net', nargs='+', help='Path of input networks binding, lasso, and de')
    parser.add_argument('--p_out_dir', '-p_out_dir', help='Path of output directory')
    parser.add_argument('--l_out_fname_net', '-l_out_fname_net', nargs='+', help='The path of output of top networks: binidng, lasso, and de')
    parser.add_argument('--top', '-top', type=int, help='top edges that will be selected from rank networks')
    parser.add_argument('--p_reg', '-p_reg', nargs='?', default=None, help='path of file for regulators of the orginal network, we need this argument only if the networks are matrices')
    parser.add_argument('--p_target', '-p_target', nargs='?', default=None, help='path of file for target genes of the original network, we need this argument only if the networks are matrices')
                            
    
    args = parser.parse_args()
    
    select_top_k_edges(p_rank_net=args.p_in_top_net
                       , l_net_name=args.l_net_name
                       , l_p_in_net=args.l_p_in_net
                       , p_out_dir=args.p_out_dir
                       , l_out_net=args.l_out_fname_net
                       , top=args.top
                       , p_reg=args.p_reg
                       , p_target=args.p_target
                      )


if __name__ == '__main__':
    main()
