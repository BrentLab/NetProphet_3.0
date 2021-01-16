def split_networks_based_on_binding_support(p_net_lasso
                                            , p_net_de
                                            , p_net_bart
                                            , p_net_pwm
                                            , p_net_new
                                            , p_net_binding
                                            , p_binding_event
                                            , p_out_dir
                                           ):
    from pandas import read_csv
    from os import mkdir, path
    
    df_binding_event = read_csv(p_binding_event, header=0, sep='\t')
    l_reg_binding_event = list(set(df_binding_event.REGULATOR.to_list()))
    
    # LASSO
    if p_net_lasso != 'NONE':
        df_net_lasso = read_csv(p_net_lasso, header=None, sep='\t')
        df_net_lasso.columns = ['REGULATOR', 'TARGET', 'VALUE']
        # support
        df_net_lasso_support = df_net_lasso[df_net_lasso.REGULATOR.isin(l_reg_binding_event)]
        if df_net_lasso_support.shape[0] > 0:
            if not path.exists(p_out_dir + 'support'):
                mkdir(p_out_dir + 'support')
            df_net_lasso_support.to_csv(p_out_dir + 'support/net_lasso.tsv', header=False, index=False, sep='\t')
        # unsupport
        df_net_lasso_unsupport = df_net_lasso[~df_net_lasso.REGULATOR.isin(l_reg_binding_event)]
        if df_net_lasso_unsupport.shape[0] > 0:
            if not path.exists(p_out_dir + 'unsupport'):
                mkdir(p_out_dir + 'unsupport')
            df_net_lasso_unsupport.to_csv(p_out_dir + 'unsupport/net_lasso.tsv', header=False, index=False, sep='\t')
        
    # DE
    if p_net_de != 'NONE':
        df_net_de = read_csv(p_net_de, header=None, sep='\t')
        df_net_de.columns = ['REGULATOR', 'TARGET', 'VALUE']
        # support
        df_net_de_support = df_net_de[df_net_de.REGULATOR.isin(l_reg_binding_event)]
        if df_net_de_support.shape[0] > 0:
            if not path.exists(p_out_dir + 'support'):
                mkdir(p_out_dir + 'support')
            df_net_de_support.to_csv(p_out_dir + 'support/net_de.tsv', header=False, index=False, sep='\t')
        # unsupport
        df_net_de_unsupport = df_net_de[~df_net_de.REGULATOR.isin(l_reg_binding_event)]
        if df_net_de_unsupport.shape[0] > 0:
            if not path.exists(p_out_dir + 'unsupport'):
                mkdir(p_out_dir + 'unsupport/net_de.tsv')
            df_net_de_unsupport.to_csv(p_out_dir + 'unsupport/net_de.tsv', header=False, index=False, sep='\t')
            
    if p_net_bart != 'NONE':
        df_net_bart = read_csv(p_net_bart, header=None, sep='\t')
        df_net_bart.columns = ['REGULATOR', 'TARGET', 'VALUE']
        # support
        df_net_bart_support = df_net_bart[df_net_bart.REGULATOR.isin(l_reg_binding_event)]
        if df_net_bart_support.shape[0] > 0:
            if not path.exists(p_out_dir + 'support'):
                mkdir(p_out_dir + 'support')
            df_net_bart_support.to_csv(p_out_dir + 'support/net_bart.tsv', header=False, index=False, sep='\t')
        # unsupport
        df_net_bart_unsupport = df_net_bart[~df_net_bart.REGULATOR.isin(l_reg_binding_event)]
        if df_net_bart_unsupport.shape[0] > 0:
            if not path.exists(p_out_dir + 'unsupport'):
                mkdir(p_out_dir + 'unsupport')
            df_net_bart_unsupport.to_csv(p_out_dir + 'unsupport/net_bart.tsv', header=False, index=False, sep='\t')
    
    if p_net_pwm != 'NONE':
        df_net_pwm = read_csv(p_net_pwm, header=None, sep='\t')
        df_net_pwm.columns = ['REGULATOR', 'TARGET', 'VALUE']
        # support
        df_net_pwm_support = df_net_pwm[df_net_pwm.REGULATOR.isin(l_reg_binding_event)]
        if df_net_pwm_support.shape[0] > 0:
            if not path.exists(p_out_dir + 'support'):
                mkdir(p_out_dir + 'support')
            df_net_pwm_support.to_csv(p_out_dir + 'support/net_pwm.tsv', header=False, index=False, sep='\t')
        # unsupport
        df_net_pwm_unsupport = df_net_pwm[~df_net_pwm.REGULATOR.isin(l_reg_binding_event)]
        if df_net_pwm_unsupport.shape[0] > 0:
            if not path.exists(p_out_dir + 'unsupport'):
                mkdir(p_out_dir + 'unsupport')
            df_net_pwm_unsupport.to_csv(p_out_dir + 'unsupport/net_pwm.tsv', header=False, index=False, sep='\t')

    if p_net_new != 'NONE':
        df_net_new = read_csv(p_net_new, header=None, sep='\t')
        df_net_new.columns = ['REGULATOR', 'TARGET', 'VALUE']
        # support
        df_net_new_support = df_net_new[df_net_new.REGULATOR.isin(l_reg_binding_event)]
        if df_net_new_support.shape[0] > 0:
            if not path.exists(p_out_dir + 'support'):
                mkdir(p_out_dir + 'support')
            df_net_new_support.to_csv(p_out_dir + 'support/net_new.tsv', header=False, index=False, sep='\t')
        # unsupport
        df_net_new_unsupport = df_net_new[~df_net_new.REGULATOR.isin(l_reg_binding_event)]
        if df_net_new_unsupport.shape[0] > 0:
            if not path.exists(p_out_dir + 'unsupport'):
                mkdir(p_out_dir + 'unsupport')
            df_net_new_unsupport.to_csv(p_out_dir + 'unsupport/net_new.tsv', header=False, index=False, sep='\t')
            
    if p_net_binding != 'NONE':
        df_net_binding = read_csv(p_net_binding, header=None, sep='\t')
        df_net_binding.columns = ['REGULATOR', 'TARGET', 'VALUE']
        # support
        df_net_binding_support = df_net_binding[df_net_binding.REGULATOR.isin(l_reg_binding_event)]
        if df_net_binding_support.shape[0] > 0:
            if not path.exists(p_out_dir + 'support'):
                mkdir(p_out_dir + 'support')
            df_net_binding_support.to_csv(p_out_dir + 'support/net_binding.tsv', header=False, index=False, sep='\t')
        # unsupport
        df_net_binding_unsupport = df_net_binding[~df_net_binding.REGULATOR.isin(l_reg_binding_event)]
        if df_net_binding_unsupport.shape[0] > 0:
            if not path.exists(p_out_dir + 'unsupport'):
                mkdir(p_out_dir + 'unsupport')
            df_net_binding_unsupport.to_csv(p_out_dir + 'unsupport/net_binding.tsv', header=False, index=False, sep='\t')
def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--p_net_lasso', '-p_net_lasso', nargs='?', default='NONE', help='path of LASSO network')
    parser.add_argument('--p_net_de', '-p_net_de', nargs='?', default='NONE', help='path of DE network')
    parser.add_argument('--p_net_bart', '-p_net_bart', nargs='?', default='NONE', help='path of BART network')
    parser.add_argument('--p_net_pwm', '-p_net_pwm', nargs='?', default='NONE', help='path of PWM network')
    parser.add_argument('--p_net_new', '-p_net_new', nargs='?', default='NONE', help='path of new source of info network')
    parser.add_argument('--p_net_binding', '-p_net_binding', nargs='?', default='NONE', help='path of BINDING network')
    parser.add_argument('--p_binding_event', '-p_binding_event', help='path of file for binding event')
    parser.add_argument('--p_out_dir', '-p_out_dir', help='path of output directory')
    
    args = parser.parse_args()
    
    split_networks_based_on_binding_support(p_net_lasso=args.p_net_lasso
                                            , p_net_de=args.p_net_de
                                            , p_net_bart=args.p_net_bart
                                            , p_net_pwm=args.p_net_pwm
                                            , p_net_new=args.p_net_new
                                            , p_net_binding=args.p_net_binding
                                            , p_binding_event=args.p_binding_event
                                            , p_out_dir=args.p_out_dir
                                           )

if __name__ == '__main__':
    main()