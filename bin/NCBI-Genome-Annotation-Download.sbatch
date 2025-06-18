#!/bin/bash

#SBATCH --job-name=NCBIMetaDataDownload
#SBATCH --partition=defq       # the requested queue
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=4      #
#SBATCH --mem-per-cpu=8000     # in megabytes, unless unit explicitly stated
#SBATCH --error=GenomeDownload-%J.err         # redirect stderr to this file
#SBATCH --output=GenomeDownload-%J.out        # redirect stdout to this file
##SBATCH --mail-user= shelleydr@Cardiff.ac.uk  # email address used for event notification
##SBATCH --mail-type=end                                   # email on job end
##SBATCH --mail-type=fail                                  # email on job failure

echo "Some Usable Environment Variables:"
echo "================================="
echo "hostname=$(hostname)"
echo `date "+%d_%m_%Y"`
echo \$SLURM_JOB_ID=${SLURM_JOB_ID}
echo \$SLURM_NTASKS=${SLURM_NTASKS}
echo \$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}
echo \$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
echo \$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}
echo \$SLURM_MEM_PER_CPU=${SLURM_MEM_PER_CPU}

# ~~~~~~~~~~ User Variables ~~~~~~~~~~

# C.acnes is 1747
# B.cenocepacia is 95486
# B.orbicola is 2978683 
# Burkholderia Genus is 32008 

# Note: If you have a list made prior, populate accession.csv with your IDs. 

TAXAID="2978683" 
ASSENSIONCSV="accession.csv"

# ~~~~~~~~~~ Variables ~~~~~~~~~~
workdir=$(pwd)

FILE=${workdir}/.NCBI-Genome-Download                                       # Assign FastANI Direcotyr

## Making Output Directory
mkdir ${workdir}/output/NCBI-Genomes                                        # Making a FastANI Output
NCBIdir=${workdir}/output/NCBI-Genomes                                          # Assign the FastANI Dir variable.

# ~~~~~~~~~~ NCBI Genome Tool  Download ~~~~~~~~~~

if [ -d "${FILE}" ]; then
   echo "File ${FILE} exists."                                              # If the file exists, no need to Download.
   echo "If you have not previously installed NCBI Genome Download Tools..."
   echo "Remove your .NCBI-Genome-Download directory and try again..."      # Ensuring FastANI is installed correcltly

else
   echo "File ${FILE} does not exist."
   echo "Creating Directory: ${FILE}"
   mkdir ${FILE}
   echo "Installing NCBI Genome Downloader to ${FILE}"
   echo "Downloading Datasets..."
   wget -P ${FILE} https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets
   sleep 5
   chmod 777 ${FILE}/datasets

   echo "Downloading Dataformats..."
   wget -P ${FILE} https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/dataformat
   sleep 5
   chmod 777 ${FILE}/dataformat
fi

wait 5
# ~~~~~~~~~~ Downloading Preview Information ~~~~~~~~~~

# This is a function to preview the number of genomes you are about to download. This script has been designed to take in a .csv.
# This method forces the user to review the preview file and provide a .csv with assension IDs to download. 

if [ -f ${workdir}/${ASSENSIONCSV} ]; then
	echo "${ASSENSIONCSV} exists. Assuming preview step has been done."

else
	cd ${FILE}
	./datasets summary genome taxon "${TAXAID}" --as-json-lines > ${TAXAID}-summary.json     # Stored summary in .NCBI-Genome-Download as this is not human-readable. 
	./dataformat tsv genome --inputfile ${TAXAID}-summary.json > ${workdir}/${TAXAID}-summary.tsv
	sleep 2
	cd ${workdir}
	echo "Exit: Please preview ${TAXAID}-summary.tsv and generate an accession.csv (with Identifier, Accession ID as csv) to download genomes!"
	exit
fi

wait 5
# ~~~~~~~~~~ Genome Downloading from Assension ~~~~~~~~~~

cd ${FILE}

touch metadata.jsonl 				# Create a lined json report ready for metadata

for ACCESSION_NUMBER in $(cat ${workdir}/${ASSENSIONCSV}); do

	rm README.md
	rm md5sum.txt
	rm ncbi_dataset -rf
	echo "Processing Assension ID: ${ACCESSION_NUMBER}"
	./datasets download genome accession "${ACCESSION_NUMBER}" --filename "${ACCESSION_NUMBER}"-NCBI-dataset.zip --mag exclude --include genome
	sleep 2
	unzip "${ACCESSION_NUMBER}"-NCBI-dataset.zip
	sleep 2 
	mv ncbi_dataset/data/"${ACCESSION_NUMBER}"/* ${NCBIdir}/"${ACCESSION_NUMBER}".fasta
	sleep 2
	rm "${ACCESSION_NUMBER}"-NCBI-dataset.zip

	./datasets summary genome accession "${ACCESSION_NUMBER}" >> metadata.jsonl
done

mv ./metadata.jsonl ${workdir}/metadata.jsonl

cd ${workdir}



