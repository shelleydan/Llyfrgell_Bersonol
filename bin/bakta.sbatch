#!/bin/bash
#SBATCH --partition=epyc                       # the requested queue
#SBATCH --job-name=BAKTA                        # name of job
#SBATCH --nodes=1                              # number of nodes to use
#SBATCH --tasks-per-node=1                     #
#SBATCH --cpus-per-task=8                      #
#SBATCH --mem=4000                               # in megabytes, unless unit explicitly stated
#SBATCH --error=bakta-%J.err                   # redirect stderr to this file
#SBATCH --output=bakta-%J.out                  # redirect stdout to this file

#SBATCH --mail-user=shelleydr@cardiff.ac.uk  # email address used for event notification
#SBATCH --mail-type=all                       # email on job start, failure and end

# ~~~~~~~~~~ DEFINING VARIABLES ~~~~~~~~~~

source config.paramaters

# ~~~~~~~~~~ NEW DIRECTORY ~~~~~~~~~~

mkdir ${DIRECTORY_ANNOTATION}/bakta
mkdir ${DATABASE_BAKTA}

# ~~~~~~~~~~ IMAGE DOWNLOAD ~~~~~~~~~~

source ${CONDA_BAKTA}

if [ -d ${DATABASE_BAKTA}/db ]; then
    echo "Note: Bakta Database Exists - Skipping Download."
else
    echo "WARNING: Bakta Database Not Found - downloading database to: ${DATABASE_BAKTA}"
    bakta_db download --output ${DATABASE_BAKTA} --type full

    amrfinder_update --force_update --database ${DATABASE_BAKTA}/db/amrfinderplus-db/

    echo "Database downloaded & AMRFinder updated"
fi


echo "#################### BAKTA HELP ####################"

bakta --help

echo "####################################################"

while IFS= read -r FILE; do

        BASE=$(basename $FILE .fasta)

        echo "Now investigating ${BASE}..."

	bakta --db ${DATABASE_BAKTA}/db \
      	      --genus Burkholderia \
      	      --species cenocepacia \
      	      --prefix ${BASE} \
      	      --output ${DIRECTORY_ANNOTATION}/bakta/${BASE} \
      	      --threads ${SLURM_CPUS_PER_TASK} \
      	      --tmp-dir ${TMPDIR} \
      	      --gram - \
	      --complete \
	      ${FILE}

done < "${FOFN_INPUT}"

conda deactivate
