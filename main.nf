#!/usr/bin/env nextflow

// enable dsl2
nextflow.enable.dsl = 2

// import subworkflows
include {ncovIllumina} from './workflows/illuminaNcov.nf'

workflow {
  Channel.fromFilePairs( "${params.artic_analysis_dir}/ncovIllumina_sequenceAnalysis_trimPrimerSequences/*.mapped.primertrimmed.sorted.{bam,bam.bai}" )
	          .set{ ch_primerTrimmedBamFiles }
  main:
    ncovIllumina(ch_primerTrimmedBamFiles)
}