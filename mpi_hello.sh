#!/bin/sh
## a simple openmpi example
## submit with:
## $ qsub ~/mpi_hello.sh
# Export all environment variables
#$ -V
# Your job name
#$ -N mpi_hello
# Use current working directory
#$ -cwd
# Join stdout and stderr
#$ -j y
# PARALLEL ENVIRONMENT:
#$ -pe mpi 20
# Enable resource reservation
#$ -R y
# The max hard walltime for this job is 16 minutes (after this it will be killed)
#$ -l h_rt=00:16:00
# The max soft walltime for this job is 15 minute (after this SIGUSR2 will be sent)
#$ -l s_rt=00:15:00
# The following is for reporting only. It is not really needed
# to run the job. It will show up in your output file.
echo "Got $NSLOTS processors."
# The mpirun command.
HF=$(mktemp)
trap 'rm -f ${HF}; exit 0' 0 1 2 3 14 15

cat $PE_HOSTFILE | awk '{print $1 " slots="$2}' > $HF
mpirun -np $NSLOTS --hostfile $HF /usr/local/lib/R/site-library/snow/RMPISNOW --no-save < /mnt/transient_nfs/ubuntu/NectarFreeSurfer/rsnow.R
