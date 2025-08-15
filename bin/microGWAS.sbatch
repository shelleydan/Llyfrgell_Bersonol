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

bash bootstrap.sh Burkholderia cenocepacia J2315 GCF_000009485.1 

snakemake -p annotate_summary find_amr_vag manhattan_plots heritability enrichment_plots qq_plots tree wg_metrics --cores ${SLURM_CPUS_PER_TASK} --use-conda --conda-frontend mamba 

#--unlock

conda deactivate
