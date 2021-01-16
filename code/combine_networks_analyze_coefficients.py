def analyze_coefficients(p_in_dir):
    d_coef__l_value, d_coef__l_sif = {}, {}
    for i in range(10):
        p_model_summary = p_in_dir + 'fold' + str(i) + '_model_summary'
        flag_start, flag_end = False, False
        with open(p_model_summary, 'r') as f:
            for line in f:
                if line.startswith('Coefficients'):
                    flag_start = True
                elif line.startswith('--'):
                    flag_end = True
                    flag_start = False
                elif flag_start:
                    l_str = line.split()
                    if len(l_str) == 6:
                        sif_idx = 5
                    elif len(l_str) == 7:
                        sif_idx = 6
                    elif len(l_str) <= 5:
                        sif_idx = 5
                    
                    else:
                        print('there are more columns in the summary than considered..')
                        print(p_model_summary)
                        print(line)
                        continue
                    if l_str[0] != 'Estimate':
                        if l_str[0] in d_coef__l_value.keys():
                            try:
                                d_coef__l_value[l_str[0]].append(float(l_str[1]))
                                if '*' in l_str[sif_idx]:
                                    d_coef__l_sif[l_str[0]].append(1)
                                else:
                                    d_coef__l_sif[l_str[0]].append(0)
                            except ValueError as err:
                                continue
                            except IndexError as index_err:
                                d_coef__l_sif[l_str[0]].append(0)
                                continue
                        else:
                            try:
                                d_coef__l_value[l_str[0]] = [float(l_str[1])]
                                if '*' in l_str[sif_idx]:
                                    d_coef__l_sif[l_str[0]] = [1]
                                else:
                                    d_coef__l_sif[l_str[0]] = [0]
                            except ValueError as err:
                                continue
                            except IndexError as index_err:
                                d_coef__l_sif[l_str[0]] = [0]
                                continue
                elif flag_end:
                    break
    
    from pandas import DataFrame
    from statistics import mean, median
    d_coef__l_stat = {}
    for coef, l_sif in d_coef__l_sif.items():
        d_coef__l_stat[coef] = [sum(l_sif)* 100/len(l_sif)]
    for coef, l_value in d_coef__l_value.items():
        d_coef__l_stat[coef] += [mean(l_value), median(l_value)
                                 , max(l_value), min(l_value)]
        
    return DataFrame(d_coef__l_stat, index=['per_sif', 'mean', 'median', 'max', 'min']).T


def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--l_p_in_dir', '-l_p_in_dir', nargs='+', help='list of input directory of the summary models (10-fold CV)')
    parser.add_argument('--l_p_out_file', '-l_p_out_file', nargs='+', help='list of output files for coefficient analysis')
    
    args = parser.parse_args()
    
    l_p_in_dir = args.l_p_in_dir
    l_p_out_file = args.l_p_out_file
    
    for p_in_dir, p_out_file in zip(l_p_in_dir, l_p_out_file):
        df_analyze = analyze_coefficients(p_in_dir)
        df_analyze.to_csv(p_out_file, header=None, index=True, sep='\t')

if __name__ == "__main__":
    main()