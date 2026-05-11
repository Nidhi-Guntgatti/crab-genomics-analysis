# ============================================
# Script: Clean MEFinder merged dataset (sample_id fix)
#
# Purpose:
#   - Load merged MEFinder dataset
#   - Standardize column names
#   - Clean and normalize sample_id values
#   - Ensure compatibility with AMR dataset for merging
#
# ============================================

# --------------------------------------------
# 1. Load required library
# --------------------------------------------
library(dplyr)

# --------------------------------------------
# 2. Read merged MEFinder dataset
# --------------------------------------------

df <- read.csv(
  "/path/to/merged/file",
  stringsAsFactors = FALSE
)

# --------------------------------------------
# 3. Standardize column names
# --------------------------------------------

# Convert all column names to lowercase and trim whitespace
# → avoids merge errors due to case/spacing inconsistencies
colnames(df) <- tolower(trimws(colnames(df)))

# --------------------------------------------
# 4. Clean sample_id values
# --------------------------------------------

# Remove:
#   - trailing whitespace
#   - "_mefinder" suffix from sample_id
#
# Example:
#   "ABC123_mefinder" → "ABC123"
#
# This ensures consistency with AMRFinder sample IDs
df$sample_id <- sub("_mefinder$", "", trimws(df$sample_id))

# --------------------------------------------
# 5. Save cleaned dataset
# --------------------------------------------

write.table(
  df,
  "/path/to/cleaned/ouput/file",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)