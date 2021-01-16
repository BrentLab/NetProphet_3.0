def reindex_network(p_in_net, p_in_reg, p_in_target, p_out_net):
    
    from pandas import read_csv
    
    l_reg = list(read_csv(p_in_reg, header=None)[0])
    l_target = list(read_csv(p_in_target, header=None)[0])
    df_net = read_csv(p_in_net, header=None, sep='\t')
    if df_net.shape[1] > len(l_target):
        df_net = df_net.dropna(axis='columns')
    df_net.index = l_reg
    df_net.columns = l_target
    df_net.to_csv(p_out_net, header=True, index=True, sep='\t')

def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--p_in_net', '-p_in_net', help='path of input network')
    parser.add_argument('--p_in_reg', '-p_in_reg', help='path of file for regulators')
    parser.add_argument('--p_in_target', '-p_in_target', help='path of file for targets')
    parser.add_argument('--p_out_net', '-p_out_net', help='path of output indexed network')
    
    args = parser.parse_args()
    
    reindex_network(p_in_net=args.p_in_net
                    , p_in_reg=args.p_in_reg
                    , p_in_target=args.p_in_target
                    , p_out_net=args.p_out_net
                   )

if __name__ == '__main__':
    main()