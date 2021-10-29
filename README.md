# NetProphet 3.0
NetProphet3.0 is network inference package, based on two main components: 1) generates different networks by regression algorithms (LASSO and BART), and other algorithms (PWM), 2) combines these generated intermediate networks in a final potential better network. The easiest way to run this package is with **singularity container**. Once singularity is installed on your computer, you can load the below container and start running NetProphet3.0. You can also install all dependencies, then run NetProphet 3.0, but it is more tedious.

# I. Install NetProphet 3.0

## The easiest, with Singularity container

- Refer to Singularity [website](https://singularity.hpcng.org/user-docs/3.6/quick_start.html#quick-installation-steps) and install singularity >=3.6.4
- load s_np container from sylab cloud with this command
   ``` 
   singularity pull library://dabid/default/s_np:sha256.2c48c295ab321b5fc6c79132934aef7f5a317beb46698ad879fd45bb2440c344 
   ```
- rename the container with a shorted file name, so it is easier to use. 
   ``` 
   mv s_np_sha256.2c48c295ab321b5fc6c79132934aef7f5a317beb46698ad879fd45bb2440c344.sif s_np 
   ```

## More advanced, install all dependencies
Refer to this wiki [page](https://github.com/BrentLab/NetProphet_3.0/wiki/Advanced-Installation) for installing NetProphet dependencies


# II. Run NetProphet 3.0
Clone NetProphet3.0 in your home directory or any other path in your computer

## With a toy example
This NetProphet3.0 command assumes that singularity container will be used. If not, have ``` --flag_singularity OFF ```.  
```
code_path=/path/of/NetProphet3.0/code/
p_out_dir=/path/of/output/directory/
p_singularity_img=/path/of/singularity/container/
p_singularity_bindpath=/path/of/link/path  # see below section for more info

${code_path}np3 -a \
    --p_in_expr_target ${code_path}toy_example/zev_expr_500_100_indexed \
    --p_in_expr_reg ${code_path}toy_example/zev_expr_reg_50_100_indexed \
    --p_in_promoter ${code_path}toy_example/promoter.scer.fasta \
    --flag_training OFF \
    --p_in_model ${code_path}model/kem_model.RData \
    --p_out_dir ${p_out_dir} \
    --flag_singularity ON \
    --p_singularity_img ${p_singularity_img} \
    --p_singularity_bindpath ${p_singularity_bindpath} \
```
## More about np3 command and options
- Usage: 
```
./${p_src_code}np3 -h 
```
- [NetProphet with SLURM environment](https://github.com/BrentLab/NetProphet_3.0/wiki/NetProphet-with-SLURM-environment)
- [NetProphet with Singularity](https://github.com/BrentLab/NetProphet_3.0/wiki/NetProphet-with-Singularity)
- [Run Individual components of NetProphet](https://github.com/BrentLab/NetProphet_3.0/wiki/_new?wiki%5Bname%5D=_Footer)
- NetProphet has three modes
   - Train with 10-CV
   - Train with small subset of TFs
   - No Training, use pre-built model
