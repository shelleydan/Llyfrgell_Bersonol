#!/bin/bash

#SBATCH --partition=defq       # the requested queue
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=4      #
#SBATCH --mem-per-cpu=8000     # in megabytes, unless unit explicitly stated
#SBATCH --error=quast-%J.err         # redirect stderr to this file
#SBATCH --output=quast-%J.out        # redirect stdout to this file
##SBATCH --mail-user= shelleydr@Cardiff.ac.uk  # email address used for event notification
##SBATCH --mail-type=end                                   # email on job end
##SBATCH --mail-type=fail                                  # email on job failure

echo "Some Usable Environment Variables:"
echo "================================="
echo "hostname=$(hostname)"
echo `date "+%d_%m_%Y"`
echo \$SLURM_JOB_ID=${SLURM_JOB_ID}
echo \$SLURM_NTASKS=${SLURM_NTASKS}
echo \$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}
echo \$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
echo \$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}
echo \$SLURM_MEM_PER_CPU=${SLURM_MEM_PER_CPU}

# ~~~~~~~~~~ VARIABLES ~~~~~~~~~~ # 

WORKDIR=$(pwd)
GENOMES=${WORKDIR}/output/ORBICOLA-Genomes

# ~~~~~~~~~~ NEW DIRECTORIES ~~~~~~~~~~ #

mkdir ${WORKDIR}/output/orbicola-quast
QUAST=${WORKDIR}/output/orbicola-quast

# ~~~~~~~~~~ QUAST SCRIPT ~~~~~~~~~~ #

module load py-quast/

quast.py \
	-t ${SLURM_CPUS_PER_TASK} \
	-o ${QUAST} \
	${GENOMES}/*

module purge
