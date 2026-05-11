# ============================================
# Script: AMR gene heatmap with MDR/XDR annotation
#
# Description:
#   This script:
#     (1) Loads AMR gene data
#     (2) Maps genes to antibiotic classes
#     (3) Creates a presence/absence matrix
#     (4) Selects top 20 most frequent AMR genes
#     (5) Classifies isolates as MDR/XDR/Non-MDR
#     (6) Prepares sample annotations
#     (7) Generates a heatmap with annotations
#     (8) Saves a high-resolution publication figure
# ============================================


# ===============================
# 1. Load required libraries
# ===============================
library(tidyverse)
library(pheatmap)


# ===============================
# 2. Load AMR data
# ===============================
# Input should contain sample_id and Element symbol
amr <- read_tsv("path/to/amr_merged_cleaned.tsv")


# ===============================
# 3. Map genes to antibiotic classes
# ===============================
# Assigns each gene to a functional drug class
amr <- amr %>%
  mutate(
    drug_class = case_when(
      str_detect(`Element symbol`, "bla") ~ "Beta-lactam",
      str_detect(`Element symbol`, "aph|ant|armA") ~ "Aminoglycoside",
      str_detect(`Element symbol`, "tet") ~ "Tetracycline",
      str_detect(`Element symbol`, "sul") ~ "Sulfonamide",
      str_detect(`Element symbol`, "qac") ~ "Disinfectant",
      str_detect(`Element symbol`, "fos") ~ "Fosfomycin",
      str_detect(`Element symbol`, "msr|mph") ~ "Macrolide",
      TRUE ~ "Other"
    )
  )


# ===============================
# 4. Create presence/absence matrix
# ===============================
# Keep unique gene presence per sample
amr_clean <- amr %>%
  select(sample_id, `Element symbol`) %>%
  distinct()

# Convert to binary matrix (1 = present, 0 = absent)
amr_matrix <- amr_clean %>%
  mutate(present = 1) %>%
  pivot_wider(
    names_from = `Element symbol`,
    values_from = present,
    values_fill = 0
  )

# Convert to matrix format
mat <- amr_matrix %>%
  column_to_rownames("sample_id")


# ===============================
# 5. Select top 20 AMR genes
# ===============================
# Based on frequency across isolates
top_genes <- colSums(mat) %>%
  sort(decreasing = TRUE) %>%
  head(20) %>%
  names()

mat_top <- mat[, top_genes]


# ===============================
# 6. Compute MDR/XDR classification
# ===============================
# Count number of drug classes per isolate
mdr_xdr <- amr %>%
  select(sample_id, drug_class) %>%
  distinct() %>%
  group_by(sample_id) %>%
  summarise(n_classes = n_distinct(drug_class))

# Total number of unique classes
total_classes <- length(unique(amr$drug_class))

# Apply classification rules
mdr_xdr <- mdr_xdr %>%
  mutate(
    Epidemiology = case_when(
      n_classes >= (total_classes - 2) ~ "XDR",
      n_classes >= 3 ~ "MDR",
      TRUE ~ "Non-MDR"
    )
  )

# Check distribution
table(mdr_xdr$Epidemiology)


# ===============================
# 7. Prepare annotation data
# ===============================
# Create annotation dataframe for heatmap
sample_ann <- mdr_xdr %>%
  select(sample_id, Epidemiology) %>%
  column_to_rownames("sample_id")

# Ensure row order matches heatmap matrix
sample_ann <- sample_ann[rownames(mat_top), , drop = FALSE]


# ===============================
# 8. Define annotation colors
# ===============================
ann_colors <- list(
  Epidemiology = c(
    "Non-MDR" = "#d9d9d9",
    "MDR"     = "#f39c12",
    "XDR"     = "#a56cb9"
  )
)


# ===============================
# 9. Generate heatmap and save
# ===============================
png(
  "path/to/output/amr_heatmap.png",
  width = 11,
  height = 6.2,
  units = "in",
  res = 600
)

library(grid)

# Create heatmap object
p <- pheatmap(
  mat_top,
  color = c("#d9d9d9", "#01698c"),
  breaks = c(0, 0.5, 1),
  legend_breaks = c(0, 1),
  legend_labels = c("Absent", "Present"),
  annotation_row = sample_ann,
  annotation_colors = ann_colors,
  show_rownames = FALSE,
  cluster_rows = FALSE,
  border_color = NA,
  fontsize_col = 10,
  main = "Presence of major AMR genes across isolates"
)

# Print
print(p)

# Adjust margins and draw heatmap
grid.newpage()
pushViewport(viewport(width = 0.9, height = 0.9))
grid.draw(p$gtable)

# Close device
dev.off()