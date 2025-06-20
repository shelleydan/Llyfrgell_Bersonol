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

// PARAMETERS
params.genomes = '/mnt/scratch45/c2006576/Llyfrgell_Bersonol/nextflow/data/assemblies.csv'

// WORKFLOW
workflow {

	// FastANI All-vs-All Comparison
	FastANI(tuple("all_vs_all", file(params.genomes), file(params.genomes)))

	// Script to Format the FastANI result
	FastANIFormat(FastANI.out.fastani_results)
}
