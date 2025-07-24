#!/bin/bash

#~~~~~~~~~~ JOB IDENTIFICATION ~~~~~~~~~~# 

#SBATCH --job-name=NextflowCheckM2             # Assing a job name.
#SBATCH --output=%J.out    # Redirect stdout to this file
#SBATCH --error=%J.err      # Redirect stderr to this file

#~~~~~~~~~~ ASSIGNED RESOURCES ~~~~~~~~~~#

#SBATCH --partition=epyc       # The requested queue partition (e.g defq)
#SBATCH --nodes=1                                 # Number of nodes to use
#SBATCH --tasks-per-node=1                        # Number of tasks per node.
#SBATCH --cpus-per-task=12                    # CPUs per task.
#SBATCH --mem-per-cpu=1000                    # In megabytes, unless unit explicitly stated
#SBATCH --time=05:00:00	                  # Assign a max time for the job to run. 

#~~~~~~~~~~ JOB  NOTIFICATIONS ~~~~~~~~~~#

#SBATCH --mail-user=shelleydr@cardiff.ac.uk           # Email address used for event notification
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

module load nextflow/

module load apptainer/

nextflow run main.nf -c nextflow.config

module purge
