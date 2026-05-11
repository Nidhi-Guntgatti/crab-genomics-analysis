# ============================================
# Script: IS element co-occurrence heatmap
#
# Description:
#   This script:
#     (1) Loads MEFinder output data
#     (2) Converts IS presence into a binary matrix
#     (3) Calculates co-occurrence between IS elements
#     (4) Selects top 15 most frequent IS elements
#     (5) Generates a clustered heatmap
#     (6) Saves a publication-ready PNG with title
# ============================================


# ===============================
# 1. Install packages (run once)
# ===============================
install.packages(c("readr", "dplyr", "tidyr", "pheatmap"))


# ===============================
# 2. Load required libraries
# ===============================
library(readr)
library(dplyr)
library(tidyr)
library(pheatmap)
library(grid)   # Required for custom plotting


# ===============================
# 3. Load MEFinder data
# ===============================
# Input should contain sample_id and IS element names
data <- read_csv("path/to/me_merged_output.csv")


# ===============================
# 4. Prepare presence/absence matrix
# ===============================
# Keep relevant columns and remove duplicates
data <- data %>%
  select(sample_id, name) %>%
  filter(!is.na(name)) %>%
  distinct(sample_id, name)

# Convert to binary matrix (1 = present, 0 = absent)
matrix_df <- data %>%
  mutate(value = 1) %>%
  pivot_wider(
    names_from = name,
    values_from = value,
    values_fill = 0
  )

# Convert to matrix format for calculations
mat <- as.matrix(matrix_df[, -1])
rownames(mat) <- matrix_df$sample_id


# ===============================
# 5. Compute co-occurrence matrix
# ===============================
# Matrix multiplication gives co-occurrence counts
co_matrix <- t(mat) %*% mat

# Remove self-counts (diagonal)
diag(co_matrix) <- NA

# Identify top 15 most frequent IS elements
is_counts <- colSums(mat)
top_is <- names(sort(is_counts, decreasing = TRUE))[1:15]

# Subset matrix to top IS elements
co_matrix <- co_matrix[top_is, top_is]


# ===============================
# 6. Generate heatmap object
# ===============================
# silent = TRUE allows custom plotting later
p <- pheatmap(
  co_matrix,
  color = colorRampPalette(c("white", "orange", "red"))(100),
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  silent = TRUE
)

# Optional: display in R
print(p)


# ===============================
# 7. Save heatmap as PNG
# ===============================
png(
  "path/to/output/IS_cooccurrence_heatmap.png",
  width = 1400,
  height = 1200,
  res = 150
)

# Create new plotting page
grid::grid.newpage()

# Define layout: title + plot
pushViewport(grid::viewport(layout = grid::grid.layout(
  nrow = 2, ncol = 1,
  heights = grid::unit(c(0.1, 0.9), "npc")
)))

# Add title
pushViewport(grid::viewport(layout.pos.row = 1))
grid::grid.text(
  "Co-occurrence of insertion sequences in CRAB isolates",
  gp = grid::gpar(fontsize = 18, fontface = "bold")
)
upViewport()

# Draw heatmap
pushViewport(grid::viewport(layout.pos.row = 2))
grid::grid.draw(p$gtable)
upViewport(2)

# Close device
dev.off()


# ===============================
# 8. Confirm output
# ===============================
file.exists("path/to/output/IS_cooccurrence_heatmap.png")