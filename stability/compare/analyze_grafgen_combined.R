#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr); library(stringr)
  library(ggplot2); library(scales); library(tibble)
})

# =============== EDIT THIS IF YOUR FILE HAS A DIFFERENT NAME ===============
infile <- "grafgen_combined.tsv"  # your merged table (like the snippet you pasted)
outdir <- "grafgen_combined_results"
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
# ===========================================================================

# ---- Read robustly (tab or whitespace) ----
df <- tryCatch(
  readr::read_delim(infile, delim = "\t", col_types = cols()),
  error = function(e) NULL
)
if (is.null(df) || ncol(df) == 1) {
  df <- readr::read_table(infile, col_types = cols())
}

# ---- Clean/standardize column names (keep originals for plotting labels) ----
nm <- names(df)
names(df) <- nm |>
  str_replace_all("\\s+", "_")

# Required columns
needed <- c("Sample","full","pruned",
            "F_percent","E_percent","A_percent",
            "F_percent_pruned","E_percent_pruned","A_percent_pruned")
missing <- setdiff(needed, names(df))
if (length(missing)) stop("Missing expected columns: ", paste(missing, collapse = ", "))

# Coerce numeric percent columns (they may be read as char if quoted)
num_cols <- c("F_percent","E_percent","A_percent",
              "F_percent_pruned","E_percent_pruned","A_percent_pruned")
df[num_cols] <- lapply(df[num_cols], function(x) suppressWarnings(as.numeric(x)))

# ============== Metrics ==============
# Agreement & Cohen's kappa (pruned vs full labels)
tab <- table(full = df$full, pruned = df$pruned)
N <- sum(tab)
po <- sum(diag(tab)) / N
pe <- sum(rowSums(tab) * colSums(tab)) / (N * N)
kappa <- (po - pe) / (1 - pe)

# F/E/A errors (in percent units)
comp <- c("F","E","A")
err_tbl <- tibble(
  component = comp,
  MAE = sapply(comp, function(cmp) {
    mean(abs(df[[paste0(cmp,"_percent_pruned")]] - df[[paste0(cmp,"_percent")]]), na.rm = TRUE)
  }),
  RMSE = sapply(comp, function(cmp) {
    sqrt(mean((df[[paste0(cmp,"_percent_pruned")]] - df[[paste0(cmp,"_percent")]])^2, na.rm = TRUE))
  })
)
MAE_overall <- mean(err_tbl$MAE)

# Save summary TSVs
write_tsv(as_tibble(tab, rownames = "full"), file.path(outdir, "confusion_full_vs_pruned.tsv"))
summary_tbl <- tibble(
  metric = c("Samples","Agreement","Cohen_kappa","MAE_F","MAE_E","MAE_A","MAE_overall"),
  value  = c(nrow(df), round(po,4), round(kappa,4),
             round(err_tbl$MAE[match("F", err_tbl$component)],4),
             round(err_tbl$MAE[match("E", err_tbl$component)],4),
             round(err_tbl$MAE[match("A", err_tbl$component)],4),
             round(MAE_overall,4))
)
write_tsv(summary_tbl, file.path(outdir, "summary_metrics.tsv"))
write_tsv(err_tbl, file.path(outdir, "component_errors.tsv"))

# ============== Plots ==============
# 1) Confusion heatmap (within-FULL fractions)
tab_long <- as_tibble(tab) |>
  rename(FULL = full, PRUNED = pruned, n = n) |>
  group_by(FULL) |>
  mutate(prop = n / sum(n)) |>
  ungroup()

p_conf <- ggplot(tab_long, aes(x = PRUNED, y = FULL, fill = prop)) +
  geom_tile() +
  geom_text(aes(label = percent(prop, accuracy = 0.1)), size = 3) +
  scale_fill_gradient(low = "white", high = "steelblue", labels = percent) +
  labs(x = "PRUNED label", y = "FULL label",
       title = "Confusion heatmap (PRUNED vs FULL)",
       fill = "Within-FULL\nfraction") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(file.path(outdir, "confusion_heatmap.png"), p_conf, width = 8, height = 6, dpi = 150)
ggsave(file.path(outdir, "confusion_heatmap.pdf"), p_conf, width = 8, height = 6)

# 2) Scatter: PRUNED vs FULL percent per component (identity line)
plot_scatter <- function(cmp, label){
  ggplot(df, aes_string(x = paste0(cmp,"_percent"), y = paste0(cmp,"_percent_pruned"))) +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    geom_point(alpha = 0.7) +
    coord_cartesian(xlim = c(0,100), ylim = c(0,100)) +
    labs(x = paste0(label, " (FULL, %)"),
         y = paste0(label, " (PRUNED, %)"),
         title = paste0(label, ": PRUNED vs FULL")) +
    theme_minimal(base_size = 12)
}
gF <- plot_scatter("F", "F_percent")
gE <- plot_scatter("E", "E_percent")
gA <- plot_scatter("A", "A_percent")
ggsave(file.path(outdir, "scatter_F_percent.png"), gF, width = 5, height = 5, dpi = 150)
ggsave(file.path(outdir, "scatter_F_percent.pdf"), gF, width = 5, height = 5)
ggsave(file.path(outdir, "scatter_E_percent.png"), gE, width = 5, height = 5, dpi = 150)
ggsave(file.path(outdir, "scatter_E_percent.pdf"), gE, width = 5, height = 5)
ggsave(file.path(outdir, "scatter_A_percent.png"), gA, width = 5, height = 5, dpi = 150)
ggsave(file.path(outdir, "scatter_A_percent.pdf"), gA, width = 5, height = 5)

# 3) Bar of MAE per component
p_mae <- ggplot(err_tbl, aes(x = component, y = MAE)) +
  geom_col() +
  geom_text(aes(label = sprintf("%.2f%%", MAE)), vjust = -0.3, size = 3) +
  labs(x = "Component", y = "MAE (percentage points)",
       title = "Absolute error (PRUNED - FULL) by component") +
  theme_minimal(base_size = 12)
ggsave(file.path(outdir, "mae_by_component.png"), p_mae, width = 6, height = 4, dpi = 150)
ggsave(file.path(outdir, "mae_by_component.pdf"), p_mae, width = 6, height = 4)

# Done
writeLines(c(
  paste0("Wrote: ", file.path(outdir, "summary_metrics.tsv")),
  paste0("       ", file.path(outdir, "confusion_full_vs_pruned.tsv")),
  paste0("       ", file.path(outdir, "component_errors.tsv")),
  paste0("Plots: ", file.path(outdir, "confusion_heatmap.png")),
  paste0("       ", file.path(outdir, "scatter_F_percent.png")),
  paste0("       ", file.path(outdir, "scatter_E_percent.png")),
  paste0("       ", file.path(outdir, "scatter_A_percent.png")),
  paste0("       ", file.path(outdir, "mae_by_component.png"))
))

