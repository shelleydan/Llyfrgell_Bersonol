#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// MODULES
include { antiSMASH } from './modules/antiSMASH'

workflow {

	Channel
		.fromPath('data/assemblies.csv')
		.splitCsv(header: false)
		.map { row ->
			def path = file(row[0])
			def sample_id = path.baseName
			tuple(sample_id, path)
		}

		| antiSMASH

}
