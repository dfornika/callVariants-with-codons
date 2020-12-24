process indexReference {
    /**
    * Indexes reference fasta file in the scheme repo using bwa.
    */

    tag { ref }

    input:
        path(ref)

    output:
        tuple path('ref.fa'), path('ref.fa.*')

    script:
        """
        ln -s ${ref} ref.fa
        bwa index ref.fa
        """
}

process callVariantsWithCodons {

    tag { sampleName }

    publishDir "${params.outdir}/${task.process.replaceAll(":","_")}", pattern: "${sampleName}.variants.aa.tsv", mode: 'copy'

    input:
      tuple val(sampleName), path(bam), path(bam_index), path(ref), path(gff)

    output:
      tuple val(sampleName), path("${sampleName}.variants.aa.tsv")

    script:
      """
      samtools faidx ${ref}
      samtools mpileup -A -d 0 --reference ${ref} -B -Q 0 ${bam} |\
      ivar variants -r ${ref} -g ${gff} -m ${params.ivarMinDepth} -p ${sampleName}.variants.aa -q ${params.ivarMinVariantQuality} -t ${params.ivarMinFreqThreshold}
      """
}