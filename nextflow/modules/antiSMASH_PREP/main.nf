#!/usr/bin/env nextflow

params.antismash_db = 'data/database/antismashdb'

process antiSMASH_PREP {

	// antiSMASH Container
	container '/mnt/scratch45/c2006576/singularity/cache/antismash_8.0.1--494d955777d5fa60.sif'

	script:
	"""
	download-antismash-databases --database-dir "${params.antismash_db}/"
	"""

}
