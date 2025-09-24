library(readr); library(dplyr); library(ggplot2)

tab <- read_tsv("ldgrid/ld_grid_summary.tsv", show_col_types = FALSE)

# Ensure numeric ordering for each facet
r2_levels  <- tab %>% filter(grid == "r2")     %>% pull(r2)        %>% as.numeric() %>% unique() %>% sort()
win_levels <- tab %>% filter(grid == "window") %>% pull(window_kb) %>% as.numeric() %>% unique() %>% sort()

tab_plot <- tab %>%
  mutate(
    r2_lab  = as.character(as.numeric(r2)),           # e.g., "0.01"
    win_lab = paste0(as.numeric(window_kb), " kb"),   # e.g., "5 kb"
    x_lab   = ifelse(grid == "r2", r2_lab, win_lab),
    facet   = ifelse(grid == "r2",
                     "Vary r^2 (window = 10 kb, step = 5 variants)",
                     "Vary window (r^2 = 0.01, step = 5 variants)")
  ) %>%
  mutate(
    x = factor(
      x_lab,
      levels = c(as.character(r2_levels), paste0(win_levels, " kb")) # preserves desired orders
    )
  )

p <- ggplot(tab_plot, aes(x = x, y = kept, fill = grid)) +
  geom_col() +
  geom_text(aes(label = kept), vjust = -0.3, size = 3) +
  facet_wrap(~ facet, scales = "free_x", nrow = 1) +
  scale_fill_manual(
    values = c(r2 = "#1b9e77", window = "#7570b3"),   # colorblind-friendly pair
    labels = c(r2 = expression(r^2~" sweep"), window = "Window sweep"),
    name = NULL
  ) +
  labs(
    x = expression(r^2~" threshold  or  window (kb)"),
    y = "SNPs kept",
    title = "LD pruning grid (kept SNPs, maf > 0.1)"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "top")

ggsave("ldgrid/ld_grid_kept_facets.color.png", p, width = 8, height = 5, dpi = 150)
ggsave("ldgrid/ld_grid_kept_facets.color.pdf", p, width = 8, height = 5)

