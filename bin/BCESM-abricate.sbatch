#!/bin/bash

#~~~~~~~~~~ JOB IDENTIFICATION ~~~~~~~~~~#

#SBATCH --job-name=ABRICATE                       # Assing a job name.
#SBATCH --output=ABRICATE-%J.out                  # Redirect stdout to this file
#SBATCH --error=ABRICATE-%J.err                   # Redirect stderr to this file

#~~~~~~~~~~ ASSIGNED RESOURCES ~~~~~~~~~~#

#SBATCH --partition=epyc                        # The requested queue partition (e.g defq)
#SBATCH --nodes=1                                 # Number of nodes to use
#SBATCH --tasks-per-node=1                        # Number of tasks per node.
#SBATCH --cpus-per-task=8                        # CPUs per task.
#SBATCH --mem-per-cpu=1000                        # In megabytes, unless unit explicitly stated

#~~~~~~~~~~ JOB  NOTIFICATIONS ~~~~~~~~~~#

#SBATCH --mail-user=ShelleyDR@cardiff.ac.uk       # Email address used for event notification
#SBATCH --mail-type=end                           # Email on job end
#SBATCH --mail-type=fail                          # Email on job failure

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

#~~~~~ VARIABLES ~~~~~#

WORKDIR=$(pwd)
GENOMES=/mnt/scratch45/c2006576/burkholderia2025/CHP1_COLLECTION/assemblies
ABRICATE=${WORKDIR}/output/abricate
DATABASE=${WORKDIR}/database/abricate
FOFN=/mnt/scratch45/c2006576/burkholderia2025/CHP1_COLLECTION/data/assemblies.csv

#~~~~~ NEW DIRECTORIES ~~~~~#
mkdir ${ABRICATE}
mkdir ${ABRICATE}/megares/files -p
mkdir ${ABRICATE}/customdb/files -p
mkdir ${ABRICATE}/vf/files -p
mkdir ${ABRICATE}/plasmid/files -p
mkdir ${ABRICATE}/BCESM/files -p

#~~~~~ ABRICATE SCRIPT ~~~~~#

module load abricate/

## MEGARES #################################################################################

#for f in ${GENOMES}/*.fasta
while IFS= read -r f;
        do
        base=$(basename "${f}" .fasta)
        echo ${base}

        abricate --db BCESM \
                 --datadir /mnt/scratch45/c2006576/burkholderia2025/CHP2_GWAS/databases/abricate \
                 --threads ${SLURM_CPUS_PER_TASK} \
                 "${f}" > ${ABRICATE}/BCESM/files/${base}_BCESM.tab

done < "${FOFN}" 

abricate --summary ${ABRICATE}/BCESM/files/*_BCESM.tab > ${ABRICATE}/BCESM/BCESM_summary_${date}.tab
sed -E 's#.*/(.*)_customdb\.tab#\1#' ${ABRICATE}/BCESM/BCESM_summary_${date}.tab > ${ABRICATE}/BCESM/BCESM_final_${date}.tab


module purge

