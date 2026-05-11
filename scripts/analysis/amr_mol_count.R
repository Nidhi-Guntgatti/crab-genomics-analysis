# ============================================
# Script: AMR–MGE association summary
#
# Purpose:
#   - Load merged AMR + MGE dataset
#   - Standardize gene names
#   - Detect presence of mobile genetic elements (MGEs)
#   - Filter key AMR genes (NDM-1, OXA-23, OXA-66)
#   - Summarize counts by gene, molecule type, and MGE status
#
# NOTE:
#   - Update input path before running
#
# Output:
#   - Summary table printed to console
# ============================================

# --------------------------------------------
# 1. Load required libraries
# --------------------------------------------
library(dplyr)
library(stringr)
library(readr)

# --------------------------------------------
# 2. Load dataset
# --------------------------------------------

input_file <- "path/to/final_all_samples_combined.csv"

df <- read_csv(input_file, col_types = cols(.default = "c"))

# --------------------------------------------
# 3. Clean gene names
# --------------------------------------------

df <- df %>%
  mutate(
    gene_clean = tolower(`Element symbol`)
  )

# --------------------------------------------
# 4. Create MGE presence flag
# --------------------------------------------

df <- df %>%
  mutate(
    has_MGE = ifelse(
      !is.na(name) & str_detect(tolower(prediction), "insertion sequence"),
      1, 0
    )
  )

# --------------------------------------------
# 5. Filter AMR genes of interest
# --------------------------------------------

amr_focus <- df %>%
  filter(str_detect(gene_clean, "ndm-1|oxa-23|oxa-66"))

# --------------------------------------------
# 6. Generate summary table
# --------------------------------------------

summary_table <- amr_focus %>%
  group_by(`Element symbol`, molecule_type, has_MGE) %>%
  summarise(count = n(), .groups = "drop")

# --------------------------------------------
# 7. Print results
# --------------------------------------------

print(summary_table)