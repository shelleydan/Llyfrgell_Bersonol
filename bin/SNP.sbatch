#!/bin/bash

#~~~~~~~~~~ JOB IDENTIFICATION ~~~~~~~~~~#

#SBATCH --job-name=SNP                    # Assing a job name.
#SBATCH --output=%J-SNP.out               # Redirect stdout to this file
#SBATCH --error=%J-SNP.err                # Redirect stderr to this file

#~~~~~~~~~~ ASSIGNED RESOURCES ~~~~~~~~~~#

#SBATCH --partition=epyc                          # The requested queue partition (e.g defq)
#SBATCH --nodes=1                                 # Number of nodes to use
#SBATCH --tasks-per-node=1                        # Number of tasks per node.
#SBATCH --cpus-per-task=8                         # CPUs per task.
#SBATCH --mem-per-cpu=4000                        # In megabytes, unless unit explicitly stated

#~~~~~~~~~~ JOB  NOTIFICATIONS ~~~~~~~~~~#

#SBATCH --mail-user=ShelleyDR@cardiff.ac.uk       # Email address used for event notification
#SBATCH --mail-type=all

#~~~~~~~~~ DOCUMENT VARIABLES ~~~~~~~~~~~#

echo "Some Usable Environment Variables:"
echo "================================="
echo "hostname=$(hostname)"
echo `date "+%d_%m_%Y"`
echo "USER=${USER}"
echo "#~~~~~~~~~~ JOB IDENTIFICATION ~~~~~~~~~~#"
echo \$SLURM_JOB_NAME=${SLURM_JOB_NAME}
echo \$SLURM_JOB_ID=${SLURM_JOB_ID}
echo "#~~~~~~~~~~ ASSIGNED RESOURCES ~~~~~~~~~~#"
echo \$SLURM_NTASKS=${SLURM_NTASKS}
echo \$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}
echo \$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
echo \$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}
echo \$SLURM_MEM_PER_CPU=${SLURM_MEM_PER_CPU}

# Write jobscript to output file (good for reproducibility)
cat $0

#~~~~~~~~~~~ START OF SCRIPT ~~~~~~~~~~~~#

#~~~~~ VARIABLES ~~~~~~#
source

WORKDIR=$(pwd)
DIR_READS=/mnt/scratch45/c2006576/burkholderia2025/CHP1_COLLECTION/output/trimdata
OUTDIR_SNP=${WORKDIR}/output/snps
REFERENCE=/mnt/scratch45/c2006576/burkholderia2025/burkholderia-reference/Burkholderia_cenocepacia_J2315_GCA_000009485.1_ASM948v1_genomic.fna
FOFN=/mnt/scratch45/c2006576/burkholderia2025/CHP1_COLLECTION/data/assemblies.csv

#~~~~~ NEW DIRECTORIES ~~~~~#
mkdir ${OUTDIR_SNP}
MODULE_SNIPPY="snippy/v4.6.0"
MODULE_SNPSITES="snp-sites/2.5.1"
MODULE_RAXML="RAxML-NG/v1.2.0"
MODULE_PYTHON="python/3.11.6-63oqiza"

#~~~~~ MODULES ~~~~~#
module load ${MODULE_SNIPPY}
module load ${MODULE_PYTHON}

#~~~~~ SCRIPT ~~~~~#

while IFS= read -r f;
        do
        base=$(basename "${f}" .fasta)
        echo ${base}


snippy  -outdir ${OUTDIR_SNP}/${base} \
        -ref ${REFERENCE} \
        -R1 ${DIR_READS}/${base}*_R1.fastq.gz \
        -R2 ${DIR_READS}/${base}*_R2.fastq.gz \
        --prefix ${base} --force

done < "${FOFN}"

snippy-core \
        -ref ${REFERENCE} \
        -prefix ${OUTDIR_SNP}/bacterial_snp ${OUTDIR_SNP}/*

module load ${MODULE_SNPSITES}

snp-sites \
        -cb -o ${OUTDIR_SNP}/aln_bacterial_snp ${OUTDIR_SNP}/bacterial_snp.full.aln

module load ${MODULE_RAXML}

raxml-ng-mpi \
        --all --msa ${OUTDIR_SNP}/aln_bacterial_snp \
        --model GTR \
        --bs-tree 1000 \
        --prefix ${OUTDIR_SNP}/snp_tree \
        --threads 8

module purge

