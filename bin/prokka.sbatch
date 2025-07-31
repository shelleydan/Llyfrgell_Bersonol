#!/bin/bash

#~~~~~~~~~~ JOB IDENTIFICATION ~~~~~~~~~~# 

#SBATCH --job-name=PROKKA_ANNOTATION             # Assing a job name.
#SBATCH --output=%J-PROKKA.out    # Redirect stdout to this file
#SBATCH --error=%J-PROKKA.err      # Redirect stderr to this file

#~~~~~~~~~~ ASSIGNED RESOURCES ~~~~~~~~~~#

#SBATCH --partition=epyc       # The requested queue partition (e.g defq)
#SBATCH --nodes=1                                 # Number of nodes to use
#SBATCH --tasks-per-node=1                        # Number of tasks per node.
#SBATCH --cpus-per-task=4                    # CPUs per task.
#SBATCH --mem-per-cpu=2000                    # In megabytes, unless unit explicitly stated
#SBATCH --time=24:00:00	                  # Assign a max time for the job to run. 

#~~~~~~~~~~ JOB  NOTIFICATIONS ~~~~~~~~~~#

#SBATCH --mail-user=ShelleyDR@cardiff.ac.uk       # Email address used for event notification
#SBATCH --mail-type=all                           # Email on all


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

source config.paramaters

#Variables - end data to be used is in trimqc
#Defining variables
workdir=$(pwd) #Script can be run from any file as this always updates

#New Output Directories
mkdir ${workdir}/output/annotation
annotdir=${workdir}/output/annotation

###Prokka

module load prokka/1.14.6-4f3ubpu

while IFS= read -r file; do

	base=$(basename $file .fasta) 

	echo ${base}

	prokka --Kingdom Bacteria  \
        	--outdir ${annotdir}/${base}  \
        	--prefix ${base} \
		--dbdir /mnt/scratch15/nodelete/apps/zen/spack/opt/spack/linux-rocky8-zen/gcc-8.5.0/prokka-1.14.6-eozpe5lnaz2xrvhw53wpdokqski4dvi2/db \
		"${file}"

done < "${FOFN}"

module unload prokka/

