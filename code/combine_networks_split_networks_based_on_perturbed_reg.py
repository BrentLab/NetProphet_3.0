def split_networks_based_on_perturbed_reg(p_net_lasso
                                          , p_net_de
                                          , p_net_bart
                                          , p_net_pwm
                                          , p_net_new
                                          , p_net_binding
                                          , p_out_dir
                                         ):
    from pandas import read_csv, melt
    from os import mkdir, path
    
    if p_net_de != 'NONE':
        if not path.exists(p_out_dir + 'with_de/'):
            mkdir(p_out_dir + 'with_de/')
        df_net_de = read_csv(p_net_de, header=0, index_col=0, sep='\t')
        l_target = df_net_de.columns.to_list()
        l_reg_de = df_net_de.index.to_list()
        df_net_de_melt = melt(df_net_de.reset_index(), id_vars='index', value_vars=l_target)
        df_net_de_melt.to_csv(p_out_dir + 'with_de/net_de.tsv', header=False, index=False, sep='\t') 
        
        if p_net_lasso != 'NONE':
            df_net_lasso = read_csv(p_net_lasso, header=0, index_col=0, sep='\t')
            l_reg = df_net_lasso.index.to_list()
            df_net_lasso_with_de = df_net_lasso.loc[l_reg_de, :]
            df_net_lasso_with_de = df_net_lasso_with_de.reindex(l_reg_de, axis='index')
            df_net_lasso_with_de_melt = melt(df_net_lasso_with_de.reset_index(), id_vars='index', value_vars=l_target)
            df_net_lasso_with_de_melt.to_csv(p_out_dir + 'with_de/net_lasso.tsv', header=False, index=False, sep='\t')
        if p_net_bart != 'NONE':
            df_net_bart = read_csv(p_net_bart, header=0, index_col=0, sep='\t')
            l_reg = df_net_bart.index.to_list()
            df_net_bart_with_de = df_net_bart.loc[l_reg_de, :]
            df_net_bart_with_de = df_net_bart_with_de.reindex(l_reg_de, axis='index')
            df_net_bart_with_de_melt = melt(df_net_bart_with_de.reset_index(), id_vars='index', value_vars=l_target)
            df_net_bart_with_de_melt.to_csv(p_out_dir + 'with_de/net_bart.tsv', header=False, index=False, sep='\t')
        if p_net_pwm != 'NONE':
            df_net_pwm = read_csv(p_net_pwm, header=0, index_col=0, sep='\t')
            l_reg = df_net_pwm.index.to_list()
            df_net_pwm_with_de = df_net_pwm.loc[l_reg_de, :]
            df_net_pwm_with_de = df_net_pwm_with_de.reindex(l_reg_de, axis='index')
            df_net_pwm_with_de_melt = melt(df_net_pwm_with_de.reset_index(), id_vars='index', value_vars=l_target)
            df_net_pwm_with_de_melt.to_csv(p_out_dir + 'with_de/net_pwm.tsv', header=False, index=False, sep='\t')
        if p_net_new != 'NONE':
            df_net_new = read_csv(p_net_new, header=0, index_col=0, sep='\t')
            l_reg = df_net_new.index.to_list()
            df_net_new_with_de = df_net_new.loc[l_reg_de, :]
            df_net_new_with_de = df_net_new_with_de.reindex(l_reg_de, axis='index')
            df_net_new_with_de_melt = melt(df_net_new_with_de.reset_index(), id_vars='index', value_vars=l_target)
            df_net_new_with_de_melt.to_csv(p_out_dir + 'with_de/net_new.tsv', header=False, index=False, sep='\t')
        if p_net_binding != 'NONE':
            df_net_binding = read_csv(p_net_binding, header=0, index_col=0, sep='\t')
            l_reg = df_net_binding.index.to_list()
            df_net_binding_with_de = df_net_binding[df_net_binding.index.isin(l_reg_de)]
            df_net_binding_with_de = df_net_binding_with_de.reindex(l_reg_de, axis='index')
            df_net_binding_with_de_melt = melt(df_net_binding_with_de.reset_index(), id_vars='index', value_vars=l_target)
            df_net_binding_with_de_melt.to_csv(p_out_dir + 'with_de/net_binding.tsv', header=False, index=False, sep='\t')

        if len(l_reg) > len(l_reg_de):
            l_reg_no_de = [i for i in l_reg if i not in l_reg_de]
            if not path.exists(p_out_dir + 'without_de/'):
                mkdir(p_out_dir + 'without_de/')
            if p_net_lasso != 'NONE':
                df_net_lasso_without_de = df_net_lasso.loc[l_reg_no_de, :]
                df_net_lasso_without_de = df_net_lasso_without_de.reindex(l_reg_no_de, axis='index')
                df_net_lasso_without_de_melt = melt(df_net_lasso_without_de.reset_index(), id_vars='index', value_vars=l_target)
                df_net_lasso_without_de_melt.to_csv(p_out_dir + 'without_de/net_lasso.tsv', header=False, index=False, sep='\t')
            if p_net_bart != 'NONE':
                df_net_bart_without_de = df_net_bart.loc[l_reg_no_de, :]
                df_net_bart_without_de = df_net_bart_without_de.reindex(l_reg_no_de, axis='index')
                df_net_bart_without_de_melt = melt(df_net_bart_without_de.reset_index(), id_vars='index', value_vars=l_target)
                df_net_bart_without_de_melt.to_csv(p_out_dir + 'without_de/net_bart.tsv', header=False, index=False, sep='\t')
            if p_net_pwm != 'NONE':
                df_net_pwm_without_de = df_net_pwm.loc[l_reg_no_de, :]
                df_net_pwm_without_de = df_net_pwm_without_de.reindex(l_reg_no_de, axis='index')
                df_net_pwm_without_de_melt = melt(df_net_pwm_without_de.reset_index(), id_vars='index', value_vars=l_target)
                df_net_pwm_without_de_melt.to_csv(p_out_dir + 'without_de/net_pwm.tsv', header=False, index=False, sep='\t')
            if p_net_new != 'NONE':
                df_net_new_without_de = df_net_new.loc[l_reg_no_de, :]
                df_net_new_without_de = df_net_new_without_de.reindex(l_reg_no_de, axis='index')
                df_net_new_without_de_melt = melt(df_net_new_without_de.reset_index(), id_vars='index', value_vars=l_target)
                df_net_new_without_de_melt.to_csv(p_out_dir + 'without_de/net_new.tsv', header=False, index=False, sep='\t')
            if p_net_binding != 'NONE':
                df_net_binding_without_de = df_net_binding.loc[l_reg_no_de, :]
                df_net_binding_without_de = df_net_binding.reindex(l_reg_no_de, axis='index')
                df_net_binding_without_de_melt = melt(df_net_binding_without_de.reset_index(), id_vars='index', value_vars=l_target)
                df_net_binding_without_de_melt.to_csv(p_out_dir + 'without_de/net_binding.tsv', header=False, index=False, sep='\t')
    else:  # without perturbation
        mkdir(p_out_dir + 'without_de/')
        if p_net_lasso != 'NONE':
            df_net_lasso = read_csv(p_net_lasso, header=0, index_col=0, sep='\t')
            l_target = df_net_lasso.columns.to_list()
            df_net_lasso_melt = melt(df_net_lasso.reset_index(), id_vars='index', value_vars=l_target)
            df_net_lasso_melt.to_csv(p_out_dir + 'without_de/net_lasso.tsv', header=False, index=False, sep='\t')
        if p_net_bart != 'NONE':
            df_net_bart = read_csv(p_net_bart, header=0, index_col=0, sep='\t')
            l_target = df_net_bart.columns.to_list()
            df_net_bart_melt = melt(df_net_bart.reset_index(), id_vars='index', value_vars=l_target)
            df_net_bart_melt.to_csv(p_out_dir + 'without_de/net_bart.tsv', header=False, index=False, sep='\t')
        if p_net_pwm != 'NONE':
            df_net_pwm = read_csv(p_net_pwm, header=0, index_col=0, sep='\t')
            l_target = df_net_pwm.columns.to_list()
            df_net_pwm_melt = melt(df_net_pwm.reset_index(), id_vars='index', value_vars=l_target)
            df_net_pwm_melt.to_csv(p_out_dir + 'without_de/net_pwm.tsv', header=False, index=False, sep='\t')
        if p_net_binding != 'NONE':
            df_net_binding = read_csv(p_net_binding, header=0, index_col=0, sep='\t')
            l_target = df_net_binding.columns.to_list()
            df_net_binding_melt = melt(df_net_binding.reset_index(), id_vars='index', value_vars=l_target)
            df_net_binding_melt.to_csv(p_out_dir + 'without_de/net_binding.tsv', header=False, index=False, sep='\t')
    
def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--p_net_lasso', '--p_net_lasso', nargs='?', default='NONE', help='path of LASSO network')
    parser.add_argument('--p_net_de', '-p_net_de', nargs='?', default='NONE', help='path of DE network')
    parser.add_argument('--p_net_bart', '-p_net_bart', nargs='?', default='NONE', help='path of BART network')
    parser.add_argument('--p_net_pwm', '-p_net_pwm', nargs='?', default='NONE', help='path of PWM network')
    parser.add_argument('--p_net_new', '-p_net_new', nargs='?', default='NONE', help='path of new source of information network')
    parser.add_argument('--p_net_binding', '-p_net_binding', nargs='?', default='NONE', help='path of BINDING network')
    parser.add_argument('--p_out_dir', '-p_out_dir', help='path of output directory')
    
    args = parser.parse_args()
    
    split_networks_based_on_perturbed_reg(p_net_lasso=args.p_net_lasso
                                         , p_net_de=args.p_net_de
                                         , p_net_bart=args.p_net_bart
                                         , p_net_pwm=args.p_net_pwm
                                         , p_net_new=args.p_net_new
                                         , p_net_binding=args.p_net_binding
                                         , p_out_dir=args.p_out_dir
                                         )

if __name__ == '__main__':
    main()