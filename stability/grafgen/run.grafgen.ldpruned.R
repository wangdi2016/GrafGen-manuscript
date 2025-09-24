## ----eval=FALSE---------------------------------------------------------------
#     if (!requireNamespace("BiocManager", quietly = TRUE))
#         install.packages("BiocManager")
#     BiocManager::install("GrafGen")

## -----------------------------------------------------------------------------
library(GrafGen)

#setwd("/Users/wangdi/work2/GrafGen-revision/benchmark/LD/to-git/run-grafgen/ldpruned_maf0.1")
setwd("./")
## -----------------------------------------------------------------------------
    #dir <- system.file("extdata", package="GrafGen", mustWork=TRUE)
    #geno.file <- paste0(dir, .Platform$file.sep, "data.vcf.gz")
    #geno.file <- "core.vcf.gz"
    #geno.file <- "hpylori.ldpruned.vcf.gz"
    geno.file <- "../data/ldprune/hpylori.ldpruned.haploid.strict.vcf.gz"
    print(geno.file)

## -----------------------------------------------------------------------------
ret <- grafGen(geno.file, print=0)
ret$table[seq_len(5), ]

## -----------------------------------------------------------------------------
print(ret)

saveRDS(ret, file="hpylori.ldpruned.haploid.strict.vcf.grafgen.maf0.1.rds")
write.table(ret$table, file="hpylori.ldpruned.haploid.strict.vcf.grafgen.maf0.1.tsv", sep="\t")

