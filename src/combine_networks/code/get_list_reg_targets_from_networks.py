def get_list_reg_target_from_networks(l_in_path_net
                                     , p_out_reg
                                     , p_out_target):
    from pandas import read_csv, Series
    
    l_path_net = l_in_path_net.split(',')
    for path in l_path_net:
        df = read_csv(path, header=0, index_col=0, sep='\t')
        l_reg = list(df.index)
        l_target = list(df.columns)
        Series(l_reg, name='reg').to_csv(p_out_reg, header=False, index=False)
        Series(l_target, name='target').to_csv(p_out_target, header=False, index=False)
        break
        
def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--l_in_path_net', '-l_in_path_net')
    parser.add_argument('--p_out_reg', '-p_out_reg')
    parser.add_argument('--p_out_target', '-p_out_target')
    
    args = parser.parse_args()
    
    get_list_reg_target_from_networks(l_in_path_net=args.l_in_path_net
                                     , p_out_reg=args.p_out_reg
                                     , p_out_target=args.p_out_target)
if __name__ == "__main__":
    main()