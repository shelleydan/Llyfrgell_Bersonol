#! bin/usr/env bash

# docker image is antismash/antismash





# ~~~~~~~~~ VARIABLES ~~~~~~~~~~

# GENERAL

WORKDIR=$(pwd)
CONTAINERDIR=/mnt/container

# IMAGE SPECIFIC

IMAGENAME="antismash/antismash"
IMAGEFILE="antismash.sif"
IMAGEDIR=/mnt/scratch/${USER}/singularity/cache

# CONTAINER SPECIFIC 

CACHEDIR=/mnt/scratch/${USER}/singularity/cache
TMPDIR=/mnt/scratch/${USER}/singularity/temp

export SINGULARITY_CACHEDIR=${CACHEDIR}
export APPTAINER_CACHEDIR=${CACHEDIR}
export TMPDIR=${TMPDIR}

# ~~~~~~~~~~ IMAGE DOWNLOAD ~~~~~~~~~~

module load apptainer/            

# Check if Image Exists already ~~~~~

if [ -f ${IMAGEFILE} ]; then       
    echo "Docker image exists - skipping download."

else

    echo "Docker image does not exist - downloading ${IMAGENAME}"
    singularity pull ${IMAGEFILE} docker://${IMAGENAME} # Install the image (image is docker and needs do$

fi


# ~~~~~~~~~~ CONTAINER ~~~~~~~~~~

export BINDS="${WORKDIR}:${CONTAINERDIR},${TMPDIR}:${CONTAINERTMP}" # Binding Work and Tmp directories

cat > anvio_init_${SLURM_JOB_ID}.sh << EOF   

