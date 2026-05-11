# ============================================
# Script: Co-occurrence of AMR genes and IS elements
#
# Description:
#   This script:
#     (1) Loads AMR gene data and IS element data
#     (2) Combines both datasets into a unified table
#     (3) Creates a presence/absence matrix
#     (4) Selects key AMR genes and top IS elements
#     (5) Calculates % co-occurrence between genes and IS
#     (6) Converts results into a matrix format
#     (7) Generates a heatmap with percentage values
#     (8) Saves a publication-ready figure
# ============================================


# ===============================
# 1. Load required libraries
# ===============================
library(tidyverse)
library(pheatmap)
library(grid)


# ===============================
# 2. Load AMR data
# ===============================
# Extract sample ID and AMR gene name
amr <- read_tsv("path/to/amr_merged_cleaned.tsv") %>%
  select(sample_id, element = `Element symbol`) %>%
  distinct()


# ===============================
# 3. Load IS element data
# ===============================
# Extract sample ID and IS element name
is_data <- read_csv("path/to/me_merged_output.csv") %>%
  select(sample_id, element = name) %>%   # adjust column if needed
  distinct()

# Optional check:
# colnames(is_data)


# ===============================
# 4. Combine AMR and IS datasets
# ===============================
# Stack both datasets into a single table
df_all <- bind_rows(amr, is_data)


# ===============================
# 5. Create presence/absence matrix
# ===============================
# Convert to binary format (1 = present, 0 = absent)
presence <- df_all %>%
  mutate(present = 1) %>%
  pivot_wider(
    names_from = element,
    values_from = present,
    values_fill = 0
  )


# ===============================
# 6. Define genes and IS elements
# ===============================
# Key carbapenemase genes
genes_of_interest <- c("blaNDM-1", "blaOXA-23", "blaOXA-66")

# Extract IS elements based on column names
is_elements <- colnames(presence) %>%
  str_subset("^IS")

# Select top 5 most frequent IS elements
is_elements <- colSums(presence[, is_elements, drop = FALSE]) %>%
  sort(decreasing = TRUE) %>%
  head(5) %>%
  names()


# ===============================
# 7. Compute % co-occurrence
# ===============================
# For each gene, calculate percentage of isolates co-occurring with each IS
heatmap_data <- map_dfr(genes_of_interest, function(gene) {
  
  total_gene <- sum(presence[[gene]] == 1)
  
  map_dfr(is_elements, function(is) {
    
    co_occurrence <- sum(
      presence[[gene]] == 1 &
        presence[[is]] == 1
    )
    
    tibble(
      Gene = gene,
      IS = is,
      Percent = (co_occurrence / total_gene) * 100
    )
  })
})


# ===============================
# 8. Convert to matrix format
# ===============================
mat <- heatmap_data %>%
  pivot_wider(names_from = IS, values_from = Percent) %>%
  column_to_rownames("Gene") %>%
  as.matrix()

# Replace missing values with 0
mat[is.na(mat)] <- 0


# ===============================
# 9. Generate heatmap
# ===============================
# Create heatmap object (silent = TRUE for custom drawing)
ph <- pheatmap(
  mat,
  silent = TRUE,
  color = colorRampPalette(c("#ffffff", "#9ecae1", "#08519c"))(100),
  breaks = seq(0, 100, length.out = 101),
  display_numbers = TRUE,
  number_format = "%.1f",
  number_color = "black",
  cluster_rows = FALSE,
  cluster_cols = FALSE,
  angle_col = 45,
  border_color = NA,
  fontsize = 11,
  main = "Co-occurrence of carbapenemase genes and insertion sequences (%)"
)

# Optional: display in R session
print(ph)


# ===============================
# 10. Save heatmap as PNG
# ===============================
png(
  filename = "path/to/output/is_heatmap.png",
  width = 10,
  height = 6,
  units = "in",
  res = 600
)

# White background
grid.newpage()
grid.rect(gp = gpar(fill = "white", col = NA))

# Adjust margins and centering
pushViewport(viewport(
  width = 0.75,
  height = 0.80,
  x = 0.52,
  y = 0.48
))

# Draw heatmap
grid.draw(ph$gtable)

# Close device
dev.off()