#!/bin/bash
#SBATCH --partition=defq                       # the requested queue
#SBATCH --job-name=MaxBin2                       # name of job
#SBATCH --nodes=1                              # number of nodes to use
#SBATCH --tasks-per-node=1                     #
#SBATCH --cpus-per-task=8                      #
#SBATCH --mem=10G                               # in megabytes, unless unit explicitly stated
#SBATCH --error=%J-MaxBin2.err                   # redirect stderr to this file
#SBATCH --output=%J-MaxBin2.out                  # redirect stdout to this file
#SBATCH --time=05:00:00                        # Assign a max time for the job to run.
##SBATCH --mail-user=<username>@cardiff.ac.uk  # email address used for event notification
##SBATCH --mail-type=all                       # email on job start, failure and end

# VARIABLES #

WORKDIR=$(pwd)
BININDIR=/mnt/scratch/c2006576/cacnes2025/output/forBinning
RAWDIR=${WORKDIR}/input/rawdata

mkdir ${WORKDIR}/output/MaxBin2
BINOUTDIR=${WORKDIR}/output/MaxBin2

#

module load maxbin2/


for FILE in ${BININDIR}/Cutibacterium_acnes_*.fasta
do
    echo ${FILE}
    NAME=$(basename "${FILE}" .fasta)
    echo ${NAME}

mkdir ${BINOUTDIR}/${NAME}

run_MaxBin.pl \
	-contig ${FILE}	\
	-reads ${RAWDIR}/${NAME}_R1.fastq \
	-reads2 ${RAWDIR}/${NAME}_R2.fastq \
	-out ${BINOUTDIR}/${NAME}/${NAME}\
	-thread ${SLURM_CPUS_PER_TASK}
done

module unload maxbin2/
