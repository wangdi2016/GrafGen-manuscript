#!/bin/bash

source "/Users/wangdi/apps/anaconda3/etc/profile.d/conda.sh"
conda activate prs

#bgzip -c hpylori.vcf > hpylori.vcf.gz
tabix -p vcf hpylori.vcf.gz

# Set IDs to CHR:POS:REF:ALT while importing; cap allele string length just in case
plink2 \
  --vcf hpylori.vcf.gz \
  --allow-extra-chr \
  --snps-only just-acgt \
  --set-all-var-ids @:#:$r:$a \
  --new-id-max-allele-len 200 \
  --make-pgen \
  --out hpylori.id

# (If you still somehow have true duplicate records, drop dups on import)
# plink2 --pfile hpylori.id --rm-dup force-first --make-pgen --out hpylori.nodup

# LD prune r^2 < 0.01 (≈ r < 0.1)
#plink2 --pfile hpylori.id --max-alleles 2 --min-alleles 2 --maf 0.01 --indep-pairwise 10 5 0.01 --out hpylori_ld
plink2 --pfile hpylori.id --maf 0.01 --indep-pairwise 10 5 0.01 --out hpylori_ld

# Write pruned VCF
plink2 --pfile hpylori.id --extract hpylori_ld.prune.in --recode vcf bgz --out hpylori.ldpruned
tabix -p vcf hpylori.ldpruned.vcf.gz

# Input: hpylori.ldpruned.vcf.gz
# Output: hpylori.ldpruned.haploid.strict.vcf.gz  (GT is 0,1, or .)

gzcat hpylori.ldpruned.vcf.gz | \
awk 'BEGIN{FS=OFS="\t"}
  /^##/ {print; next}
  /^#CHROM/ {print; next}
  {
    # find the position of GT in the FORMAT column
    nfmt = split($9, fmt, ":"); gtpos = 0
    for (k=1; k<=nfmt; k++) if (fmt[k]=="GT") { gtpos=k; break }
    if (gtpos==0) { print; next }  # no GT? just pass through

    # rewrite each sample field
    for (i=10; i<=NF; i++) {
      ns = split($i, f, ":"); g = f[gtpos]

      # if diploid, convert
      if (g ~ /^[\.0-9]+[\/|][\.0-9]+$/) {
        split(g, a, /[\/|]/)
        if (a[1]=="." || a[2]==".")      f[gtpos] = "."
        else if (a[1]==a[2]) {           # homozygous
          if (a[1]=="0") f[gtpos]="0"
          else            f[gtpos]="1"   # any ALT index -> 1
        } else {
          f[gtpos] = "."                 # heterozygote -> missing (safe)
        }
      }
      # rebuild the sample field
      s=f[1]; for (j=2; j<=ns; j++) s = s ":" f[j]; $i = s
    }
    print
  }' | bgzip > hpylori.ldpruned.haploid.strict.vcf.gz
tabix -p vcf hpylori.ldpruned.haploid.strict.vcf.gz

