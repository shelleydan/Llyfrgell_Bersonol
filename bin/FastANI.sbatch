#!/bin/bash

#SBATCH --partition=defq       # the requested queue
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=16      #
#SBATCH --mem-per-cpu=10000     # in megabytes, unless unit explicitly stated
#SBATCH --error=ANI-%J.err         # redirect stderr to this file
#SBATCH --output=ANI-%J.out        # redirect stdout to this file
#SBATCH --mail-user=shelleydr@Cardiff.ac.uk  # email address used for event notification
#SBATCH --mail-type=end                                   # email on job end
#SBATCH --mail-type=fail                                  # email on job failure

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

# ~~~~~~~~~~ Variables ~~~~~~~~~~

workdir=$(pwd)                                                              # Assign Working directory
rawdir=${workdir}/input/rawdata                                             # Assign Rawdata directory
genomedir=${workdir}/output/ORBICOLA/ORBICOLA-removed-redundant

FILE=${workdir}/.FastANI                                                    # Assign FastANI Direcotyr

## Making Output Directory
mkdir ${workdir}/output/FastANI                                             # Making a FastANI Output
mkdir ${workdir}/output/FastANI/OrbicolaPanANI                                 # Making a FastANI output for individual results
#mkdir ${workdir}/output/FastANIs
fastanidir=${workdir}/output/FastANI                                        # Assign the FastANI Dir variable. 
mkdir ${workdir}/input/reference
refdir=${workdir}/input/reference

# ~~~~~~~~~~ Downloading RefSeq Genome ~~~~~~~~~~

#if [ -d "${refdir}/D1" ]; then
#    echo "Reference Genomes from PRJNA224116 project ID"
#
#else 
#    echo "Downloading reference genomes from PRJNA224116" 
#    wget -P ${refdir} http://enve-omics.ce.gatech.edu/data/public_fastani/D1.tar.gz 
#    tar -xvzf ${refdir}/D1.tar.gz -C ${refdir}
#fi

# ~~~~~~~~~~ FastANI Download ~~~~~~~~~~

if [ -d "${FILE}" ]; then
   echo "File ${FILE} exists."                                              # If the file exists, no need to Download.
   echo "If you have not previously installed FastANI..."
   echo "Remove your FastANI directory (rm -rf FastANI) and try again..."   # Ensuring FastANI is installed correcltly

else
   echo "File ${FILE} does not exist."
   echo "Creating Directory: ${FILE}"
   mkdir ${FILE}
   echo "Installing FastANI to ${FILE}"
   wget -P ${FILE}  https://github.com/ParBLiSS/FastANI/archive/master.zip  # Download FastANI from Repository
   sleep 5
   unzip ${FILE}/* -d ${FILE}                                               # Only one file is downloaded to this directory. 
   sleep 5
   rm ${FILE}/master.zip                                                    # Remove the original FastANI zip download.


   cd ${FILE}/FastANI-master                                                # Change Directory to the extracted tool. 
   sleep 1
   autoconf                                                                 # Generate configuration scripts for FastANI
   sleep 5 
   ./configure --with-gsl=/usr/                                             # Runs the configuration scripts.
   sleep 5
   make                                                                     # Compile FastANI into an excecutable code. 
   cd ${workdir}                                                            # Return to Working Directory
fi

# ~~~~~~~~~~ Performing FastANI Analysis ~~~~~~~~~~

FASTDIR=${FILE}/FastANI-master

cd ${FASTDIR}

for f in ${genomedir}/*.fasta #Listing all files in the ra$
do
base=$(basename $f | sed 's/\.fasta$//')
#base=$(echo $R1 | sed 's/_R1//') #Removes the '_R1_ e..g viru$

echo ${f}

./fastANI \
	-q ${f} \
	--rl ${workdir}/burkholderia-reference/refs.csv \
	-o ${fastanidir}/OrbicolaPanANI/${base}.tsv \
	--threads ${SLURM_CPUS_PER_TASK}
done

# ~~~~~~~~~~ Concatonate Output Files ~~~~~~~~~~

touch ${fastanidir}/OrbicolaPanANI.tsv

printf "QUERY-GENOME\tREF-GENOME\tANI-PERCENTAGE\tMATCHING-FRAGS\tTOTAL-FRAGS\n" > ${fastanidir}/OrbicolaPanANI.tsv

cat ${fastanidir}/OrbicolaPanANI/*.tsv >> ${fastanidir}/OrbicolaPanANI.tsv

awk -F'\t' '{
    file1=gensub(/\.fasta$/, "", "g", basename($1));
    file2=basename($2);
    $1=file1;
    $2=file2;
    OFS="\t"; print
}

function basename(path) {
    n = split(path, parts, "/");
    return parts[n];
}' ${fastanidir}/OrbicolaPanANI.tsv > ${fastanidir}/OrbicolaPanANI-Ordered.tsv

# ~~~~~~~~~~ Reformating Output File ~~~~~~~~~~

# Input and output file names
INPUT_FILE="${fastanidir}/OrbicolaPanANI-Ordered.tsv"
OUTPUT_FILE="${fastanidir}/Reformatted_OrbicolaPanANI_Ordered.tsv"

# Check if input file is provided
if [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 <input_tsv_file>"
    exit 1
fi

# Extract unique sample names
tail -n +2 "$INPUT_FILE" | cut -f1 | sort -u > samples.tmp

# Extract unique reference genomes
tail -n +2 "$INPUT_FILE" | cut -f2 | sort -u > refs.tmp

# Prepare header
echo -ne "Sample" > "$OUTPUT_FILE"
while read ref; do
    echo -ne "\t${ref}_ANI-Percentage\t${ref}_Matching-Frags\t${ref}_Total-Frags" >> "$OUTPUT_FILE"
done < refs.tmp
echo "" >> "$OUTPUT_FILE"

# Process each sample
while read sample; do
    echo -ne "$sample" >> "$OUTPUT_FILE"
    while read ref; do
        values=$(awk -v s="$sample" -v r="$ref" '$1 == s && $2 == r {print $3"\t"$4"\t"$5}' "$INPUT_FILE")
        if [ -z "$values" ]; then
            echo -ne "\tNA\tNA\tNA" >> "$OUTPUT_FILE"
        else
            echo -ne "\t$values" >> "$OUTPUT_FILE"
        fi
    done < refs.tmp
    echo "" >> "$OUTPUT_FILE"
done < samples.tmp

# Cleanup
temp_files=(samples.tmp refs.tmp)
rm -f "${temp_files[@]}"

echo "Reformatted file saved as $OUTPUT_FILE"

