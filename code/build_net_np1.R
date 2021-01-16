combine_lasso_de = function(p_in_net_lasso
                            , p_in_net_de
                            , p_out_net_np1
                           ){
    # source("/scratch/mblab/dabid/netprophet/code_netprophet3.0/code/netprophet1/modelaverage.r")
    # p_in_net_lasso = "/scratch/mblab/dabid/netprophet/net_out/kem_netprophet2.1_tf313_target6112_old/net/lasso.adjmtr"
    # p_in_net_de = "/scratch/mblab/dabid/netprophet/net_in/all_kem_de_logfc_262_6112"
    # read input
    df_net_lasso = read.csv(p_in_net_lasso, header=TRUE, row.names=1, sep="\t")
    df_net_de = read.csv(p_in_net_de, header=TRUE, row.names=1, sep="\t")
    # process input
    l_target = as.factor(colnames(df_net_lasso))
    l_reg = as.factor(rownames(df_net_lasso))
    
    # pad de with 0s if necessary
    if (dim(df_net_lasso)[1] > dim(df_net_de)[1]){
        df_net_de = df_net_lasso[match(l_reg, rownames(df_net_de)), ]
        df_net_de[is.na(df_net_de)] = 0
    }
    
    m_net_lasso = as.matrix(df_net_lasso)
    m_net_de = as.matrix(df_net_de)
    # normalize lasso
    m_net_lasso = m_net_lasso / max(abs(m_net_lasso))
    
    # normalize de
    idx = which(m_net_de>0)
    m_net_de[idx] = m_net_de[idx] - min(abs(m_net_de[idx]))
    idx = which(m_net_de<0)
    m_net_de[idx] = m_net_de[idx] + min(abs(m_net_de[idx]))
    
    
      
    df_net_np1 = compute.model.average.new(m_net_lasso
                                           , m_net_de
                                           , c(3,1,1,1,1,2,0.1,0.01)
                                          )
    write.table(df_net_np1
                , file=p_out_net_np1
                , row.names=l_reg
                , col.names=l_target
                , quote=FALSE
                , sep="\t"
               )
    
}

if (sys.nframe() == 0){
    if (!require(optparse)){
        install.packages("optparse", repo="http://cran.rstudio.com/")
        library("optparse")
    }
    
    p_in_net_lasso = make_option(c("--p_in_net_lasso"), type="character", help="path of lasso network")
    p_in_net_de = make_option(c("--p_in_net_de"), type="character", help="path of de network")
    p_out_net_np1 = make_option(c("--p_out_net_np1"), type="character", help="path  of netprophet1 network")
    p_src_code = make_option(c("--p_src_code"), type="character", help="path of code source")
    
    opt_parser = OptionParser(option_list=list(p_in_net_lasso, p_in_net_de, p_out_net_np1, p_src_code))
    opt = parse_args(opt_parser)
    source(paste(opt$p_src_code, "code/netprophet1/modelaverage.r", sep=""))
    combine_lasso_de(p_in_net_lasso=opt$p_in_net_lasso
                     , p_in_net_de=opt$p_in_net_de
                     , p_out_net_np1=opt$p_out_net_np1
                    )
}