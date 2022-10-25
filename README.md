# NetProphet 3.0
NetProphet3.0 is network inference package, first it generates different networks by regression algorithms (LASSO and BART), and other algorithms (PWM). Then, it combines these networks in one final network. The easiest way to run NetProphet3 is with **singularity container**. After installing singularity, you load the container below and start running NetProphet3.0. The more advanced way is by installing all dependencies of NetProphet 3.0.

# I. Install NetProphet 3.0

## The easiest, with Singularity container

- Refer to Singularity [website](https://singularity.hpcng.org/user-docs/3.6/quick_start.html#quick-installation-steps) and install singularity >=3.5.2
- load s_np container from sylab cloud with this command
   ``` 
   singularity pull library://dabid/default/s_np3:sha256.cec2a1ebb7798992807bd48725ce172d8fa8fd580539c774ad4f478f109ae243
   ```
- rename the container with a shorted file name, so it is easier to use. 
   ``` 
   mv s_np3:sha256.cec2a1ebb7798992807bd48725ce172d8fa8fd580539c774ad4f478f109ae243.sif s_np3.sif 
   ```

## More advanced, install all dependencies
Refer to this wiki [page](https://github.com/BrentLab/NetProphet_3.0/wiki/Advanced-Installation) for installing NetProphet dependencies


# II. Run NetProphet 3.0
Clone NetProphet3.0 in a path in your computer and let's call that path ${p_src_code}

## With a toy example
This NetProphet3.0 command assumes that singularity container will be used and that's why ``` --flag_singularity ON ```.  
```
p_wd=/scratch/mblab/dabid/proj_net/
p_src_code=${p_wd}code/NetProphet_3.0/
p_out_dir=${p_wd}code/NetProphet_3.0/toy_example/res/

${p_src_code}np3 -c \
    --p_in_binding_event ${p_src_code}toy_example/data_binding_reg_target.tsv \
    --l_in_name_net "lasso,de,bart,pwm" \
    --l_in_path_net "${p_out_dir}features/net_lasso.tsv,${p_src_code}toy_example/data_zev_de_shrunken_50_500_indexed,${p_out_dir}features/net_bart.tsv,${p_out_dir}features/net_pwm.tsv" \
    --flag_training ON-CV \
    --combine_cv_nbr_fold 10 \
    --p_out_dir ${p_out_dir}10cv/ \
    --flag_singularity OFF \
    --flag_slurm ON \
    --p_out_dir_logs ${p_out_dir}log/ \
    --data toy_example_10cv \
```
## More about np3 command and options
- Usage: 
```
./${p_src_code}np3 -h 
```
- [NetProphet3.0 with SLURM environment](https://github.com/BrentLab/NetProphet_3.0/wiki/NetProphet-with-SLURM-environment)
- [NetProphet3.0 with Singularity](https://github.com/BrentLab/NetProphet_3.0/wiki/NetProphet-with-Singularity)
- NetProphet3.0 combination method
    - [Train with 10CV](https://github.com/BrentLab/NetProphet_3.0/wiki/10cv)
    - [Train for integration](https://github.com/BrentLab/NetProphet_3.0/wiki/integration)
    - [No Training, use a pre-built model (yeast)](https://github.com/BrentLab/NetProphet_3.0/wiki/yeast_model)
- NetProphet3.0 other modules
    - [LASSO](https://github.com/BrentLab/NetProphet_3.0/wiki/LASSO)
    - [BART](https://github.com/BrentLab/NetProphet_3.0/wiki/BART)
    - [PWM](https://github.com/BrentLab/NetProphet_3.0/wiki/PWM) 
