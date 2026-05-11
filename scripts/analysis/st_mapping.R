# ============================================
# Script: Match sample IDs to MLST sequence types
#
# Description:
#   This script:
#     (1) Reads a list of sample file paths
#     (2) Extracts clean sample IDs
#     (3) Searches for matching IDs in MLST results
#     (4) Retrieves corresponding ST types
#     (5) Creates a final mapping table
#     (6) Saves the output as a CSV file
# ============================================


# ===============================
# 1. Load required libraries
# ===============================
library(readr)
library(dplyr)


# ===============================
# 2. Read input files
# ===============================
# Text file containing sample paths
file_paths <- readLines("path/to/blaOXA-66_list.txt")

# MLST results table
data <- read_csv("path/to/mlst_results.csv")


# ===============================
# 3. Extract clean sample IDs
# ===============================
# Removes ".short.fasta" suffix and keeps base name
sample_ids <- basename(file_paths) %>%
  gsub(".short.fasta", "", .)


# ===============================
# 4. Match sample IDs to MLST data
# ===============================
# Uses grep to find ID within sample_id column

st_types <- sapply(sample_ids, function(id) {
  
  # Find matching row(s)
  idx <- grep(id, data$sample_id, fixed = TRUE)
  
  if (length(idx) > 0) {
    return(data$`ST type`[idx])
  } else {
    return(NA)  # No match found
  }
})


# ===============================
# 5. Create final mapping table
# ===============================

final_output <- data.frame(
  Sample_ID = sample_ids,
  ST_Type = as.character(st_types)
)


# ===============================
# 6. Save output
# ===============================

write_csv(
  final_output,
  "path/to/output/matched_ST_results.csv"
)


# ===============================
# 7. Preview results
# ===============================
print(head(final_output))