#!/usr/bin/env nextflow

// Adapted from: https://github.com/connor-lab/ncov2019-artic-nf/blob/master/workflows/illuminaNcov.nf

include {indexReference} from '../modules/illumina.nf'
include {callVariantsWithCodons} from '../modules/illumina.nf'

workflow prepareReferenceFiles {
    // Get reference fasta
    Channel.fromPath(params.ref).set{ ch_refFasta }
    
    // Check if all BWA aux files exist, if not, make them
    bwaAuxFiles = []
    refPath = new File(params.ref).getAbsolutePath()
    new File(refPath).getParentFile().eachFileMatch( ~/.*.bwt|.*.pac|.*.ann|.*.amb|.*.sa/) { bwaAuxFiles << it }
    
    if ( bwaAuxFiles.size() == 5 ) {
      Channel.fromPath( bwaAuxFiles ).set{ ch_bwaAuxFiles }
      ch_refFasta.combine(ch_bwaAuxFiles.collect().toList()).set{ ch_preparedRef }
    } else {
      indexReference(ch_refFasta)
      indexReference.out.set{ ch_preparedRef }
    } 
 
    Channel.fromPath(params.gff).set{ ch_gffFile }

    emit:
      bwaindex = ch_preparedRef
      gfffile = ch_gffFile
}

workflow sequenceAnalysis {

  take:
    ch_primerTrimmedBamFiles
    ch_preparedRef
    ch_gffFile
    
  main:
    callVariantsWithCodons(ch_primerTrimmedBamFiles.map{ it -> [it[0], it[1][0], it[1][1]] }.combine(ch_preparedRef.map{ it[0] }).combine(ch_gffFile))
}

workflow ncovIllumina {
    take:
      ch_primerTrimmedBamFiles

    main:
      // Build fasta, index and gfffile as required
      prepareReferenceFiles()

      // Actually do analysis
      sequenceAnalysis(ch_primerTrimmedBamFiles, prepareReferenceFiles.out.bwaindex, prepareReferenceFiles.out.gfffile)
}