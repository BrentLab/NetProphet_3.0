#!/bin/bash


# ============================================================== #
# |             *********************************              | #
# |             *** Run & Evaluate Netprophet ***              | #
# |             *********************************              | #
# ============================================================== #

# ------------------------------------------------------ #
# |          *** Prepare Data for NetProphet ***       | #
# ------------------------------------------------------ #

# load modules
module load anaconda3/4.1.1
source activate netprophet

# run prepare data
python /scratch/mblab/dabid/netprophet/code_NetProphet_2.0/CODE/prepare_resources.py \
-g /scratch/mblab/dabid/netprophet/code_NetProphet_2.0/RESOURCES/genes \
-r /scratch/mblab/dabid/netprophet/code_NetProphet_2.0/RESOURCES/regulators \
-e /scratch/mblab/dabid/netprophet/code_NetProphet_2.0/RESOURCES/data.expr \
-c /scratch/mblab/dabid/netprophet/code_NetProphet_2.0/RESOURCES/conditions \
-or /scratch/mblab/dabid/netprophet/test_data/tmp/rdata.expr \
-of /scratch/mblab/dabid/netprophet/test_data/tmp/data.fc.tsv \
-oa /scratch/mblab/dabid/netprophet/test_data/tmp/allowed.adj \
-op1 /scratch/mblab/dabid/netprophet/test_data/tmp/data.pert.adj \
-op2 /scratch/mblab/dabid/netprophet/test_data/tmp/data.pert.tsv

# ------------------------------------------------------ #
# |                *** Run NetProphet ***              | #
# ------------------------------------------------------ #
# load modules
module load R/3.2.1
module load openmpi/1.8.3

# set the working directory
pushd /scratch/mblab/dabid/netprophet/code_NetProphet_2.0

# submit netprophet job
j_run_net=$(/scratch/mblab/dabid/netprophet/code_NetProphet_2.0/SRC/NetProphet1/netprophet \
-m -c \
-u /scratch/mblab/dabid/netprophet/code_NetProphet_2.0/SRC/NetProphet1 \
-t /scratch/mblab/dabid/netprophet/code_NetProphet_2.0/RESOURCES/data.expr \
-d /scratch/mblab/dabid/netprophet/code_NetProphet_2.0/run_tfa/expr_zev_15_de.shrunken.adj \
-a /scratch/mblab/dabid/netprophet/test_data/tmp/allowed.adj \
-p /scratch/mblab/dabid/netprophet/test_data/tmp/data.pert.adj \
-g /scratch/mblab/dabid/netprophet/code_NetProphet_2.0/RESOURCES/genes \
-f /scratch/mblab/dabid/netprophet/code_NetProphet_2.0/RESOURCES/regulators \
-r /scratch/mblab/dabid/netprophet/test_data/tmp/rdata.expr \
-o /scratch/mblab/dabid/netprophet/test_data/net \
-n /scratch/mblab/dabid/netprophet/test_data/net/test \
-e /scratch/mblab/dabid/netprophet/test_logs/test \
-j test)

# get job id for netprophet job
jid_run_net=$(echo $j_run_net | awk '{split($0, a, " "); print a[4]}')

# ------------------------------------------------------ #
# |             *** Evaluate NetProphet ***            | #
# ------------------------------------------------------ #

# set working directotry
pushd /scratch/mblab/dabid/netprophet/code_TF_Network_Evaluation/scripts/

# create the directory when evaluation will be saved
mkdir -p /scratch/mblab/dabid/netprophet/test_data/ChIP

# submit a job for netprophet evaluation
j_run_eval=$(sbatch --mail-type=FAIL,END --mail-user=dabid@wustl.edu \
-J test \
-o ../../test_logs/test_eval.out -e ../../test_logs/test_eval.err \
--dependency=afterany:$jid_run_net \
evaluate_network_w_nonbinary_benchmark.sh \
/scratch/mblab/dabid/netprophet/test_data/net/test \
/scratch/mblab/dabid/netprophet/code_NetProphet_2.0/RESOURCES/regulators \
/scratch/mblab/dabid/netprophet/code_NetProphet_2.0/RESOURCES/genes \
15.9 20 \
/scratch/mblab/dabid/netprophet/test_data/ChIP)                                                             
