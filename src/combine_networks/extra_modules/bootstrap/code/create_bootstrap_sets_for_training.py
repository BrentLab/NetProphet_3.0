def write_training_for_cv_folds(p_in_dir
                                    , s
                                    , i):
    from random import choices, seed
    from pandas import read_csv
    from os import path, listdir
    
    """
    p_in_dir: path of input directory
    s: for bootstrap index
    i: for fold index of CV
    """
    for file in listdir(p_in_dir+'tmp_combine/network_construction/supported/data_cv/'):
        if path.isfile(p_in_dir+'tmp_combine/network_construction/supported/data_cv/'+file) \
        and file.startswith('fold' +str(i)+'_train') and file.endswith('.tsv'):
            df_net = read_csv(p_in_dir + 'tmp_combine/network_construction/supported/data_cv/' + file
                              , header=None, sep='\t')
            seed((s+1)*(i+1))
            l_bootstrapped_idx = choices([i for i in range(df_net.shape[0])], k=df_net.shape[0])
            df_net.iloc[l_bootstrapped_idx, :].to_csv(
                p_in_dir + 'tmp_combine/network_construction/bootstrap/'+str(s)+'/supported/data_cv/' + file
                , header=False, index=False, sep='\t')
            
            
def bootstrap_training_set(p_in_dir
                          , nbr_bootstrap
                          , nbr_cv_fold
                          , flag_training
                          ):
    """
    parse p_in_dir, the directory for network construction
    parse support and unsupport directories for bootstrapping 
    the training data in each of these directories
    """
    
    from os import path, makedirs, listdir
    from random import choices, seed
    from pandas import read_csv
    import multiprocessing as mp
    
    if not path.exists(p_in_dir + 'tmp_combine/network_construction/bootstrap/'):
        makedirs(p_in_dir + 'tmp_combine/network_construction/bootstrap/')
    pool = mp.Pool(min(mp.cpu_count(), 4))
    for s in range(nbr_bootstrap):
        if not path.exists(p_in_dir + 'tmp_combine/network_construction/bootstrap/' + str(s) + '/'):
            makedirs(p_in_dir + 'tmp_combine/network_construction/bootstrap/' + str(s) + '/')
        if flag_training == 'ON-CV':
            # support
            if not path.exists(p_in_dir + 'tmp_combine/network_construction/bootstrap/' + str(s) + '/supported/data_cv/'):
                makedirs(p_in_dir + 'tmp_combine/network_construction/bootstrap/' + str(s) + '/supported/data_cv/')
            pool.starmap(write_training_for_cv_folds, [(p_in_dir, s, i) for i in range(nbr_cv_fold)])
            
            # unsupport
            if not path.exists(p_in_dir + 'tmp_combine/network_construction/bootstrap/' + str(s) + '/unsupported/'):
                makedirs(p_in_dir + 'tmp_combine/network_construction/bootstrap/' + str(s) + '/unsupported/')
            for file in listdir(p_in_dir+'tmp_combine/network_construction/supported/'):
                if path.isfile(p_in_dir+'tmp_combine/network_construction/supported/'+file) \
                and file.startswith('net_') and file.endswith('.tsv'):
                    df_net = read_csv(p_in_dir+'tmp_combine/network_construction/supported/'+file, header=None, sep='\t')
                    seed(s)
                    l_bootstrapped_idx = choices([i for i in range(df_net.shape[0])], k=df_net.shape[0])
                    df_net.iloc[l_bootstrapped_idx,:].to_csv(
                        p_in_dir+'tmp_combine/network_construction/bootstrap/' + str(s) + '/unsupported/' + file
                            , header=False, index=False, sep='\t')
        elif flag_training == "ON-SUB":
            pass                                            
    
    pool.close()
    pool.join()                                            
    
def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    
    parser.add_argument('--p_in_dir', '-p_in_dir', help='path of directory for network construction')
    parser.add_argument('--nbr_bootstrap', '-nbr_nbr_bootstrap', type=int, nargs='?', default=20, help='number samples for bootstrapping')
    parser.add_argument('--nbr_cv_fold', '-nbr_cv_fold', type=int, nargs='?', default=10, help='number of CV folds')
    parser.add_argument('--flag_training', '-flag_training', help='ON-CV or ON-SUB')                                       
                                        
    
    args = parser.parse_args()
    
    bootstrap_training_set(p_in_dir=args.p_in_dir
                          , nbr_bootstrap=args.nbr_bootstrap
                          , nbr_cv_fold=args.nbr_cv_fold
                          , flag_training=args.flag_training)
    
if __name__ == "__main__":
    main()