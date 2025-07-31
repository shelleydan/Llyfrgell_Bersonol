#!/bin/bash
#SBATCH --partition=epyc                       # the requested queue
#SBATCH --job-name=geNomad                        # name of job
#SBATCH --nodes=1                              # number of nodes to use
#SBATCH --tasks-per-node=1                     #
#SBATCH --cpus-per-task=8                      #
#SBATCH --mem=8G                               # in megabytes, unless unit explicitly stated
#SBATCH --error=genomad-%J.err                   # redirect stderr to this file
#SBATCH --output=genomad-%J.out                  # redirect stdout to this file

##SBATCH --mail-user=<username>@cardiff.ac.uk  # email address used for event notification
##SBATCH --mail-type=all                       # email on job start, failure and end

# ~~~~~~~~~~ DEFINING VARIABLES ~~~~~~~~~~

WORKDIR="/mnt/scratch45/c2006576/burkholderia2025"
CONTWORKDIR=${WORKDIR}

# ~~~~~~~~~~ NEW DIRECTORY ~~~~~~~~~~

mkdir ${WORKDIR}/CHP3_PHAGE/output/genomad

# ~~~~~~~~~~ IMAGE DOWNLOAD ~~~~~~~~~~

module load apptainer/1.3.4

export SINGULARITY_CACHEDIR=/mnt/scratch45/${USER}/singularity/cache/
export APPTAINER_CACHEDIR=/mnt/scratch45/${USER}/singularity/cache/
export TMPDIR=/mnt/scratch45/${USER}/singularity/cache/

IMAGE_NAME=staphb/genomad
SINGULARITY_IMAGE_NAME=genomad.sif
SINGIMGDIR=/mnt/scratch45/${USER}/singularity/cache

if [ -f /mnt/scratch45/${USER}/singularity/cache/${SINGULARITY_IMAGE_NAME} ]; then
    echo "Docker image exists - skipping download."
else
    echo "Docker image does not exist - downloading ${IMAGE_NAME}"
    singularity pull /mnt/scratch45/${USER}/singularity/cache/${SINGULARITY_IMAGE_NAME} docker://${IMAGE_NAME}
fi

# ~~~~~~~~~~ CONTAINER AND LAUNCH ~~~~~~~~~~

export BINDS="${WORKDIR}:${CONTWORKDIR}"

cat > genomad_init_${SLURM_JOB_ID}.sh << EOF

# ~~~~~ VARIABLES ~~~~~

CONTWORKDIR=\$(pwd)
echo \${CONTWORKDIR}
FOFN=/mnt/scratch45/c2006576/burkholderia2025/CHP1_COLLECTION/data/assemblies.csv
DIR_OUTPUT=\${CONTWORKDIR}/output/genomad
DIR_geNomad_DB=${CONTWORKDIR}/CHP3_PHAGE/genomad_db
# Read FOFN paths into an array

genomad --help

if [ -d \${DIR_geNomad_DB} ]; then
    echo "Note: geNomad Database Exists - Skipping Download."
else
    echo "WARNING: geNomad Database Not Found - downloading..."
    genomad download-database \${DIR_geNomad_DB}
fi


while IFS= read -r FILE; do

        BASE=\$(basename \$FILE .fasta)

        echo "Now investigating \${BASE}..."

	mkdir \${DIR_OUTPUT}/\${BASE}

	genomad end-to-end --cleanup \${FILE} \${DIR_OUTPUT}/\${BASE} \${DIR_geNomad_DB}

done < "\${FOFN}"



EOF

# ~~~~~~~~~~ CONTAINER EXECUTE ~~~~~~~~~~

singularity exec --contain --bind ${BINDS} --pwd "${CONTWORKDIR}/CHP3_PHAGE" /mnt/scratch45/${USER}/singularity/cache/${SINGULARITY_IMAGE_NAME} bash ./genomad_init_${SLURM_JOB_ID}.sh

