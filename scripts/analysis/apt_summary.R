# ============================================
# Script: Plasmid replicon summary (APT output)
#
# Description:
#   This script:
#     (1) Reads all plasmid BLAST output files
#     (2) Combines them into a single dataset
#     (3) Filters high-confidence hits (identity + length)
#     (4) Selects best hit per plasmid per sample
#     (5) Summarizes plasmid replicon frequency
#     (6) Calculates percentage across all samples
# ============================================


# ===============================
# 1. Load required libraries
# ===============================
library(dplyr)
library(readr)
library(purrr)
library(stringr)


# ===============================
# 2. Define input directory
# ===============================
# Folder containing cleaned plasmid BLAST outputs
dir_path <- "path/to/apt_output/cleaned"


# ===============================
# 3. List all files
# ===============================
files <- list.files(dir_path, full.names = TRUE)


# ===============================
# 4. Read and tag each file
# ===============================
# Adds sample ID based on filename

read_plasmid <- function(file) {
  df <- read_tsv(file, show_col_types = FALSE)
  
  df$sample <- basename(file)
  
  return(df)
}

# Combine all samples into one dataframe
plasmid_data <- map_dfr(files, read_plasmid)


# ===============================
# 5. Filter high-confidence hits
# ===============================
# Keep hits with:
#   - ≥95% identity
#   - ≥500 bp alignment length

plasmid_filtered <- plasmid_data %>%
  filter(pident >= 95, length >= 500)


# ===============================
# 6. Select best hit per sample
# ===============================
# Uses highest bitscore for each plasmid target

plasmid_best <- plasmid_filtered %>%
  group_by(sample, sseqid) %>%
  slice_max(bitscore, n = 1) %>%
  ungroup()


# ===============================
# 7. Summarize plasmid frequency
# ===============================
# Counts how often each replicon appears

plasmid_summary <- plasmid_best %>%
  group_by(qseqid) %>%
  summarise(count = n()) %>%
  arrange(desc(count))


# ===============================
# 8. Calculate percentage
# ===============================
# Assumes total number of samples = 650

plasmid_summary <- plasmid_summary %>%
  mutate(percent = (count / 650) * 100)


# ===============================
# 9. Preview results
# ===============================
head(plasmid_summary)