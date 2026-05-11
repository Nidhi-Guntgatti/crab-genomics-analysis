# ============================================
# Script: Collect GFF3 files for gene (blaNDM-1) samples
#
# Purpose:
#   - Read list of blaNDM-1 positive sample IDs
#   - Locate corresponding Bakta output folders
#   - Extract GFF3 files for each sample
#   - Copy them into a single directory
#
# NOTE:
#   - Update input/output paths before running
#
# Output:
#   - Consolidated GFF3 files for blaNDM-1 isolates
# ============================================

# --------------------------------------------
# 1. Define input and output paths
# --------------------------------------------

# File containing sample IDs (one per line)
sample_file <- "path/to/blaNDM-1_list.txt"

# Base directory containing Bakta output folders
base_dir <- "path/to/bakta_output"

# Output directory for collected GFF3 files
output_dir <- "path/to/output/gff3/NDM-1"

# Create output directory if it does not exist
dir.create(output_dir, showWarnings = FALSE)

# --------------------------------------------
# 2. Read sample list
# --------------------------------------------

samples <- readLines(sample_file)

# --------------------------------------------
# 3. Loop through samples and extract GFF3
# --------------------------------------------

for (s in samples) {
  
  # Construct sample folder path
  sample_path <- file.path(base_dir, s)
  
  # ----------------------------------------
  # 3.1 Check if sample folder exists
  # ----------------------------------------
  
  if (!dir.exists(sample_path)) {
    cat("Folder not found:", s, "\n")
    next
  }
  
  # ----------------------------------------
  # 3.2 Locate GFF3 file
  # ----------------------------------------
  
  gff_file <- list.files(sample_path, pattern = "\\.gff3$", full.names = TRUE)
  
  if (length(gff_file) == 0) {
    cat("No GFF3 found in:", s, "\n")
    next
  }
  
  # If multiple GFF3 files exist, use the first
  gff_file <- gff_file[1]
  
  # ----------------------------------------
  # 3.3 Copy file to output directory
  # ----------------------------------------
  
  # Output filename uses original sample ID
  dest_file <- file.path(output_dir, paste0(s, ".gff3"))
  
  file.copy(gff_file, dest_file, overwrite = TRUE)
  
  cat("Copied:", s, "\n")
}
