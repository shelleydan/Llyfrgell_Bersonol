#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// MODULES
include { antiSMASH_PREP } from './modules/antiSMASH_PREP'
include { antiSMASH } from './modules/antiSMASH'

// Paramaters
params.genomes = 'data/assemblies.csv'


workflow {

	genomes_ch = Channel.fromPath(params.genomes)
						.splitCsv(header: false)
						.map { row ->
							def path = file(row[0])
							def sample_id = path.baseName
							tuple(sample_id, path)
						}

		// Preparing the antiSmash Environment
		antiSMASH_PREP()

		// antiSMASH Process
		//antiSMASH(genomes_ch)

}
