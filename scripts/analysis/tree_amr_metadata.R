# ============================================
# Script: Generate and clean tree label metadata
#
# Purpose:
#   - Convert metadata into tree-compatible label format
#   - Append ".short.fasta" to sample IDs
#   - Retain AMR context labels
#   - Standardize naming (e.g., NDM → NDM1)
#
# NOTE:
#   - Update input/output paths before running
#
# Output:
#   - labels.tsv (for phylogenetic annotation)
# ============================================

# --------------------------------------------
# 1. Load metadata
# --------------------------------------------

df <- read.csv("path/to/metadata.csv", stringsAsFactors = FALSE)

# --------------------------------------------
# 2. Create label dataframe
# --------------------------------------------

labels_df <- data.frame(
  taxa = paste0(df$sample_id, ".short.fasta"),
  context = df$context,
  stringsAsFactors = FALSE
)

# --------------------------------------------
# 3. Clean / standardize context labels
# --------------------------------------------

# Fix common naming inconsistencies
labels_df$context <- gsub("ndm11", "NDM1", labels_df$context, ignore.case = TRUE)
labels_df$context <- gsub("ndm1", "NDM1", labels_df$context, ignore.case = TRUE)

# --------------------------------------------
# 4. Save output
# --------------------------------------------

write.table(
  labels_df,
  "path/to/output/labels.tsv",
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)

# --------------------------------------------
# 5. Preview output
# --------------------------------------------

head(labels_df)