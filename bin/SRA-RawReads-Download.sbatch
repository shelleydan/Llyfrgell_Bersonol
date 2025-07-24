#!/bin/bash

#SBATCH --job-name=SRA-RawRead-Download
#SBATCH --partition=epyc       # the requested queue
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

# ~~~~~~~~~~ Parse flags ~~~~~~~~~ # 
MODE=""
while [[ "$1" != "" ]]; do
    case $1 in
        --short ) MODE="short" ;;
        --long ) MODE="long" ;;
        * ) echo "Invalid option: $1"; exit 1 ;;
    esac
    shift
done

# ~~~~~~~~~~ User Variables ~~~~~~~~~~

ASSENSIONCSV="accession.csv"

# ~~~~~~~~~~ Variables ~~~~~~~~~~
workdir=$(pwd)

FILE=${workdir}/.SRA-Genome-Download                                       # Assign FastANI Direcotyr

## Making Output Directory
mkdir ${workdir}/input/rawdata                                        # Making a FastANI Output
RAWREADS=${workdir}/input/rawdata                                          # Assign the FastANI Dir variable.

# ~~~~~~~~~~ NCBI Genome Tool  Download ~~~~~~~~~~

#if [ -d "${FILE}" ]; then
#   echo "File ${FILE} exists."                                              # If the file exists, no need to Download.
#   echo "If you have not previously installed SRA Toolkit..."
#   echo "Remove your ${FILE} directory and try again..."      # Ensuring FastANI is installed correcltly

#else
#   echo "File ${FILE} does not exist."
#   echo "Creating Directory: ${FILE}"
#   mkdir ${FILE}

#   echo "Installing ENA Genome Downloader to ${FILE}"
#   echo "Downloading Tools..."
#   cd ${FILE}
#   wget -P ${FILE} https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.2.1/sratoolkit.3.2.1-alma_linux64.tar.gz

#   wait 5

#   tar xvfz sratoolkit.3.2.1-alma_linux64.tar.gz

#   wait 5

#   cd ${RAWREADS}

#   .${FILE}/sratoolkit.3.2.1-alma_linux64/bin/vdb-config --prefetch-to-cwd

#   cd ${WORKDIR}
#fi


# ~~~~~~~~~~ Genome Downloading from Assension ~~~~~~~~~~

SRA_BIN=/mnt/scratch45/c2006576/burkholderia2025/.SRA-Genome-Download/sratoolkit.3.2.1-alma_linux64/bin

cd ${SRA_BIN}

if [[ "${MODE}" == "short" ]]; then
	mkdir ${RAWREADS}/PAIRED

	for ACCESSION_NUMBER in $(cat ${workdir}/${ASSENSIONCSV}); do

		echo "Fetching ${ACCESSION_NUMBER}..."
		./prefetch ${ACCESSION_NUMBER} -O ${RAWREADS}

		./fasterq-dump ${RAWREADS}/${ACCESSION_NUMBER} -O ${RAWREADS}/PAIRED --split-files
	done

elif [[ "${MODE}" == "long" ]]; then
        mkdir ${RAWREADS}/SINGLE

	for ACCESSION_NUMBER in $(cat ${workdir}/${ASSENSIONCSV}); do

                echo "Fetching ${ACCESSION_NUMBER}..."
                ./prefetch ${ACCESSION_NUMBER} -O ${RAWREADS}

                ./fasterq-dump ${RAWREADS}/${ACCESSION_NUMBER} -O ${RAWREADS}/SINGLE 

        done

else

	echo "Please assign either long (--long) or short (--short) flags"
	exit 1

fi
