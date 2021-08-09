# NetProphet 3.0
NetProphet3.0 is for network inference, it leverages machine learning to optimize for that. 
The easiest way to run this package is with **singularity container**. Once singularity is installed on your computer, you can load NetProphet 3.0 container and immediately start running this package. If you are more adventurous, you can install all dependencies, and still be able to run NetProphet 3.0. All instructions are below.

# I. Install NetProphet 3.0

## The easiest, with Singularity container

- Refer to Singularity [website](https://singularity.hpcng.org/user-docs/3.6/quick_start.html#quick-installation-steps) and install singularity >=3.6.4
- load s_np container from sylab cloud with this command ``` singularity pull library://dabid/default/s_np:sha256.2c48c295ab321b5fc6c79132934aef7f5a317beb46698ad879fd45bb2440c344 ```

## More advanced, install all dependencies
Refer to wiki page to install depencies for NetProphet 3.0


# II. Run NetProphet 3.0

## Run with a toy example

## Learn more about NetProphet 3.0 options
- For Usage type ``` np3 -h ```
- Run NetProphet 3.0 in SLURM environment
- NetProphet 3.0 modes
    ** 10 fold of CV
    ** prebuilt model
    ** subset of TFs
