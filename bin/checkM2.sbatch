#!/bin/bash
#SBATCH --partition=epyc                       # the requested queue
#SBATCH --job-name=CheckM2                     # name of job
#SBATCH --nodes=1                              # number of nodes to use
#SBATCH --tasks-per-node=1                     #
#SBATCH --cpus-per-task=8                      #
#SBATCH --mem=2000                             # in megabytes, unless unit explicitly stated
#SBATCH --error=%J.err                   # redirect stderr to this file
#SBATCH --output=%J.out                  # redirect stdout to this file
#SBATCH --time=05:00:00                        # Assign a max time for the job to run.
##SBATCH --mail-user=shelleydr@cardiff.ac.uk  # email address used for event notification
##SBATCH --mail-type=all                       # email on job start, failure and end

# ~~~~~~~~~~ ACKOWLEDGMENTS ~~~~~~~~~~

# Correspondance: Dan Shelley (shelleydr@cardiff.ac.uk)

# ~~~~~~~~~~ CONFIG ~~~~~~~~~~
 
CACHEDIR='/mnt/scratch45/c2006576/singularity/cache'
TMPDIR='/mnt/scratch45/c2006576/singularity/tmp'

WORKDIR=$(pwd)
CONTAINERDIR="/mnt/container"
CONTAINERTMP="/tmp"
GENOMES=${WORKDIR}/output/assemblies
DATABASE='/mnt/scratch45/c2006576/burkholderia2025/Llyfrgell_Bersonol/nextflow/database/uniref100.KO.1.dmnd'

CHECKM2=${WORKDIR}/output/checkM2
mkdir ${CHECKM2}

# ~~~~~~~~~~ IMAGE DOWNLOAD ~~~~~~~~~~

module load apptainer/

export SINGULARITY_CACHEDIR=${CACHEDIR}   # Singularity Cache
export APPTAINER_CACHEDIR=${CACHEDIR}     # Apptainer Cache
export TMPDIR=${TMPDIR}                   # Temp storage directory 

SINGULARITY_IMG=checkm2.sif
IMAGENAME=staphb/checkm2

if [ -f ${SINGULARITY_IMG} ]; then                             # See if the Image is already downloaded
    echo "Docker image exists - skipping download."
else
    echo "Docker image does not exist - downloading ${IMAGENAME}"
    singularity pull ${SINGULARITY_IMG} docker://${IMAGENAME} # Install the image (image is docker and needs do$
fi

# ~~~~~~~~~~ CONTAINER AND ANVIO ~~~~~~~~~~

export BINDS="${WORKDIR}:${CONTAINERDIR},${TMPDIR}:${CONTAINERTMP}" # Binding Work and Tmp directories

cat > checkm2_${SLURM_JOB_ID}.sh << EOF                              # Generate the ANVIO initalising script to be executed

# ~~~~~ CheckM2 Script ~~~~~

checkm2 predict --input ${CONTAINERDIR}/output/assemblies/* \
                --output-directory ${CONTAINERDIR}/output/checkM2/ \
		--database_path ${CONTAINERDIR}/Llyfrgell_Bersonol/nextflow/database/uniref100.KO.1.dmnd \
                --tmpdir ${CONTAINERTMP} \
                --threads ${SLURM_CPUS_PER_TASK} \
                --specific \
                --stdout \
                --remove_intermediates \
                --force

EOF

singularity exec --contain --bind ${BINDS} --pwd ${CONTAINERDIR} ${SINGULARITY_IMG} bash checkm2_${SLURM_JOB_ID}.sh
