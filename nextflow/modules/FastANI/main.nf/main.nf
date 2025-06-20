#!/usr/bin/env nextflow

params.fastANIdb = 'data/database/fastANI.csv'

process FastANI {

	tag "$sample_id"

	// Identify the outputs
	publishDir "results/FastANI", mode: 'copy'

	// antiSMASH Container
	container 'docker://community.wave.seqera.io/library/fastani:1.34--54a7588f3473e24f'

    cpus 4
    memory '8 GB'

	input:
	tuple val(sample_id), path(fasta)

	output:
    tuple val(sample_id), path("${sample_id}.tsv")

	script:
	"""
	fastANI -q ${fasta} \
            --rl ${params.fastANIdb} \
            -o ${sample_id}.tsv \
            --threads ${task.cpus}
	"""
}
