#!/bin/bash

#SBATCH --partition=epyc       # the requested queue
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=8      #
#SBATCH --mem-per-cpu=4000     # in megabytes, unless unit explicitly stated
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

export TMPDIR="/mnt/scratch45/c2006576/singularity/cache"

# ~~~~~~~~~~ VARIABLES ~~~~~~~~~~ #

WORKDIR=$(pwd)
GENOMES=${WORKDIR}/output/assemblies

# ~~~~~~~~~~ NEW DIRECTORIES ~~~~~~~~~~ #

mkdir ${WORKDIR}/output/checkM2
CHECKM2=${WORKDIR}/output/checkM2

# ~~~~~~~~~~ CHECKM2 START ~~~~~~~~~~ #

module load checkm2/

checkm2 predict --input ${GENOMES}/* \
		--output-directory ${CHECKM2}/Burk2025_020725 \
		--tmpdir ${TMPDIR} \
		--threads ${SLURM_CPUS_PER_TASK} \
		--specific \
		--stdout \
		--remove_intermediates \
		--force

module purge
