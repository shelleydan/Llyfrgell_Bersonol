#!/bin/bash

#~~~~~~~~~~ JOB IDENTIFICATION ~~~~~~~~~~#

#SBATCH --job-name=ABRICATE                       # Assing a job name.
#SBATCH --output=%J-ABRICATE.out                  # Redirect stdout to this file
#SBATCH --error=%J-ABRICATE.err                   # Redirect stderr to this file

#~~~~~~~~~~ ASSIGNED RESOURCES ~~~~~~~~~~#

#SBATCH --partition=epyc                        # The requested queue partition (e.g defq)
#SBATCH --nodes=1                                 # Number of nodes to use
#SBATCH --tasks-per-node=1                        # Number of tasks per node.
#SBATCH --cpus-per-task=16                        # CPUs per task.
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

#~~~~~ ABRICATE SCRIPT ~~~~~#

module load abricate/

## MEGARES #################################################################################

#for f in ${GENOMES}/*.fasta
while IFS= read -r f;
        do
        base=$(basename "${f}" .fasta)
        echo ${base}

        abricate --db megares_v3.00 \
                 --datadir /mnt/scratch45/c2006576/burkholderia2025/CHP2_GWAS/databases/abricate \
                 --threads ${SLURM_CPUS_PER_TASK} \
                 "${f}" > ${ABRICATE}/customdb/files/${base}_customdb.tab

        abricate --db megares \
                 --threads ${SLURM_CPUS_PER_TASK} \
                 "${f}" > ${ABRICATE}/megares/files/${base}_megares.tab

        abricate --db vfdb \
                 --threads ${SLURM_CPUS_PER_TASK} \
                 "${f}" > ${ABRICATE}/vf/files/${base}_vf.tab

        abricate --db plasmidfinder \
                 --threads ${SLURM_CPUS_PER_TASK} \
                 "${f}" > ${ABRICATE}/plasmid/files/${base}_plasmid.tab

done < "${FOFN}" 

abricate --summary ${ABRICATE}/customdb/files/*_customdb.tab > ${ABRICATE}/customdb/customdb_summary_${date}.tab
sed -E 's#.*/(.*)_customdb\.tab#\1#' ${ABRICATE}/customdb/customdb_summary_${date}.tab > ${ABRICATE}/customdb/customdb_final_${date}.tab


abricate --summary ${ABRICATE}/megares/files/*_megares.tab > ${ABRICATE}/megares/megares_summary_${date}.tab
sed -E 's#.*/(.*)_megares\.tab#\1#' ${ABRICATE}/megares/megares_summary_${date}.tab > ${ABRICATE}/megares/megares_final_${date}.tab


abricate --summary ${ABRICATE}/vf/files/*_vf.tab > ${ABRICATE}/vf/vf_summary_${date}.tab
sed -E 's#.*/(.*)_megares\.tab#\1#' ${ABRICATE}/vf/vf_summary_${date}.tab > ${ABRICATE}/vf/vf_final_${date}.tab


abricate --summary ${ABRICATE}/plasmid/files/*_plasmid.tab > ${ABRICATE}/plasmid/plasmid_summary_${date}.tab
sed -E 's#.*/(.*)_megares\.tab#\1#' ${ABRICATE}/plasmid/plasmid_summary_${date}.tab > ${ABRICATE}/plasmid/plasmid_final_${date}.tab

module purge

