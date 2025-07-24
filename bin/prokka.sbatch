#!/bin/bash

#SBATCH --partition=defq       # the requested queue
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=8      #
#SBATCH --mem-per-cpu=16000     # in megabytes, unless unit explicitly stated
#SBATCH --error=%J-PROKKA.err         # redirect stderr to this file
#SBATCH --output=%J-PROKKA.out        # redirect stdout to this file
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

