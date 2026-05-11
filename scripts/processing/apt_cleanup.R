# ============================================
# Script: Standardize Acinetobacter baumannii (BLAST) TSV outputs
#
# Purpose:
#   - Read raw TSV files (BLAST outfmt 6)
#   - Assign proper column names
#   - Save cleaned files to a new directory
# ============================================

# --------------------------------------------
# 1. Load required library
# --------------------------------------------
library(readr)

# --------------------------------------------
# 2. Define input and output paths
# --------------------------------------------

# Input folder containing raw TSV files
input_dir <- "path/to/apt_output"

# Output folder for cleaned files
output_dir <- file.path(input_dir, "cleaned")

# Create output directory if it does not exist
dir.create(output_dir, showWarnings = FALSE)

# --------------------------------------------
# 3. List all TSV files
# --------------------------------------------

# Get full paths of all TSV files
files <- list.files(input_dir, pattern = "\\.tsv$", full.names = TRUE)

# --------------------------------------------
# 4. Define column names (BLAST outfmt 6)
# --------------------------------------------

col_names <- c(
  "qseqid",
  "sseqid",
  "pident",
  "length",
  "mismatch",
  "gapopen",
  "qstart",
  "qend",
  "sstart",
  "send",
  "evalue",
  "bitscore"
)

# --------------------------------------------
# 5. Process each file
# --------------------------------------------

for (file in files) {
  
  # Read TSV file without header
  df <- read_delim(
    file,
    delim = "\t",
    col_names = FALSE,
    show_col_types = FALSE
  )
  
  # Assign BLAST column names
  colnames(df) <- col_names
  
  # Save cleaned file to output directory
  write_tsv(df, file.path(output_dir, basename(file)))
}

# --------------------------------------------
# 6. Completion message
# --------------------------------------------

cat("All files processed successfully!\n")