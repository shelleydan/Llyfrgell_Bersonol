#!/bin/bash
#SBATCH --partition=epyc                       # the requested queue
#SBATCH --job-name=BACPHLIP                        # name of job
#SBATCH --nodes=1                              # number of nodes to use
#SBATCH --tasks-per-node=1                     #
#SBATCH --cpus-per-task=4                      #
#SBATCH --mem=2000                               # in megabytes, unless unit explicitly stated
#SBATCH --error=BACPHLIP-%J.err                   # redirect stderr to this file
#SBATCH --output=BACPHLIP-%J.out                  # redirect stdout to this file

##SBATCH --mail-user=<username>@cardiff.ac.uk  # email address used for event notification
##SBATCH --mail-type=all                       # email on job start, failure and end

# ~~~~~~~~~~ DEFINING VARIABLES ~~~~~~~~~~

WORKDIR="/mnt/scratch45/c2006576/burkholderia2025"
CONTWORKDIR=${WORKDIR}

MODULE_BACPHLIP="/mnt/scratch45/c2006576/modules/bacphlip/bacphlip_env/bin/activate"
DIRECTORY_GENOMAD=${WORKDIR}/CHP3_PHAGE/output/genomad
DIRECTORY_BACPHLIP=${WORKDIR}/CHP3_PHAGE/output/bacphlip
FOFN=/mnt/scratch45/c2006576/burkholderia2025/CHP1_COLLECTION/data/assemblies.csv
# ~~~~~~~~~~ NEW DIRECTORY ~~~~~~~~~~

mkdir ${WORKDIR}/CHP3_PHAGE/output/bacphlip

module load hmmer/3.1b2
source ${MODULE_BACPHLIP}

bacphlip -h


while IFS= read -r FILE; do

    BASE=$(basename "$FILE" .fasta)

    echo "Now investigating prophages found within ${BASE}..."

    count=$(grep -o ">" ${DIRECTORY_GENOMAD}/${BASE}/${BASE}_find_proviruses/${BASE}_renamed_provirus.fna | wc -l)

    if [ "$count" -eq 1 ]; then
	bacphlip -f \
             -i "${DIRECTORY_GENOMAD}/${BASE}/${BASE}_find_proviruses/${BASE}_renamed_provirus.fna" 

	FASTA_ID=$(grep ">" ${DIRECTORY_GENOMAD}/${BASE}/${BASE}_find_proviruses/${BASE}_renamed_provirus.fna | sed 's/^>//')

	awk -v name="${FASTA_ID}" 'NR==1 {print; next} {if ($1 == "0") $1 = name; print}' OFS="\t" "${DIRECTORY_GENOMAD}/${BASE}/${BASE}_find_proviruses/${BASE}_renamed_provirus.fna.bacphlip" > "${DIRECTORY_GENOMAD}/${BASE}/${BASE}_find_proviruses/${BASE}_renamed_provirus.fna.bacphlip.tmp"

	mv "${DIRECTORY_GENOMAD}/${BASE}/${BASE}_find_proviruses/${BASE}_renamed_provirus.fna.bacphlip.tmp" "${DIRECTORY_GENOMAD}/${BASE}/${BASE}_find_proviruses/${BASE}_renamed_provirus.fna.bacphlip"

    elif [ "$count" -gt 1 ]; then
        bacphlip -f \
             -i "${DIRECTORY_GENOMAD}/${BASE}/${BASE}_find_proviruses/${BASE}_renamed_provirus.fna" \
             --multi_fasta

    else
	echo "This file is empty"

    fi

    mv "${DIRECTORY_GENOMAD}/${BASE}/${BASE}_find_proviruses/${BASE}_renamed_provirus.fna.bacphlip" "${DIRECTORY_BACPHLIP}/${BASE}_summary.tsv"

done < "${FOFN}"

## Generate a Summary File
echo -e "Sample\tVirulent\tTemperate" > ${DIRECTORY_BACPHLIP}/concatonated_summary.tsv

for file in ${DIRECTORY_BACPHLIP}/ *_summary.tsv; do

	tail -n +2 "$file" >> ${DIRECTORY_BACPHLIP}/concatonated_summary.tsv;

done

echo "All Bacphlip Predictions can be found here: ${DIRECTORY_BACPHLIP}"

deactivate
module purge
