#!/bin/bash
#SBATCH --partition=epyc                       # the requested queue
#SBATCH --job-name=antiSMASH                        # name of job
#SBATCH --nodes=1                              # number of nodes to use
#SBATCH --tasks-per-node=1                     #
#SBATCH --cpus-per-task=8                      #
#SBATCH --mem=4000                               # in megabytes, unless unit explicitly stated
#SBATCH --error=antiSMASH-%J.err                   # redirect stderr to this file
#SBATCH --output=antiSMASH-%J.out                  # redirect stdout to this file

#SBATCH --mail-user=shelleydr@cardiff.ac.uk  # email address used for event notification
#SBATCH --mail-type=all                       # email on job start, failure and end

# ~~~~~~~~~~ DEFINING VARIABLES ~~~~~~~~~~

WORKDIR="/mnt/scratch45/c2006576/burkholderia2025"
CONTWORKDIR=${WORKDIR}

# ~~~~~~~~~~ NEW DIRECTORY ~~~~~~~~~~

mkdir ${WORKDIR}/CHP2_GWAS/output/antiSMASH

# ~~~~~~~~~~ IMAGE DOWNLOAD ~~~~~~~~~~

module load apptainer/1.3.4

export SINGULARITY_CACHEDIR=/mnt/scratch45/${USER}/singularity/cache/
export APPTAINER_CACHEDIR=/mnt/scratch45/${USER}/singularity/cache/
export TMPDIR=/mnt/scratch45/${USER}/singularity/cache/

IMAGE_NAME="antismash/standalone:8.0.2"
SINGULARITY_IMAGE_NAME=antiSMASH.sif
SINGIMGDIR=/mnt/scratch45/${USER}/singularity/cache

if [ -f ${SINGIMGDIR}/${SINGULARITY_IMAGE_NAME} ]; then
    echo "Docker image exists - skipping download."
else
    echo "Docker image does not exist - downloading ${IMAGE_NAME}"
    singularity pull ${SINGIMGDIR}/${SINGULARITY_IMAGE_NAME} docker://${IMAGE_NAME}
fi

# ~~~~~~~~~~ CONTAINER AND LAUNCH ~~~~~~~~~~

export BINDS="${WORKDIR}:${CONTWORKDIR}"

cat > antiSMASH_init_${SLURM_JOB_ID}.sh << EOF

# ~~~~~ VARIABLES ~~~~~

# Note: We move into ${CONTWORKDIR}/CHP3_PHAGE thus the code works as follows

CONTWORKDIR=\$(pwd)
echo \${CONTWORKDIR}
FOFN=/mnt/scratch45/c2006576/burkholderia2025/CHP1_COLLECTION/data/assemblies.csv
DIR_ANTISMASH=${CONTWORKDIR}/CHP2_GWAS/output/antiSMASH
# Read FOFN paths into an array

antismash . . --version

echo "################### AntiSMASH Help ####################"

antismash . . --help

echo "############### Advanced AntiSMASH Help ###############"

antismash . . --help-showall

echo "#######################################################"

#if [ -d \${DATABASE_ANTISMASH} ]; then
#    echo "Note: geNomad Database Exists - Skipping Download."
#else
#    echo "WARNING: geNomad Database Not Found - downloading..."
#    antismash --setup-database \${DATABASE_ANTISMASH}
#fi

while IFS= read -r FILE; do

        BASE=\$(basename \$FILE .fasta)

        echo "Now investigating \${BASE}..."

	mkdir \${DIR_ANTISMASH}/\${BASE}

	antismash \
		-t bacteria \
		-c \${SLURM_CPUS_PER_TASK} \
		--genefinding-tool prodigal \
		--fullhmmer \
		--clusterhmmer \
		--tigrfam \
		--asf \
		--cc-mibig \
  		--cb-general \
		--cb-knownclusters \
		--cb-subclusters \
  		--pfam2go \
		--smcog-trees \
		--html-start-compact \
		--html-ncbi-context \
		--output-dir \${DIR_ANTISMASH}/\${BASE} \
		--output-basename \${BASE} \
		\${FILE}

done < "\${FOFN}"

EOF

# ~~~~~~~~~~ CONTAINER EXECUTE ~~~~~~~~~~

singularity exec --contain --bind ${BINDS} --pwd "${CONTWORKDIR}/CHP2_GWAS" /mnt/scratch45/${USER}/singularity/cache/${SINGULARITY_IMAGE_NAME} bash ./antiSMASH_init_${SLURM_JOB_ID}.sh

