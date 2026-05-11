# ============================================
# Script: Phylogenetic distance vs AMR context
#
# Purpose:
#   - Load phylogenetic tree (Parsnp output)
#   - Compute pairwise genetic distances
#   - Integrate AMR metadata (context labels)
#   - Compare distances between:
#       * same AMR context
#       * different AMR context
#   - Perform statistical testing (Wilcoxon test)
#
# NOTE:
#   - Update input paths before running
#
# Output:
#   - Summary statistics printed to console
#   - Wilcoxon test result
# ============================================

# --------------------------------------------
# 1. Load required libraries
# --------------------------------------------
library(ape)
library(dplyr)

# --------------------------------------------
# 2. Read phylogenetic tree
# --------------------------------------------
tree <- read.tree("path/to/parsnp.tree")

# --------------------------------------------
# 3. Clean sample names in tree
# --------------------------------------------
tree$tip.label <- gsub("\\.short\\.fasta$", "", tree$tip.label)
tree$tip.label <- gsub("\\.fasta$", "", tree$tip.label)
tree$tip.label <- gsub(".*/", "", tree$tip.label)

# --------------------------------------------
# 4. Compute pairwise distance matrix
# --------------------------------------------
dist_matrix <- cophenetic.phylo(tree)

# --------------------------------------------
# 5. Load metadata
# --------------------------------------------
meta <- read.csv("path/to/metadata.csv", stringsAsFactors = FALSE)

# --------------------------------------------
# 6. Convert matrix to long-format dataframe
# --------------------------------------------
dist_df <- as.data.frame(as.table(dist_matrix))
colnames(dist_df) <- c("sample1", "sample2", "distance")

# --------------------------------------------
# 7. Remove self-comparisons + duplicates
# --------------------------------------------

# REMOVE duplicates (A-B and B-A)
dist_df <- dist_df %>%
  filter(sample1 < sample2)

# --------------------------------------------
# 8. Merge metadata
# --------------------------------------------
dist_df <- dist_df %>%
  left_join(meta, by = c("sample1" = "sample_id")) %>%
  rename(context1 = context) %>%
  left_join(meta, by = c("sample2" = "sample_id")) %>%
  rename(context2 = context)

# --------------------------------------------
# 9. Check for mismatches (IMPORTANT)
# --------------------------------------------
cat("Missing context1:\n")
print(table(is.na(dist_df$context1)))

cat("Missing context2:\n")
print(table(is.na(dist_df$context2)))

# OPTIONAL: remove mismatched samples
dist_df <- dist_df %>%
  filter(!is.na(context1) & !is.na(context2))

# --------------------------------------------
# 10. Define comparison groups
# --------------------------------------------
dist_df <- dist_df %>%
  mutate(group = ifelse(context1 == context2, "same", "different"))

# --------------------------------------------
# 11. Summary statistics
# --------------------------------------------
dist_summary <- dist_df %>%
  group_by(group) %>%
  summarise(
    mean_distance = mean(distance),
    median_distance = median(distance),
    n = n(),
    .groups = "drop"
  )

print(dist_summary)

# --------------------------------------------
# 12. Statistical test
# --------------------------------------------

# Wilcoxon rank-sum test
wilcox_result <- wilcox.test(distance ~ group, data = dist_df)

print(wilcox_result)