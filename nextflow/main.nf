#!/usr/bin/env nextflow

/* SCRIPT DESCRIPTION
 *
 * 
 *
 *
 *
 *
 */

nextflow.enable.dsl=2

// MODULES
include { FastANI } from './modules/FastANI/main.nf'
include { FastANIFormat } from './modules/FastANIFormat/main.nf'
include { kraken2 } from './modules/kraken2/main.nf'
include { checkM2 } from './modules/checkM2/main.nf'

// PARAMETERS
params.genomes = '/mnt/scratch45/c2006576/burkholderia2025/data/assemblies.csv'
//params.diamonddb = '/mnt/scratch45/c2006576/burkholderia2025/Llyfrgell_Bersonol/nextflow/database/uniref100.KO.1.dmnd'
//params.reads_csv = '/mnt/scratch45/${USER}/Llyfrgell_Bersonol/nextflow/data/rawreads.csv'
//params.kraken2db = '/mnt/scratch15/nodelete/smbpk/kraken_db/kraken_standard'

// WORKFLOW
workflow {

	// FastANI All-vs-All Comparison
	FastANI(tuple("all_vs_all", file(params.genomes), file(params.genomes)))

	// Script to Format the FastANI result
	FastANIFormat(FastANI.out.fastani_results)

	//reads_ch = Channel.fromPath(params.reads_csv)
	//		  .splitCsv(header:true)
	//		  .map { row -> tuple(row.sample, file(row.forward), file(row.reverse)) }
	//		  .set {read_pairs }

	// Kraken2 to provide Taxonomic Information
	//kraken2(reads_ch)

	// CheckM2 to Assess Genome Quality / Contamination
	//checkM2(file(params.genomes))
}
