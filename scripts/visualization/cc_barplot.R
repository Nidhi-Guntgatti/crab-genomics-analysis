# ============================================
# Script: Distribution of carbapenemase genes across clonal complexes
#
# Description:
#   This script:
#     (1) Loads AMR and PopPUNK clonal cluster data
#     (2) Cleans and standardizes sample IDs
#     (3) Filters for key carbapenemase genes
#     (4) Merges AMR data with clonal complex (CC) information
#     (5) Counts isolates per CC and gene
#     (6) Selects top CCs and groups others
#     (7) Orders CCs for visualization
#     (8) Generates a faceted bar plot
#     (9) Saves a high-resolution figure
# ============================================


# ===============================
# 1. Load required libraries
# ===============================
library(tidyverse)
library(janitor)


# ===============================
# 2. Load and clean input data
# ===============================

# Load AMR dataset
amr <- read_tsv("path/to/amr_merged_cleaned.tsv")

# Load PopPUNK clonal cluster assignments
cc_df <- read_csv("path/to/query_assignment_clusters.csv") %>%
  clean_names() %>%                          # standardize column names
  select(name, clonal_cluster) %>%
  rename(sample_id = name, CC = clonal_cluster) %>%
  mutate(sample_id = str_replace(sample_id, "\\..*", ""))  # remove suffix to match AMR IDs


# ===============================
# 3. Filter genes of interest
# ===============================
# Focus on key carbapenemase genes
genes_of_interest <- c("blaNDM-1", "blaOXA-23", "blaOXA-66")

df_gene_cc <- amr %>%
  filter(`Element symbol` %in% genes_of_interest) %>%
  left_join(cc_df, by = "sample_id") %>%
  distinct(sample_id, CC, `Element symbol`)


# ===============================
# 4. Count isolates per CC and gene
# ===============================
plot_cc <- df_gene_cc %>%
  count(CC, `Element symbol`) %>%
  group_by(CC) %>%
  mutate(total = sum(n)) %>%
  ungroup()


# ===============================
# 5. Select top clonal complexes
# ===============================
# Keep top 5 CCs based on total counts
top_cc <- plot_cc %>%
  distinct(CC, total) %>%
  arrange(desc(total)) %>%
  slice_head(n = 5) %>%
  pull(CC)

# Group remaining CCs as "Other"
plot_cc <- plot_cc %>%
  mutate(CC_group = ifelse(CC %in% top_cc, CC, "Other"))


# ===============================
# 6. Order CCs for plotting
# ===============================
# Sort CCs by frequency
cc_order <- plot_cc %>%
  distinct(CC_group, total) %>%
  arrange(desc(total)) %>%
  pull(CC_group) %>%
  unique()

# Move "Other" to the end
cc_order <- c(setdiff(cc_order, "Other"), "Other")

plot_cc$CC_group <- factor(plot_cc$CC_group, levels = cc_order)


# ===============================
# 7. Generate faceted plot
# ===============================
# Displays distribution of each gene across CCs
p_cc <- ggplot(plot_cc, aes(x = CC_group, y = n, fill = `Element symbol`)) +
  geom_bar(stat = "identity") +
  facet_wrap(~`Element symbol`, scales = "free_y") +
  scale_fill_manual(values = c(
    "blaNDM-1"  = "#9b8fd7",
    "blaOXA-23" = "#65a764",
    "blaOXA-66" = "#d099c5"
  )) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Distribution of major carbapenemase genes across clonal complexes",
    x = "Clonal Complex (CC)",
    y = "Number of isolates"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )

# Display plot
print(p_cc)


# ===============================
# 8. Save high-resolution figure
# ===============================
ggsave(
  filename = "path/to/output/cc_gene_facet_plot.png",
  plot = p_cc,
  width = 12,
  height = 4,
  units = "in",
  dpi = 600
)