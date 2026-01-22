#!/bin/bash

#~~~~~~~~~~ JOB IDENTIFICATION ~~~~~~~~~~# 

#SBATCH --job-name=UNICYCLER                          # Assing a job name.
#SBATCH --output=%J-UNICYCLER.out                     # Redirect stdout to this file
#SBATCH --error=%J-UNICYCLER.err                      # Redirect stderr to this file

#~~~~~~~~~~ ASSIGNED RESOURCES ~~~~~~~~~~#

#SBATCH --partition=epyc                              # The requested queue partition (e.g defq)
#SBATCH --nodes=1                                     # Number of nodes to use
#SBATCH --tasks-per-node=1                            # Number of tasks per node.
#SBATCH --cpus-per-task=8                             # CPUs per task.
#SBATCH --mem-per-cpu=2000                            # In megabytes, unless unit explicitly stated
##SBATCH --time=[HH:MM:SS]	                      # Assign a max time for the job to run. 

#~~~~~~~~~~ JOB  NOTIFICATIONS ~~~~~~~~~~#

#SBATCH --mail-user=ShelleyDR@cardiff.ac.uk           # Email address used for event notification
#SBATCH --mail-type=all                               # Email on job on all activity 

#~~~~~~~~~ DOCUMENT VARIABLES ~~~~~~~~~~~#

echo "Some Usable Environment Variables:"
echo "================================="
echo "hostname=$(hostname)"
echo "\$SLURM_JOB_ID=${SLURM_JOB_ID}"
echo "\$SLURM_NTASKS=${SLURM_NTASKS}"
echo "\$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}"
echo "\$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}"
echo "\$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}"
echo "\$SLURM_MEM_PER_CPU=${SLURM_MEM_PER_CPU}"

# Write jobscript to output file (good for reproducibility)
cat $0

source config.parameters

# ~~~~~ VARIABLES ~~~~~ #
DIR_READS="${DIRECTORY_WORK}/output/trimdata"
DIR_OUT_ASSEMBLY="${DIRECTORY_WORK}/output/assemblies"

# ~~~~~ SCRIPT ~~~~~ # 

module load ${MODULE_UNICYCLER}					# Loads the Unicycler module

for file in ${DIR_READS}/*_trim_*1.fastq.gz				# Starts the loop for all files in the given directory
	do

	R1=$(basename $file | cut -f1 -d.)			# Extracts the name before the .
	base=$(echo $R1 | sed 's/_trim_R1$//')			# Removes the _trim_1 naming format.


	unicycler -1 ${DIR_READS}/${base}*_trim_R1.fastq.gz \
		  -2 ${DIR_READS}/${base}*_trim_R2.fastq.gz \
	  	  -t ${SLURM_CPUS_PER_TASK} \
	  	  -o ${DIR_OUT_ASSEMBLY}/${base}

	 mv "${DIR_OUT_ASSEMBLY}/${base}/assembly.fasta" "${DIR_OUT_ASSEMBLY}/${base}/${base}.fasta"

done								# Finalise the loop

module purge							# Remove all active modules
