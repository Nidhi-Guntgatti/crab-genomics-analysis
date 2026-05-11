# ============================================
# Script: Merge AMRFinder output files
# Purpose:
#   - Read multiple AMRFinder TSV result files
#   - Extract sample IDs from filenames
#   - Append sample_id to each dataset
#   - Merge all files into a single combined table
#
# ============================================

# --------------------------------------------
# 1. Load required library
# --------------------------------------------
library(dplyr)

# --------------------------------------------
# 2. Define input directory
# --------------------------------------------

# Folder containing AMRFinder TSV files
input_dir <- "/your/input/path/here"

# --------------------------------------------
# 3. List all AMRFinder output files
# --------------------------------------------

# Select files ending with "_amrfinder.tsv"
files <- list.files(input_dir, pattern = "_amrfinder\\.tsv$", full.names = TRUE)

# --------------------------------------------
# 4. Read and process each file
# --------------------------------------------

# Loop through files and:
#   - extract sample ID from filename
#   - read TSV file
#   - add sample_id column
#   - return processed dataframe
merged_data <- lapply(files, function(f) {
  
  # Extract sample ID (remove suffix "_amrfinder.tsv")
  sample_id <- sub("_amrfinder\\.tsv$", "", basename(f))
  
  # Read TSV file
  df <- read.delim(f, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  # Add sample_id as first column
  df <- cbind(sample_id = sample_id, df)
  
  return(df)
  
}) %>%
  # Combine all dataframes into one
  bind_rows()

# --------------------------------------------
# 5. Save merged output
# --------------------------------------------

# Write merged dataset as TSV file
write.table(
  merged_data,
  "/your/output/path here",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)