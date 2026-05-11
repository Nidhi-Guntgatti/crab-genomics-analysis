# ============================================
# Script: Distribution of carbapenemase genes across sequence types
#
# Description:
#   This script:
#     (1) Loads MLST results and cleans sample IDs
#     (2) Filters AMR data for selected genes of interest
#     (3) Merges AMR data with sequence type (ST) information
#     (4) Counts number of isolates per ST and gene
#     (5) Groups low-frequency STs into "Other"
#     (6) Generates a faceted bar plot
#     (7) Optionally creates a stacked bar plot
#     (8) Produces a summary table
# ============================================


# ===============================
# 1. Load required libraries
# ===============================
library(tidyverse)


# ===============================
# 2. Load and clean MLST data
# ===============================
# Extract sample IDs and corresponding ST types
st_df <- read_csv("path/to/mlst_results.csv") %>%
  select(sample_id, `ST type`) %>%
  rename(ST = `ST type`) %>%
  mutate(sample_id = basename(sample_id)) %>%
  mutate(sample_id = str_replace(sample_id, "\\.short\\.fasta$", ""))


# ===============================
# 3. Filter AMR genes of interest
# ===============================
# Focus on key carbapenemase genes
genes_of_interest <- c("blaNDM-1", "blaOXA-23", "blaOXA-66")

amr_subset <- amr %>%
  filter(`Element symbol` %in% genes_of_interest)


# ===============================
# 4. Merge AMR data with ST data
# ===============================
# Combine gene presence with sequence type information
df_gene_st <- amr_subset %>%
  left_join(st_df, by = "sample_id") %>%
  distinct(sample_id, ST, `Element symbol`)


# ===============================
# 5. Count isolates per ST and gene
# ===============================
plot_df <- df_gene_st %>%
  distinct(sample_id, ST, `Element symbol`) %>%
  count(ST, `Element symbol`) %>%
  group_by(ST) %>%
  mutate(total = sum(n)) %>%
  ungroup()


# ===============================
# 6. Replace missing ST values
# ===============================
# Convert "-" entries to "Other"
plot_df <- plot_df %>%
  mutate(ST = ifelse(ST == "-", "Other", ST))


# ===============================
# 7. Select top 10 sequence types
# ===============================
# Identify most frequent STs
top_st <- plot_df %>%
  distinct(ST, total) %>%
  arrange(desc(total)) %>%
  slice_head(n = 10) %>%
  pull(ST)

# Group remaining STs into "Other"
plot_df <- plot_df %>%
  mutate(ST_group = ifelse(ST %in% top_st, ST, "Other"))


# ===============================
# 8. Order STs for plotting
# ===============================
# Sort STs by total frequency
st_order <- plot_df %>%
  distinct(ST_group, total) %>%
  arrange(desc(total)) %>%
  pull(ST_group) %>%
  unique()

# Move "Other" to the end
st_order <- c(setdiff(st_order, "Other"), "Other")

plot_df$ST_group <- factor(plot_df$ST_group, levels = st_order)


# ===============================
# 9A. Create faceted bar plot
# ===============================
# Shows distribution per gene separately
p1 <- ggplot(plot_df, aes(x = ST_group, y = n, fill = `Element symbol`)) +
  geom_bar(stat = "identity") +
  facet_wrap(~`Element symbol`, scales = "free_y") +
  scale_fill_manual(values = c(
    "blaNDM-1"  = "#9b8fd7",
    "blaOXA-23" = "#65a764",
    "blaOXA-66" = "#d099c5"
  )) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Distribution of major carbapenemase genes across sequence types",
    x = "Sequence Type (ST)",
    y = "Number of isolates"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )

# Display plot
print(p1)

# Save high-resolution figure
ggsave(
  filename = "path/to/output/st_gene_facet_plot.png",
  plot = p1,
  width = 12,
  height = 4,
  units = "in",
  dpi = 600
)


# ===============================
# 9B. (Optional) Stacked plot
# ===============================
# Uncomment to generate combined view

# p2 <- ggplot(plot_df, aes(x = ST_group, y = n, fill = `Element symbol`)) +
#   geom_bar(stat = "identity") +
#   scale_fill_manual(values = c(
#     "blaNDM-1"  = "#9b8fd7",
#     "blaOXA-23" = "#65a764",
#     "blaOXA-66" = "#d099c5"
#   )) +
#   theme_minimal(base_size = 12) +
#   labs(
#     x = "Sequence Type (ST)",
#     y = "Number of isolates",
#     fill = "Carbapenemase gene"
#   ) +
#   theme(
#     axis.text.x = element_text(angle = 45, hjust = 1),
#     legend.position = "top"
#   )

# print(p2)


# ===============================
# 10. Create summary table
# ===============================
# Convert to wide format for reporting
table_df <- plot_df %>%
  pivot_wider(
    names_from = `Element symbol`,
    values_from = n,
    values_fill = 0
  ) %>%
  select(ST, total, ST_group, everything()) %>%
  arrange(desc(total))

# Display table
print(table_df)