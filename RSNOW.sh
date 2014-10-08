#!/bin/bash
# Export all environment variables
#$ -V

#$ -N mpi_interactive
# Use current working directory
#$ -cwd
# Join stdout and stderr
#$ -j y
# Enable resource reservation
#$ -R y
# PARALLEL ENVIRONMENT:
#$ -pe mpi 20

echo "Got $NSLOTS processors."
# The mpirun command.
HF=$(mktemp)
trap 'rm -f ${HF}; exit 0' 0 1 2 3 14 15

cat $PE_HOSTFILE | awk '{print $1 " slots="$2}' > $HF
mpirun -np $NSLOTS --hostfile $HF /usr/local/lib/R/site-library/snow/RMPISNOW --no-save

