def split_data(name_data
               , p_data
               , p_out_dir
               , nbr_row):
    from pandas import read_csv
    
    df_data = read_csv(p_data, header=0, index_col=0, sep='\t')
    
    for i in range(0, df_data.shape[0], nbr_row):
        df_data_sub = df_data.iloc[i:i+nbr_row, :]
        df_data_sub.to_csv(p_out_dir + name_data + '_' + str(i) + '.tsv', header=True, index=True, sep='\t')

def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--name_data', '-name_data', help='name of data or prefix of file of input data')
    parser.add_argument('--p_data', '-p_data', help='path of input data (matrix)')
    parser.add_argument('--p_out_dir', '-p_out_dir', help='path of output directory')
    parser.add_argument('--nbr_row', '-nbr_row', type=int, help='number')
    
    args = parser.parse_args()
    
    split_data(name_data=args.name_data
               , p_data=args.p_data
               , p_out_dir=args.p_out_dir
               , nbr_row=args.nbr_row)


if __name__ == '__main__':
    main()