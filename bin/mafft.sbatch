#!/bin/bash

#SBATCH --partition=defq       # the requested queue
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=16      #
#SBATCH --mem-per-cpu=20000     # in megabytes, unless unit explicitly stated
#SBATCH --error=checkM-%J.err         # redirect stderr to this file
#SBATCH --output=checkM-%J.out        # redirect stdout to this file
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

# ~~~~~~~~~~ TMP DIR ~~~~~~~~~~~ #

export TMPDIR="/mnt/scratch/c2006576/singularity/cache"

# ~~~~~~~~~~ VARIABLES ~~~~~~~~~~ #

WORKDIR=$(pwd)
GENOMES=${WORKDIR}/output/ORBICOLA-Genomes

# ~~~~~~~~~~ NEW DIRECTORIES ~~~~~~~~~~ #

mkdir ${WORKDIR}/output/ch
CHECKM2=${WORKDIR}/output/mafft

sequence1 = 
sequence2 = 
output_sequence = 

# ~~~~~~~~~~ CHECKM2 START ~~~~~~~~~~ #

module load mafft/

mafft --auto ${sequence1} ${sequence2} > ${output_sequence}

module purge
