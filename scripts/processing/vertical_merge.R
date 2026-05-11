# ============================================
# Script: Merge all sample output files
#
# Purpose:
#   - Read multiple CSV/TSV files from a directory
#   - Standardize column types (all as character)
#   - Combine all files into a single dataset
#
# NOTE:
#   - Handles mixed file formats (.csv and .tsv)
#   - Ensures consistent data types across files
#
# Output:
#   - final_all_samples_combined.csv
# ============================================

# --------------------------------------------
# 1. Load required libraries
# --------------------------------------------
library(dplyr)
library(readr)
library(purrr)

# --------------------------------------------
# 2. Define input and output paths
# --------------------------------------------

# Folder containing merged sample files
merged_dir <- "path/to/files"

# Output file
output_file <- "path/to/output/file/combined.csv"

# --------------------------------------------
# 3. List input files
# --------------------------------------------

# Include both CSV and TSV files
files <- list.files(
  merged_dir,
  pattern = "\\.csv$|\\.tsv$",
  full.names = TRUE
)

# --------------------------------------------
# 4. Define file reader function
# --------------------------------------------

# Read files with all columns as character
read_file <- function(file) {
  
  if (grepl("\\.csv$", file)) {
    
    df <- read_csv(file, col_types = cols(.default = "c"))
    
  } else {
    
    df <- read_delim(file, delim = "\t", col_types = cols(.default = "c"))
  }
  
  return(df)
}

# --------------------------------------------
# 5. Combine all files
# --------------------------------------------

final_combined <- map_dfr(files, read_file)

# --------------------------------------------
# 6. Save output
# --------------------------------------------

write_csv(final_combined, output_file)

# --------------------------------------------
# 7. Completion message
# --------------------------------------------

cat("All files merged successfully!\n")
cat("Output file:", output_file, "\n")