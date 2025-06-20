#!/usr/bin/env nextflow

process FastANI {

    publishDir 'results/FastANI', mode: 'copy'

    container 'docker://staphb/fastani'

    input:
    tuple val(sample_id), 
	  path(query_list, stageAs: 'queries.txt'), 
          path(reference_list, stageAs: 'references.txt')

    output:
    path "${sample_id}.tsv", emit: fastani_results

    script:
    """
    fastANI --ql queries.txt \
	    --rl references.txt \
	     -o ${sample_id}.tsv
    """
}
