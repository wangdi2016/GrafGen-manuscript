## ----eval=FALSE---------------------------------------------------------------
#     if (!requireNamespace("BiocManager", quietly = TRUE))
#         install.packages("BiocManager")
#     BiocManager::install("GrafGen")

## -----------------------------------------------------------------------------
library(GrafGen)

#setwd("/Users/wangdi/work2/GrafGen-revision/benchmark/LD/to-git/run-grafgen/full")
setwd("./")
## -----------------------------------------------------------------------------
    #dir <- system.file("extdata", package="GrafGen", mustWork=TRUE)
    #geno.file <- paste0(dir, .Platform$file.sep, "data.vcf.gz")
    geno.file <- "../data/full/core.vcf.gz"
    print(geno.file)

## -----------------------------------------------------------------------------
ret <- grafGen(geno.file, print=0)
ret$table[seq_len(5), ]

## -----------------------------------------------------------------------------
print(ret)

saveRDS(ret, file="core.vcf.grafgen.rds")
write.table(ret$table, file="core.vcf.grafgen.tsv")

