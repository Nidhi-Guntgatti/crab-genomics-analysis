# ============================================
# Script: Generate sample ID list from FASTA files
#
# Purpose:
#   - Extract sample IDs from FASTA filenames
#   - Remove file extensions
#   - Save list of sample IDs to a text file
#
# ============================================

# --------------------------------------------
# 1. Define input folder
# --------------------------------------------

folder <- "/path/to/fasta/files/folder"

# --------------------------------------------
# 2. List all FASTA files
# --------------------------------------------

# Get all files ending with ".fasta"
files <- list.files(folder, pattern = "\\.fasta$", full.names = FALSE)

# --------------------------------------------
# 3. Extract sample IDs
# --------------------------------------------

# Remove ".fasta" extension from filenames
# Example: "sample123.fasta" → "sample123"
sample_ids <- sub("\\.fasta$", "", files)

# --------------------------------------------
# 4. Save sample ID list
# --------------------------------------------

# Write one sample ID per line (no quotes, no row/column names)
write.table(
  sample_ids,
  file = "/path/to/text/file",
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE
)