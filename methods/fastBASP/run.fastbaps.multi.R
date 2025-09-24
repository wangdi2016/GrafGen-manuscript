.libPaths("/Users/wangdi/work2/GrafGen-revision/fastbaps/demo/renv/library/macos/R-4.4/aarch64-apple-darwin20/")
library(fastbaps)
library(ape)

#fasta.file.name <- system.file("extdata", "seqs.fa", package = "fastbaps")
fasta.file.name <- "data/core.aln.fa"
sparse.data <- import_fasta_sparse_nt(fasta.file.name)

d <- snp_dist(sparse.data)
d <- as.dist(d/max(d))
h <- hclust(d, method="ward.D2")

#sparse.data <- optimise_prior(sparse.data, type = "optimise.symmetric")
#> [1] "Optimised hyperparameter: 0.02"
#multi.res.df1<- multi_res_baps(sparse.data, k.init=9, levels=9)
multi.res.df2 <- multi_level_best_baps_partition(sparse.data, h, levels=9)

# Save to CSV
#write.csv(multi.res.df1, "hpy1012set.fastbaps_clusters.multi.res.df1.k9.csv", row.names = FALSE)
write.csv(multi.res.df2, "hpy1012set.fastbaps_clusters.multi.res.df2.k9.best.csv", row.names = FALSE)


