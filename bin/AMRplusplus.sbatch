#!/bin/bash

#~~~~~~~~~~ JOB IDENTIFICATION ~~~~~~~~~~#

#SBATCH --job-name=AMRplusplus                    # Assing a job name.
#SBATCH --output=%J-AMRplusplus.out               # Redirect stdout to this file
#SBATCH --error=%J-AMRplusplus.err                # Redirect stderr to this file

#~~~~~~~~~~ ASSIGNED RESOURCES ~~~~~~~~~~#

#SBATCH --partition=epyc                          # The requested queue partition (e.g defq)
#SBATCH --nodes=1                                 # Number of nodes to use
#SBATCH --tasks-per-node=1                        # Number of tasks per node.
#SBATCH --cpus-per-task=8                         # CPUs per task.
#SBATCH --mem-per-cpu=1000                        # In megabytes, unless unit explicitly stated

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

#~~~~~ VARIABLES ~~~~~#

WORKDIR=$(pwd)
INDIR=/mnt/scratch45/c2006576/burkholderia2025/CHP1_COLLECTION/assemblies
OUTDIR=${WORKDIR}/output/amrplusplus

#~~~~~ NEW DIRECTORIES ~~~~~#
mkdir ${OUTDIR}

#~~~~~ SCRIPT ~~~~~#

# Setting up the Environment
source /mnt/scratch15/$USER/amr/AMR_env/bin/activate

# AMRplusplus script
python /mnt/scratch15/$USER/amr/AmrPlusPlus_SNP/SNP_Verification.py \
							-c /mnt/scratch15/$USER/amr/AmrPlusPlus_SNP/config.ini \
							-a true \
							-t ${SLURM_CPUS_PER_TASK} \
							-i ${INDIR}/* \
							-o ${OUTDIR}

deactivate
