# E. coli Variant Calling Pipeline (REL606)

## Overview:
This repository contains a reproducible, modular variant calling pipeline for Escherichia coli whole-genome sequencing (WGS) data. The pipeline is designed to process paired-end Illumina reads, align them to the REL606 reference genome, and identify high-confidence SNPs and small indels.

# The workflow follows widely accepted best practices in bacterial genomics and is suitable for:
Academic coursework and bioinformatics diplomas -Research projects -Training and demonstration purposes

## Pipeline Steps:
1- Quality Control: Raw FASTQ quality assessment using FastQC

2- Read Trimming: Adapter and quality trimming using Trimmomatic

3- second QC: second round of QC to check the quality after trimming

4- Alignment: Mapping reads to the REL606 reference genome using BWA-MEM

5- Post-alignment Processing: SAM to BAM conversion

6- Sorting and indexing: using samtools

7- Variant Calling: SNP and indel calling using bcftools

## Input Requirements:
1- Sequencing Data: -Paired-end FASTQ files (.fastq or .fastq.gz)

2- Reference Genome -E. coli REL606 reference genome (FASTA) -Corresponding annotation file (GFF)

## Output Files
All outputs are automatically generated under the results/ directory: qc/ : fastq reports bam/ : Sorted and indexed BAM files vcf/ : Raw and filtered VCF files tmp/ : temporary files.

## Installation:
    * Conda Environment (Recommended)
    * conda env create -f envs/conda_environment.yml conda activate ecoli-variant-calling
## Required Tools
-FastQC 
-Trimmomatic 
-BWA 
-samtools 
-bcftools optional: 
-IGV (for visualization)
### Visualization with IGV:

1. Load the reference genome (REL606.fasta)
2. Load the sorted BAM file and its index
3. Load the corresponding VCF file
4. Inspect SNPs and indels at candidate loci

## Author:
Yahia Maher Mohamed Molecular Biologist | NGS & Bioinformatics Egypt

## License:
This project is released under the MIT License.

## Citation:
If you use this pipeline in your work, please cite it using the CITATION.cff file provided.
