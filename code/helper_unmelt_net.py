def unmelt_net(p_in_net
               , p_in_reg
               , p_in_target
               , p_out_net
              ):
    from pandas import pivot_table, read_csv
    
    # read input networks
    df_in_net = read_csv(p_in_net, header=None, sep='\t')
    df_in_net.columns = ['REGULATOR', 'TARGET', 'VALUE']
    
    # unmelt input network
    df_out_net = pivot_table(df_in_net
                             , index=['REGULATOR']
                             , columns=['TARGET']
                             , values='VALUE'
                             , fill_value=0
                            )
    l_in_reg = list(read_csv(p_in_reg, header=None)[0])
    l_in_target = list(read_csv(p_in_target, header=None)[0])
    df_out_net = df_out_net.reindex(l_in_reg, axis='index', fill_value=0)
    df_out_net = df_out_net.reindex(l_in_target, axis='columns', fill_value=0)
    
    # write output network
    df_out_net.to_csv(p_out_net, header=False, index=False, sep='\t')
    
    return df_out_net

def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--p_in_net', '-p_in_net', help='path of input network')
    parser.add_argument('--p_in_reg', '-p_in_reg', help='path for list of regulators')
    parser.add_argument('--p_in_target', '-p_in_target', help='path for list of targets')
    parser.add_argument('--p_out_net', '-p_out_net', help='path of output network')
    
    args = parser.parse_args()
    
    unmelt_net(p_in_net=args.p_in_net
               , p_in_reg=args.p_in_reg
               , p_in_target=args.p_in_target
               , p_out_net=args.p_out_net
              )

if __name__ == "__main__":
    main()