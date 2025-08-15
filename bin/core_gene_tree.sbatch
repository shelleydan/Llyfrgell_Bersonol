#!/bin/bash

#~~~~~~~~~~ JOB IDENTIFICATION ~~~~~~~~~~# 

#SBATCH --job-name=PANAROO	                  # Assing a job name.
#SBATCH --output=PANGENOME-%J.out                 # Redirect stdout to this file
#SBATCH --error=PANGENOME-%J.err                  # Redirect stderr to this file

#~~~~~~~~~~ ASSIGNED RESOURCES ~~~~~~~~~~#

#SBATCH --partition=epyc                          # The requested queue partition (e.g defq)
#SBATCH --nodes=1                                 # Number of nodes to use
#SBATCH --tasks-per-node=1                        # Number of tasks per node.
#SBATCH --cpus-per-task=24                        # CPUs per task.
#SBATCH --mem-per-cpu=2000                        # In megabytes, unless unit explicitly stated
##SBATCH --time=[HH:MM:SS]	                  # Assign a max time for the job to run. 

#~~~~~~~~~~ JOB  NOTIFICATIONS ~~~~~~~~~~#

#SBATCH --mail-user=ShelleyDR@cardiff.ac.uk       # Email address used for event notification
#SBATCH --mail-type=all                           # Email on all job updates

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

source config.paramaters

#module load ${MODULE_PANAROO}

#mkdir ${DIR_CORE_GENOME}
#mkdir ${DIR_CORE_GENOME}/trees

#echo ${DIR_ANNOTATION}
#echo ${DIR_CORE_GENOME}

# Pangenome Creation

#panaroo -i ${DIR_ANNOTATION}/*/*.gff \
#	-o ${DIR_CORE_GENOME} \
#	-t ${SLURM_CPUS_PER_TASK} \
#	--clean-mode sensitive \
#	-a core \
#	--aligner mafft \
#	--remove-invalid-genes

module load ${MODULE_RAXML}

raxml-ng \
        --all --msa ${DIR_CORE_GENOME}/core_gene_alignment.aln \
        --model GTR \
        --bs-tree 100 \
        --prefix ${DIR_CORE_GENOME}/trees/pangenome_trees \
        --threads ${SLURM_CPUS_PER_TASK} \
	--force perf_threads

module purge

