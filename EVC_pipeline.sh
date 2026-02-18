#!/usr/bin/env bash
set -euo pipefail
# Pipeline info:

#-------------------------------------------------------
# Pipeline: E. coli variant calling pipeline
# Author: Yahia Maher Mohamed
# Date: 01.Feb.2026
# version: 1.0
# Detecting the number of CPU cores threads
#-------------------------------------------------------

# indentifying directories

#-------------------------------------------------------
RAW="$1"
REF="$2"
QC_DIR="$3"
BAM_DIR="$4"
TMP_DIR="$5"
VCF_DIR="$6"
threads=$(( $(nproc) - 2 ))
if [ "$threads" -lt 1 ]; then
    threads=1
fi
# -------------------------------
# Create Output Directories
# -------------------------------
mkdir -p "$QC_DIR" "$BAM_DIR" "$TMP_DIR" "$VCF_DIR"
# -------------------------------
# Tool Availability Check
# -------------------------------
for tool in fastqc trimmomatic bwa samtools bcftools vcftools; do
    if ! command -v "$tool" &> /dev/null; then
        echo "[ERROR] $tool is not installed or not in PATH"
        exit 1
    fi
done
#-------------------------------------------------------
# assigning the forward and reverse files
SAMPLE=$(basename "$R1" _R1.fastq)
# first qc
for R1 in "${RAW}"/*_R1.fastq; do 
    R2=${R1/_R1.fastq/_R2.fastq}
    SAMPLE=$(basename "$R1" _R1.fastq)
    echo "Processing sample: $SAMPLE"
# the echo lines used to easily separate between samples in case of processing large number of samples

 echo "[$(date)] start FastQC for $SAMPLE"
fastqc -t ${threads} -o ${qc} "$R1" "$R2"
done
# adaptors trimming using trimmomatic
trimmomatic PE -threads ${threads} ${R1} ${R2} trimmed/${SAMPLE}_R1.trimmed.fastq trimmed/${SAMPLE}_R1.unpaired.fastq trimmed/${SAMPLE}_R2.trimmed.fastq trimmed/${SAMPLE}_R2.unpaired.fastq ILLUMINACLIP:adaptor.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36

#second qc for the trimmed samples
fastqc *_trimmed.fastq

#reference indexing (if needed)
if [ ! -f "${REF}.bwt" ]; then
    echo "[INFO] Indexing reference genome..."
    bwa index "${REF}"
else
    echo "[INFO] Reference already indexed. Skipping."
fi
# Alignment and BWA processing
for R1 in "${RAW}"/*_R1.fastq; do
    R2="${R1/_R1.fastq/_R2.fastq}"
    SAMPLE=$(basename "$R1" _R1.fastq)

        bwa mem -t "${threads}" "${REF}" "$R1" "$R2" \
        | samtools view -@ "${threads}" -b \
        | samtools sort -@ "${threads}" -o "${BAM_DIR}/${SAMPLE}.sorted.bam"

    if [ $? -ne 0 ]; then
        echo "[ERROR] Alignment failed for ${SAMPLE}. Skipping."
        continue
    fi

    # Index BAM
    samtools index "${BAM_DIR}/${SAMPLE}.sorted.bam"
done

# automated variant calling and filtering
for BAM in "${BAM_DIR}"/*.sorted.bam; do
    SAMPLE=$(basename "$BAM" .sorted.bam)

    #variant Calling with bcftools
    echo "Calling variants with bcftools..."
    bcftools mpileup -f "$REF" -Ou "$BAM" -a AD,DP | \
    bcftools call -mv -Ov -o "${VCF_DIR}/${SAMPLE}.raw.vcf"
if [ $? -ne 0 ]; then
        echo "[ERROR] Variant calling failed for ${SAMPLE}. Skipping."
        continue
    fi
    #Filter variants with VCFftool
   echo "Filtering variants with VCFtools..."
    vcftools --vcf "${VCF_DIR}/${SAMPLE}.raw.vcf" --minQ 30 --minDP 10 --recode --out "${VCF_DIR}/${SAMPLE}.filtered"
done
