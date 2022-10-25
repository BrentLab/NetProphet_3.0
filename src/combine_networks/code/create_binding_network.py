def create_binding_network(p_in_binding_event
                           , p_in_reg
                           , p_in_target
                           , p_out_net_binding
                          ):
    """
    create a binding network: a matrix regulators X targets. This network includes all regulators
    in the network even if they do not exist in the file p_in_binding_event file
    p_in_binding_event: a file for positive binding event | REGULATOR | TARGET |
    """
    from pandas import DataFrame, read_csv
    import numpy as np
    
    df_in_pos_event = read_csv(p_in_binding_event, header=0, sep='\t')
        
    l_reg = list(read_csv(p_in_reg, header=None)[0])
    l_target = list(read_csv(p_in_target, header=None)[0])
    df_net = DataFrame(int(0), index=np.arange(len(l_reg)), columns=np.arange(len(l_target)))
    
    df_net.index = l_reg
    df_net.columns = l_target
     
    for reg, target in zip(df_in_pos_event.REGULATOR, df_in_pos_event.TARGET):
        if (reg in df_net.index) and (target in df_net.columns):
            df_net.loc[reg, target] = int(1)
            
    if p_out_net_binding:
        df_net.to_csv(p_out_net_binding, header=True, index=True, sep='\t')

    return df_net 

if __name__ == '__main__':
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--p_in_binding_event', '-p_in_binding_event', help='path of file for binding events')
    parser.add_argument('--p_in_reg', '-p_in_reg', help='path of file for list of regulators')
    parser.add_argument('--p_in_target', '-p_in_target', help='path of file for list of target genes')
    parser.add_argument('--p_out_net_binding', '-p_out_net_binding', nargs='?', default=None, help='path of file for output network')
    
    args = parser.parse_args()
    
    create_binding_network(p_in_binding_event=args.p_in_binding_event
                           , p_in_reg=args.p_in_reg
                           , p_in_target=args.p_in_target
                           , p_out_net_binding=args.p_out_net_binding
                          )
    