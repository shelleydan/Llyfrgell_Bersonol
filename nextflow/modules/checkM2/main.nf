#!/usr/bin/env nextflow

params.diamonddb = '/mnt/scratch45/c2006576/burkholderia2025/Llyfrgell_Bersonol/nextflow/database/uniref100.KO.1.dmnd'

process checkM2 {

    publishDir 'results/checkM2', mode: 'copy'

    container 'community.wave.seqera.io/library/checkm2:1.1.0--60f287bc25d7a10d'

    input:
    path(assemblies)

    output:
    path "checkm2_output"

    script:
    """
    export TMPDIR=/mnt/scratch45/c2006576/singularity/tmp
    export APPTAINER_TMPDIR=/mnt/scratch45/c2006576/singularity/tmp
    export APPTAINER_CACHEDIR=/mnt/scratch45/c2006576/singularity/cache
    export PYTHONTMPDIR=/mnt/scratch45/c2006576/singularity/tmp/python

    checkm2 predict --threads ${task.cpus} \
		    --input ${assemblies} \
                    --output-directory checkm2_output \
                    --database_path ${params.diamonddb} 
    """
}
