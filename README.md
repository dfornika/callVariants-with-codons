# callVariantsWithCodons

This is a small supplementary workflow that takes an existing output directory from [BCCDC-PHL/ncov2019-artic-nf](https://github.com/BCCDC-PHL/ncov2019-artic-nf)
and re-runs the `callVariants` process (using `ivar variants`), with a `.gff` annotation file. This produces an output `variants.tsv` file with codon and
amino-acid information included. That information is missing from our default pipeline because we do not supply a `.gff` annotation file.

The pipeline is intended to be used to add new output files into an existing pipeline output directory. To prevent overwriting the existing `variants.tsv` files,
the output from this pipeline is written to a separate output directory and the output filenames have been appended with `.aa.tsv`.

After running this pipeline, the output directory would have two `variants.tsv` output directories, as follows:

```
ncovIllumina_sequenceAnalysis_callVariants/<sample_id>.variants.tsv
ncovIllumina_sequenceAnalysis_callVariantsWithCodons/<sample_id>.variants.aa.tsv
```

## Usage

```
nextflow run dfornika/callVariants-with-codons \
  -profile conda \
  --artic_analysis_dir <existing output dir from ncov2019-artic-nf> \
  --ref <nCoV-2019.reference.fasta> \
  --gff <nCoV-2019.gff> \
  --outdir <same existing output dir from ncov2019-artic-nf as above> 
```
