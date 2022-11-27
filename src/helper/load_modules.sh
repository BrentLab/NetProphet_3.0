#!/bin/bash

# module load anaconda3/4.1.1
# module load r-legacy/3.4.3
# module load openmpi/1.8.8

eval $(/ref/mblab/software/spack-0.18.1/bin/spack load --sh r-rmpi@0.6-9.2 ^r@4.1.3 ^openmpi@4.1.3 schedulers=slurm legacylaunchers=true ^slurm@20-11-9-1 anaconda3)

