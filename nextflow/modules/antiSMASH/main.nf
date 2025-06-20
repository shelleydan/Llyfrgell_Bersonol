#!/usr/bin/env nextflow

process antiSMASH {

	tag "$sample_id"

	// Identify the outputs
	publishDir "results/antiSMASH", mode: 'copy'

	// antiSMASH Container
	container '/mnt/scratch45/c2006576/singularity/cache/antismash_8.0.1--494d955777d5fa60.sif'

	input:
	tuple val(sample_id), path(fasta)

	output:
	tuple val(sample_id), path("antismash_output")

	script:
	"""
	antismash --output-dir antismash_output $fasta
	"""

}
