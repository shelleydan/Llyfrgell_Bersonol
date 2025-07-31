#!/bin/bash
#SBATCH --partition=epyc                       # the requested queue
#SBATCH --job-name=InterPro                        # name of job
#SBATCH --nodes=1                              # number of nodes to use
#SBATCH --tasks-per-node=1                     #
#SBATCH --cpus-per-task=8                      #
#SBATCH --mem=2G                               # in megabytes, unless unit explicitly stated
#SBATCH --error=interPro-%J.err                   # redirect stderr to this file
#SBATCH --output=interPro-%J.out                  # redirect stdout to this file

##SBATCH --mail-user=<username>@cardiff.ac.uk  # email address used for event notification
##SBATCH --mail-type=all                       # email on job start, failure and end

# ~~~~~~~~~~ DEFINING VARIABLES ~~~~~~~~~~

WORKDIR="/mnt/scratch45/c2006576/burkholderia2025"
CONTWORKDIR=${WORKDIR}
MODULE_PYTHON="python/3.10"
# ~~~~~~~~~~ NEW DIRECTORY ~~~~~~~~~~

mkdir ${WORKDIR}/CHP2_GWAS/output/interPro
DIRECTORY_INTERPRO=${WORKDIR}/CHP2_GWAS/output/interPro
# ~~~~~~~~~~ IMAGE DOWNLOAD ~~~~~~~~~~

mkdir ${WORKDIR}/CHP2_GWAS/interpro
DATABASE_INTERPRO=${WORKDIR}/CHP2_GWAS/interpro
URL_INTERPRO="https://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.75-106.0/interproscan-5.75-106.0-64-bit.tar.gz"
URL_BASE=$(basename ${URL_INTERPRO})
URL_EXTRACTED_BASE=$(basename ${URL_INTERPRO} -64-bit.tar.gz)
FOFN=/mnt/scratch45/c2006576/burkholderia2025/CHP1_COLLECTION/data/assemblies.csv


echo "File is interproscan-5.75-106.0"
echo ${URL_BASE}
echo ${URL_EXTRACTED_BASE}

if [ -d "${DATABASE_INTERPRO}/${URL_EXTRACTED_BASE}" ]; then
    echo "Note: Database Exists - Skipping Download."
else
    echo "WARNING: Database Not Found - downloading..."
    #wget ${URL_INTERPRO} -O ${DATABASE_INTERPRO}/${URL_BASE}

    #tar -pxzf ${DATABASE_INTERPRO}/${URL_BASE} -C ${DATABASE_INTERPRO}

    cd ${DATABASE_INTERPRO}/${URL_EXTRACTED_BASE}

    module load ${MODULE_PYTHON}

    python setup.py -f interproscan.properties

    module unload ${MODULE_PYTHON}

    cd ${WORKDIR}/CHP2_GWAS

fi

module load ${MODULE_PYTHON}
module load java/17.0.1

cd ${DATABASE_INTERPRO}/${URL_EXTRACTED_BASE}

while IFS= read -r FOFN_FILE; do

        BASE=$(basename $FOFN_FILE .fasta)

        echo "Now investigating ${BASE}..."

	./interproscan.sh \
		--input ${FOFN_FILE} \
		-b ${DIRECTORY_INTERPRO}/${BASE} \
		-cpu ${SLURM_CPUS_PER_TASK} \
		-f tsv \

done < "${FOFN}"

cat ${DIRECTORY_INTERPRO}/*.tsv > ${DIRECTORY_INTERPRO}/interproscan_all_results.tsv

module purge

