# NetProphet 3.0
NetProphet3.0 is a package for network inference that leverage machine learning with XGboost. The easiest way to run this package is with **singularity container**. Once singularity is installed on your computer, there is no need to install any more packages. If you are more adventurous, you can install all NetProphet 3.0 dependencies, and still be able to run it.

# I. Install NetProphet 3.0

## The easiest, with Singularity container

Install Singularity & download s_np container developed by Brent Lab

- Refer to Singularity [website](https://singularity.hpcng.org/user-docs/3.6/quick_start.html#quick-installation-steps) and install singularity >=3.6.4
- load s_np container from sylab cloud with this command ``` singularity pull  ```

## More advanced, install all dependencies
Refer to wiki page to install depencies for NetProphet 3.0


# II. Run NetProphet 3.0

## The fastest, run toy example

## Learn more about NetProphet 3.0 options
- For Usage type ``` np3 -h ```
- Run NetProphet 3.0 in SLURM environment
- NetProphet 3.0 modes
    ** 10 fold of CV
    ** prebuilt model
    ** subset of TFs
