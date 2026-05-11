# ============================================
# Script: QUAST and CheckM summary extraction
#
# Description:
#   This script:
#     (1) Reads QUAST summary reports from multiple samples
#     (2) Extracts key assembly metrics (genome size, contigs, N50, GC)
#     (3) Combines all QUAST outputs into a single table
#     (4) Reads CheckM summary files
#     (5) Extracts completeness and contamination metrics
#     (6) Combines all CheckM outputs into a single table
#     (7) Saves both cleaned datasets for downstream analysis
# ============================================


# ===============================
# 1. Load required libraries
# ===============================
library(tidyverse)
library(stringr)


# ===============================
# 2. Define QUAST input directory
# ===============================
quast_dir <- "path/to/quast_summary"


# ===============================
# 3. List all QUAST report files
# ===============================
quast_files <- list.files(
  quast_dir,
  pattern = "report.tsv",
  recursive = TRUE,
  full.names = TRUE
)


# ===============================
# 4. Function to extract QUAST metrics
# ===============================
extract_quast <- function(file) {
  
  # Read QUAST report
  df <- read_tsv(file, show_col_types = FALSE)
  
  # Convert wide format to long format
  df_long <- df %>%
    pivot_longer(-Assembly, names_to = "metric", values_to = "value")
  
  # Extract key assembly statistics
  genome_size <- df_long %>%
    filter(Assembly == "Total length (>= 0 bp)") %>%
    pull(value)
  
  contigs <- df_long %>%
    filter(Assembly == "# contigs (>= 0 bp)") %>%
    pull(value)
  
  N50 <- df_long %>%
    filter(Assembly == "N50") %>%
    pull(value)
  
  GC <- df_long %>%
    filter(Assembly == "GC (%)") %>%
    pull(value)
  
  # Extract sample name from column name
  sample <- colnames(df)[2]
  
  # Return formatted output
  tibble(
    sample = sample,
    genome_size = as.numeric(genome_size) / 1e6,  # convert to Mb
    contigs = as.numeric(contigs),
    N50 = as.numeric(N50),
    GC = as.numeric(GC)
  )
}


# ===============================
# 5. Combine all QUAST results
# ===============================
quast_combined <- map_dfr(quast_files, extract_quast)


# ===============================
# 6. Save QUAST summary
# ===============================
write_csv(quast_combined, "path/to/output/quast_clean.csv")


# ===============================
# 7. Define CheckM input directory
# ===============================
checkm_dir <- "path/to/checkm_summary"


# ===============================
# 8. List all CheckM files
# ===============================
checkm_files <- list.files(
  checkm_dir,
  pattern = "\\.tsv$",
  full.names = TRUE
)


# ===============================
# 9. Function to extract CheckM metrics
# ===============================
extract_checkm <- function(file) {
  
  # Read CheckM output
  df <- read_tsv(file, show_col_types = FALSE)
  
  # Each file contains one row (single sample)
  df <- df[1, ]
  
  # Extract key metrics
  tibble(
    sample = df$Name,
    completeness = df$Completeness,
    contamination = df$Contamination
  )
}


# ===============================
# 10. Combine all CheckM results
# ===============================
checkm_combined <- map_dfr(checkm_files, extract_checkm)


# ===============================
# 11. Save CheckM summary
# ===============================
write_csv(checkm_combined, "path/to/output/checkm_clean.csv")