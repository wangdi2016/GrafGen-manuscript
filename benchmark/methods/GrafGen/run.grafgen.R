## ----eval=FALSE---------------------------------------------------------------
#     if (!requireNamespace("BiocManager", quietly = TRUE))
#         install.packages("BiocManager")
#     BiocManager::install("GrafGen")

## -----------------------------------------------------------------------------
library(GrafGen)

#setwd("/Users/wangdi/work2/git/GrafGen_v2_run")
#setwd("/Users/wangdi/work2/GrafGen-revision/benchmark/LD/grafgen")
setwd("/Users/wangdi/work2/GrafGen-revision/benchmark/LD/to-git/run-grafgen/full")
## -----------------------------------------------------------------------------
    #dir <- system.file("extdata", package="GrafGen", mustWork=TRUE)
    #geno.file <- paste0(dir, .Platform$file.sep, "data.vcf.gz")
    geno.file <- "core.vcf.gz"
    print(geno.file)

## -----------------------------------------------------------------------------
ret <- grafGen(geno.file, print=0)
ret$table[seq_len(5), ]

## -----------------------------------------------------------------------------
print(ret)

saveRDS(ret, file="core.vcf.grafgen.rds")
write.table(ret$table, file="core.vcf.grafgen.tsv")

## ----crop=NULL----------------------------------------------------------------
pdf(file="core.vcf.grafgen.pdf", height=8, width=12)
    plot(ret)
dev.off()

## -----------------------------------------------------------------------------
if (interactive()) interactiveReferencePlot()

## -----------------------------------------------------------------------------
tmp <- createApp(ret)

names(environment(tmp$app$server)$output)

# Wrap the original plotting function
orig_server <- tmp$app$server

tmp$app$server <- function(input, output, session) {
  
  # run the original server code first
  orig_server(input, output, session)
  
  # override the plot rendering
  output$gd_plot <- renderPlot({
    # get the original plot object
    p <- isolate(output$gd_plot())
    
    # apply new color scale
    p + scale_color_manual(values = c(
      "ALG" = "#D55E00",
      "ARG" = "#E69F00",
      "BGD" = "#56B4E9",
      "BGR" = "#009E73",
      "BRA" = "#F0E442",
      "CAN" = "#0072B2"
      # ... add all your countries
    ))
  })
}

# Launch modified app
shiny::runApp(tmp$app)










if (interactive()) {
    reference_results <- tmp$reference_results
    user_results      <- tmp$user_results
    user_metadata     <- tmp$user_metadata
    shiny::runApp(tmp$app)
}

## -----------------------------------------------------------------------------
sessionInfo()

