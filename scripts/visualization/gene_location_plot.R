# ============================================
# Script: Genomic location of carbapenemase genes
#
# Description:
#   This script:
#     (1) Loads AMR gene data and MOB-suite output
#     (2) Cleans and standardizes sample and contig IDs
#     (3) Identifies genomic location (plasmid vs chromosome)
#     (4) Filters for key carbapenemase genes
#     (5) Merges AMR and plasmid information
#     (6) Calculates isolate counts and percentages
#     (7) Generates a stacked bar plot
#     (8) Saves a publication-ready figure
# ============================================


# ===============================
# 1. Load required libraries
# ===============================
library(tidyverse)


# ===============================
# 2. Load input datasets
# ===============================
# AMR gene annotations
amr <- read_tsv("path/to/amr_merged_cleaned.tsv")

# MOB-suite contig classification
mob <- read_tsv("path/to/all_contigs_merged.tsv")


# ===============================
# 3. Clean and standardize IDs
# ===============================

# --- AMR CLEAN ---
# Extract sample ID, gene, and contig identifier
amr_clean <- amr %>%
  select(sample_id, contig_raw = `Contig id`, gene = `Element symbol`) %>%
  mutate(
    sample_id = basename(sample_id),
    sample_id = str_replace(sample_id, "\\.short$", ""),
    contig_id = str_extract(contig_raw, "contig\\d+")
  )

# --- MOB CLEAN ---
# Standardize IDs and classify location
mob_clean <- mob %>%
  mutate(
    sample_id = basename(sample_id),
    sample_id = str_replace(sample_id, "\\.short$", ""),
    contig_id = str_extract(contig_id, "contig\\d+"),
    Location = case_when(
      str_to_lower(molecule_type) == "plasmid" ~ "Plasmid",
      TRUE ~ "Chromosome"
    )
  ) %>%
  select(sample_id, contig_id, Location)


# ===============================
# 4. Define genes of interest
# ===============================
# Key carbapenemase genes
genes_of_interest <- c("blaNDM-1", "blaOXA-23", "blaOXA-66")


# ===============================
# 5. Merge AMR with location data
# ===============================
# Assign genomic location to each gene hit
amr_loc <- amr_clean %>%
  filter(gene %in% genes_of_interest) %>%
  left_join(mob_clean, by = c("sample_id", "contig_id")) %>%
  mutate(
    Location = ifelse(is.na(Location), "Chromosome", Location)
  )


# ===============================
# 6. Sanity check
# ===============================
# Check distribution of plasmid vs chromosome
print(table(amr_loc$Location))


# ===============================
# 7. Count unique isolates
# ===============================
# Count per gene and genomic location
plot_df <- amr_loc %>%
  distinct(sample_id, gene, Location) %>%
  count(gene, Location)


# ===============================
# 8. Convert counts to percentages
# ===============================
plot_df <- plot_df %>%
  group_by(gene) %>%
  mutate(percent = (n / sum(n)) * 100) %>%
  ungroup()


# ===============================
# 9. Fix factor order
# ===============================
# Ensure consistent plotting order
plot_df <- plot_df %>%
  mutate(
    gene = factor(gene, levels = c("blaNDM-1", "blaOXA-23", "blaOXA-66")),
    Location = factor(Location, levels = c("Chromosome", "Plasmid"))
  )


# ===============================
# 10. Generate stacked bar plot
# ===============================
p_loc <- ggplot(plot_df, aes(x = gene, y = percent, fill = Location)) +
  geom_bar(
    stat = "identity",
    width = 0.6,
    position = position_stack(reverse = TRUE)
  ) +
  geom_text(
    aes(label = paste0(round(percent, 1), "%")),
    position = position_stack(vjust = 0.5, reverse = TRUE),
    color = "black",
    size = 3.5,
    fontface = "bold"
  ) +
  scale_fill_manual(values = c(
    "Chromosome" = "#dd8452",
    "Plasmid" = "#4c72b0"
  )) +
  ylim(0, 100) +
  theme_minimal(base_size = 13) +
  labs(
    x = "Carbapenemase gene",
    y = "Percentage (%) of isolates",
    fill = "Genomic location",
    title = "Genomic distribution of major carbapenemase genes"
  ) +
  theme(
    legend.position = "top",
    axis.text.x = element_text(size = 12),
    
    axis.title.y = element_text(margin = margin(r = 12)),
    axis.title.x = element_text(margin = margin(t = 12)),
    
    plot.title = element_text(
      hjust = 0.5,
      margin = margin(b = 10)
    ),
    plot.title.position = "plot",
    
    plot.margin = margin(15, 15, 15, 15)
  )

# Display plot
print(p_loc)


# ===============================
# 11. Save figure
# ===============================
ggsave(
  filename = "path/to/output/gene_location_plot.png",
  plot = p_loc,
  width = 8,
  height = 4,
  dpi = 600
)