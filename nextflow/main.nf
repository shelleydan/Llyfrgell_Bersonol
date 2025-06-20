#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// MODULES
include { FastANI } from './modules/FastANI/main.nf'

// PARAMETERS
params.genomes = 'data/assemblies.csv'

workflow {

	genomes_ch = Channel.fromPath(params.genomes)
						.splitCsv(header: false)
						.map { row ->
							def path = file(row[0])
							def sample_id = path.baseName
							tuple(sample_id, path)
						}

	FastANI(genomes_ch)

}
