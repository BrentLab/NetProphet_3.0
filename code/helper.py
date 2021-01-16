def read_csv_indexed(p_df, p_index=None, p_column=None, sep='\t'
                    , p_wd=''
                    ):
    """
    provide the file of DF and list of row and columns indexes
    an indexed DF is returned
    """
    from pandas import read_csv
    from json import load
    
    d_config__value = load(open('/scratch/mblab/dabid/netprophet/net_config/run.conf', 'r'))
    if not p_index:
        p_index = p_wd + d_config__value['p_reg']
    if not p_column:
        p_column = p_wd + d_config__value['p_target']
        
    df = read_csv(p_df, header=None, sep=sep)
    l_index = list(read_csv(p_index, header=None)[0])
    l_column = list(read_csv(p_column, header=None)[0])
    if len(df.columns.to_list()) >  len(l_index):
        df = df.dropna(axis='columns')
    df.index, df.columns = l_index, l_column
    return df


def melt_net(p_net, col3_name='VALUE', flag_abs=True):
    from pandas import melt
    
    df_net = read_csv_indexed(p_net)
    df_net_melt = melt(df_net.reset_index(), id_vars='index', value_vars=df_net.columns.to_list())
    df_net_melt.columns = ['REGULATOR', 'TARGET', col3_name]
    df_net_melt.index = [(reg, target) for reg, target in zip(df_net_melt.REGULATOR, df_net_melt.TARGET)]
    if flag_abs:
        df_net_melt[col3_name] = df_net_melt[col3_name].abs()
    df_net_melt = df_net_melt.sort_values(ascending=False, by=col3_name)
    return df_net_melt

   
def organize_model_summary(p_prefix, suffix="", seed_total=10):
    """
    input: provide a prefix of folder of 10cv 
    output: two dictionraries of coefficient estimate are returned
    one for the estimate and the other one is for significance
    """
    d_coef__l_value, d_coef__l_sign = {}, {}
    for seed in range(seed_total):
        for fold in range(10):
            p_model_summary = p_prefix + str(seed) + '/fold' + str(fold) + '_model_summary' + suffix
            flag_start, flag_end = False, False
            with open(p_model_summary, 'r') as f:
                for line in f:
                    if line.startswith('Coefficients'):
                        flag_start =True
                    elif line.startswith('--'):
                        flag_end = True
                    elif flag_start:
                        l_str = line.split()
                        if len(l_str) == 6:
                            sign_idx = 5
                        elif len(l_str) == 7:
                            sign_idx = 6
                        elif len(l_str) <= 5:
                            sign_idx = 5
                        else:
                            print('there are more columns in the model summary than considered in code')
                            print(p_model_summary)
                            print(line)
                            continue
                        if l_str[0] != 'Estimate':
                            if l_str[0] in d_coef__l_value.keys():
                                try:
                                    d_coef__l_value[l_str[0]].append(float(l_str[1]))
                                    if '*' in l_str[sign_idx]:
                                        d_coef__l_sign[l_str[0]].append(1)
                                    else:
                                        d_coef__l_sign[l_str[0]].append(0)
                                except ValueError as err:
                                    continue
                                except IndexError as index_err:
                                    d_coef__l_sign[l_str[0]].append(0)
                                    continue
                            else:
                                try:
                                    d_coef__l_value[l_str[0]] = [float(l_str[1])]
                                    if '*' in l_str[sign_idx]:
                                        d_coef__l_sign[l_str[0]] = [1]
                                    else:
                                        d_coef__l_sign[l_str[0]] = [0]
                                except ValueError as err:
                                    continue
                                except IndexError as index_err:
                                    d_coef__l_sign[l_str[0]] = [0]
                                    continue
                    if flag_end:
                        break
    return d_coef__l_value, d_coef__l_sign
