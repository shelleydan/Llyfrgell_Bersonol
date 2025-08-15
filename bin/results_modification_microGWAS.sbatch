#!/bin/bash
#SBATCH --partition=epyc                       # the requested queue
#SBATCH --job-name=MicroGWAS                        # name of job
#SBATCH --nodes=1                              # number of nodes to use
#SBATCH --tasks-per-node=1                     #
#SBATCH --cpus-per-task=24                      #
#SBATCH --mem=2000                               # in megabytes, unless unit explicitly stated
#SBATCH --error=microGWAS-%J.err                   # redirect stderr to this file
#SBATCH --output=microGWAS-%J.out                  # redirect stdout to this file

##SBATCH --mail-user=shelleydr@cardiff.ac.uk  # email address used for event notification
##SBATCH --mail-type=all                       # email on job start, failure and end

# ~~~~~~~~~~ DEFINING VARIABLES ~~~~~~~~~~

WORKDIR="/mnt/scratch45/c2006576/burkholderia2025"
CONTWORKDIR=${WORKDIR}
MODULE_PYTHON="python/3.10"
# ~~~~~~~~~~ NEW DIRECTORY ~~~~~~~~~~

mkdir ${WORKDIR}/CHP2_GWAS/output/microGWAS
DIRECTORY_INTERPRO=${WORKDIR}/CHP2_GWAS/output/microGWAS
# ~~~~~~~~~~ IMAGE DOWNLOAD ~~~~~~~~~~

mkdir ${WORKDIR}/CHP2_GWAS/microGWAS
DATABASE_MICROGWAS=${WORKDIR}/CHP2_GWAS/microGWAS
URL_MICROGWAS="https://github.com/microbial-pangenomes-lab/microGWAS/releases/download/0.6.0/microGWAS.tar.gz"
URL_BASE=$(basename ${URL_MICROGWAS})
URL_EXTRACTED_BASE=$(basename ${URL_MICROGWAS} .tar.gz)
FOFN=/mnt/scratch45/c2006576/burkholderia2025/CHP1_COLLECTION/data/assemblies.csv

echo "Using file from: ${URL_MICROGWAS}"
echo ${URL_BASE}
echo ${URL_EXTRACTED_BASE}

if [ -d "${DATABASE_MICROGWAS}/${URL_EXTRACTED_BASE}" ]; then
    echo "Note: Database Exists - Skipping Download."
else
    echo "WARNING: Database Not Found - downloading..."
    wget ${URL_MICROGWAS} -O ${DATABASE_MICROGWAS}/${URL_BASE}

    tar -pxzf ${DATABASE_MICROGWAS}/${URL_BASE} -C ${DATABASE_MICROGWAS}

fi


#while IFS= read -r FOFN_FILE; do

#        BASE=$(basename $FOFN_FILE .fasta)

#        echo "Now investigating ${BASE}..."

#done < "${FOFN}"

source /mnt/scratch15/nodelete/$USER/miniforge/miniforge_env/bin/activate microGWAS_conda

cd /mnt/scratch45/c2006576/burkholderia2025/CHP2_GWAS/microGWAS/microGWAS

## This line gets a p-value threshold needed for the next section. 
#python3 workflow/scripts/count_patterns.py out/associations/cysticfibrosis/unitigs_patterns.txt --threshold

# Out p-value threshold is: 8.97E-08

module load python/3.11

python3 workflow/scripts/manhattan_plot.py out/associations/phenotype/mapped_all.tsv J2315 peak1.png --threshold 8.97E-08 --zoom 0.4 0.475 20
python3 workflow/scripts/manhattan_plot.py out/associations/phenotype/mapped_all.tsv J2315 peak2.png --threshold 8.97E-08 --zoom 1.1 1.2 20 
python3 workflow/scripts/manhattan_plot.py out/associations/phenotype/mapped_all.tsv J2315 peak3.png --threshold 8.97E-08 --zoom 1.7 1.8 20

module purge

conda deactivate
