# NetProphet 3.0
NetProphet3.0 is a package for network inference: first, it generates intermediate networks by regression and other algorithms LASSO, DE, BART, PWM. Then, it combines them into one final network using XGboost, a supervised ML. The easiest way to run NetProphet3 is with the **singularity container**, as demonstrated below. Steps are easy: first install the singularity software, then pull the container, you will be ready to run NetProphet3. 

# I. Install NetProphet 3.0

## The easiest, with Singularity container

- Refer to Singularity [website](https://singularity.hpcng.org/user-docs/3.6/quick_start.html#quick-installation-steps) and install singularity >=3.5.2
- load the `s_np` container from the sylab cloud with this command
   ``` 
   singularity pull library://dabid/default/s_np3:sha256.e14c3a078c052932b5e2a840beea1fa5b8798db5668e196d8e297b223b6390d3
   ```
- rename the container with a shorted file name, so it is easier to use. 
   ``` 
   mv s_np3_sha256.e14c3a078c052932b5e2a840beea1fa5b8798db5668e196d8e297b223b6390d3.sif s_np3.sif
   ```

## The more advanced, here, all dependencies have to be installed
Refer to this wiki [page](https://github.com/BrentLab/NetProphet_3.0/wiki/Advanced-Installation) for installing NetProphet dependencies


# II. Run NetProphet 3.0
Clone NetProphet3.0 in a path in your computer, let's call that path ${p_src_code}

## With a toy example
This is an example of NetProphet3.0 combination command, it assumes that the singularity container will be used and that's why ``` --flag_singularity ON ```. Refer to the folder ${p_src_code}toy_example, for commands of each of the NetProphet3 modules; they can be run with and without singularity.  
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
    --flag_singularity ON \
    --p_singularity_img /path/singularity/image \
    --p_singularity_bindpath /your/home/dir/ \
    --flag_slurm OFF
```
## More about np3 command and options
- Help usage: ` ./${p_src_code}np3 -h`
- [NetProphet3.0: with SLURM environment](https://github.com/BrentLab/NetProphet_3.0/wiki/NetProphet-with-SLURM-environment)
- [NetProphet3.0: with Singularity](https://github.com/BrentLab/NetProphet_3.0/wiki/NetProphet-with-Singularity)
- NetProphet3.0: combination method
    - [Train for 10CV](https://github.com/BrentLab/NetProphet_3.0/wiki/10cv)
    - [Train for integration](https://github.com/BrentLab/NetProphet_3.0/wiki/integration)
    - [No Training, use a pre-built model (yeast)](https://github.com/BrentLab/NetProphet_3.0/wiki/prebuilt_yeast_model)
- NetProphet3.0: construction of intermediate networks
    - [LASSO](https://github.com/BrentLab/NetProphet_3.0/wiki/LASSO)
    - [BART](https://github.com/BrentLab/NetProphet_3.0/wiki/BART)
    - [PWM](https://github.com/BrentLab/NetProphet_3.0/wiki/PWM) 
