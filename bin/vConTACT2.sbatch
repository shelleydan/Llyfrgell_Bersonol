#!/bin/bash
#SBATCH --partition=epyc                       # the requested queue
#SBATCH --job-name=CheckV                        # name of job
#SBATCH --nodes=1                              # number of nodes to use
#SBATCH --tasks-per-node=1                     #
#SBATCH --cpus-per-task=8                      #
#SBATCH --mem=8G                               # in megabytes, unless unit explicitly stated
#SBATCH --error=checkV-%J.err                   # redirect stderr to this file
#SBATCH --output=checkV-%J.out                  # redirect stdout to this file

##SBATCH --mail-user=<username>@cardiff.ac.uk  # email address used for event notification
##SBATCH --mail-type=all                       # email on job start, failure and end

# ~~~~~~~~~~ DEFINING VARIABLES ~~~~~~~~~~

WORKDIR="/mnt/scratch45/c2006576/burkholderia2025"
CONTWORKDIR=${WORKDIR}

# ~~~~~~~~~~ NEW DIRECTORY ~~~~~~~~~~

mkdir ${WORKDIR}/CHP3_PHAGE/output/checkv

# ~~~~~~~~~~ IMAGE DOWNLOAD ~~~~~~~~~~

module load apptainer/1.3.4

export SINGULARITY_CACHEDIR=/mnt/scratch45/${USER}/singularity/cache/
export APPTAINER_CACHEDIR=/mnt/scratch45/${USER}/singularity/cache/
export TMPDIR=/mnt/scratch45/${USER}/singularity/cache/

IMAGE_NAME=staphb/checkv
SINGULARITY_IMAGE_NAME=checkv.sif
SINGIMGDIR=/mnt/scratch45/${USER}/singularity/cache

if [ -f ${SINGIMGDIR}/${SINGULARITY_IMAGE_NAME} ]; then
    echo "Docker image exists - skipping download."
else
    echo "Docker image does not exist - downloading ${IMAGE_NAME}"
    singularity pull ${SINGIMGDIR}/${SINGULARITY_IMAGE_NAME} docker://${IMAGE_NAME}
fi

# ~~~~~~~~~~ CONTAINER AND LAUNCH ~~~~~~~~~~

export BINDS="${WORKDIR}:${CONTWORKDIR}"

cat > checkV_init_${SLURM_JOB_ID}.sh << EOF

# ~~~~~ VARIABLES ~~~~~

# Note: We move into ${CONTWORKDIR}/CHP3_PHAGE thus the code works as follows

CONTWORKDIR=\$(pwd)
echo \${CONTWORKDIR}
FOFN=/mnt/scratch45/c2006576/burkholderia2025/CHP1_COLLECTION/data/assemblies.csv
DIR_OUTPUT=\${CONTWORKDIR}/output/checkv
DIR_checkv_DB=${CONTWORKDIR}/CHP3_PHAGE/checkv_db/checkv-db-v1.5
DIR_GENOMAD=${CONTWORKDIR}/CHP3_PHAGE/output/genomad
# Read FOFN paths into an array

checkv end_to_end --help

if [ -d \${DIR_checkv_DB} ]; then
    echo "Note: geNomad Database Exists - Skipping Download."
else
    echo "WARNING: geNomad Database Not Found - downloading..."
    checkv download_database \${DIR_checkv_DB}
fi

while IFS= read -r FILE; do

        BASE=\$(basename \$FILE .fasta)

        echo "Now investigating \${BASE}..."

	mkdir \${DIR_OUTPUT}/\${BASE}

	checkv end_to_end \
		\${DIR_GENOMAD}/\${BASE}/\${BASE}_find_proviruses/\${BASE}_provirus.fna \
		\${DIR_OUTPUT}/\${BASE} \
		-d \${DIR_checkv_DB} \
		-t 8 \
		--remove_tmp \
		--restart

done < "\${FOFN}"



EOF

# ~~~~~~~~~~ CONTAINER EXECUTE ~~~~~~~~~~

singularity exec --contain --bind ${BINDS} --pwd "${CONTWORKDIR}/CHP3_PHAGE" /mnt/scratch45/${USER}/singularity/cache/${SINGULARITY_IMAGE_NAME} bash ./checkV_init_${SLURM_JOB_ID}.sh

