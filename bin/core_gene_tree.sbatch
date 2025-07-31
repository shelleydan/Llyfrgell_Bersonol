#!/bin/bash
#SBATCH --partition=epyc       # the requested queue
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=16     #
#SBATCH --mem-per-cpu=1000     # in megabytes, unless unit explicitly stated
#SBATCH --error=%J.err         # redirect stderr to this file
#SBATCH --output=%J.out        # redirect stdout to this file
##SBATCH --mail-user=[insert email address]@Cardiff.ac.uk  # email address used for event notification
##SBATCH --mail-type=end                                   # email on job end
##SBATCH --mail-type=fail                                  # email on job failure

echo "Some Usable Environment Variables:"
echo "================================="
echo "hostname=$(hostname)"
echo \$SLURM_JOB_ID=${SLURM_JOB_ID}
echo \$SLURM_NTASKS=${SLURM_NTASKS}
echo \$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}
echo \$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
echo \$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}
echo \$SLURM_MEM_PER_CPU=${SLURM_MEM_PER_CPU}

# Write jobscript to output file (good for reproducibility)
cat $0

source config.paramaters

module load ${MODULE_PANAROO}

#mkdir ${DIR_CORE_GENOME}
#mkdir ${DIR_CORE_GENOME}/trees

echo ${DIR_ANNOTATION}
echo ${DIR_CORE_GENOME}

# Pangenome Creation

#panaroo -i ${DIR_ANNOTATION}/*/*.gff \
#	-o ${DIR_CORE_GENOME} \
#	-t ${SLURM_CPUS_PER_TASK} \
#	--clean-mode sensitive \
#	-a core \
#	--aligner mafft \
#	--remove-invalid-genes

module load ${MODULE_RAXML}

raxml-ng \
        --all --msa ${DIR_CORE_GENOME}/core_gene_alignment.aln \
        --model GTR \
        --bs-tree 1000 \
        --prefix ${DIR_CORE_GENOME}/trees/pangenome_trees \
        --threads 8

module purge

