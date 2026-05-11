# ============================================
# Script: MLST + PopPUNK + Kaptive Integration
#
# Purpose:
#   - Load typing outputs from multiple tools:
#       * MLST (sequence type information)
#       * PopPUNK (clonal clusters)
#       * Kaptive KL (capsule locus typing)
#       * Kaptive OCL (outer core locus typing)
#   - Standardize sample identifiers across datasets
#   - Merge all typing information into a unified table
#   - Generate a combined dataset for downstream analysis
#
# Output:
#   - A merged CSV file containing:
#       * Sample ID
#       * MLST information
#       * PopPUNK cluster assignment
#       * KL type and confidence
#       * OCL type and confidence
#
# Notes:
#   - File paths must be updated before running
#   - Sample IDs are extracted using regex (G[0-9]+)
#   - All merges are performed using sample_id
# ============================================


# ===============================
# 1. Load required libraries
# ===============================
library(dplyr)
library(readr)
library(stringr)


# ===============================
# 2. Define input file paths
# ===============================
# NOTE: Update these paths before running

mlst_file    <- "path/to/MLST_with_IC.csv"
poppunk_file <- "path/to/query_assignment_clusters.csv"
kaptive_kl   <- "path/to/KL_results.tsv"
kaptive_oc   <- "path/to/OC_results.tsv"


# ===============================
# 3. Load input datasets
# ===============================

# MLST results
mlst <- read_csv(mlst_file, show_col_types = FALSE)

# PopPUNK clustering results
poppunk <- read_csv(
  poppunk_file,
  col_types = cols(
    Taxon = col_character(),
    Cluster = col_character()
  )
)

# Kaptive KL typing
kl <- read_tsv(kaptive_kl, show_col_types = FALSE)

# Kaptive OCL typing
oc <- read_tsv(kaptive_oc, show_col_types = FALSE)


# ===============================
# 4. Extract and standardize sample IDs
# ===============================

# MLST → extract sample ID from file path
mlst <- mlst %>%
  mutate(
    sample_id = str_extract(file, "G[0-9]+"),
    file = sample_id   # replace long path with clean ID
  )

# PopPUNK → extract sample ID and rename cluster
poppunk <- poppunk %>%
  mutate(
    sample_id = str_extract(Taxon, "G[0-9]+"),
    poppunk_cluster = Cluster
  ) %>%
  select(sample_id, poppunk_cluster)

# Kaptive KL → extract locus and confidence
kl <- kl %>%
  mutate(
    sample_id = str_extract(`Assembly`, "G[0-9]+"),
    KL = `Best match locus`,
    KL_confidence = `Match confidence`
  ) %>%
  select(sample_id, KL, KL_confidence)

# Kaptive OCL → extract locus and confidence
oc <- oc %>%
  mutate(
    sample_id = str_extract(`Assembly`, "G[0-9]+"),
    OCL = `Best match locus`,
    OCL_confidence = `Match confidence`
  ) %>%
  select(sample_id, OCL, OCL_confidence)


# ===============================
# 5. Merge all datasets
# ===============================
# Combine all typing information using sample_id

merged <- mlst %>%
  left_join(poppunk, by = "sample_id") %>%
  left_join(kl,      by = "sample_id") %>%
  left_join(oc,      by = "sample_id")


# ===============================
# 6. Save merged output
# ===============================

out_path <- "path/to/mlst_poppunk_kaptive_merged.csv"

write_csv(merged, out_path)


# ===============================
# 7. Print summary
# ===============================

cat("\n✔ Merged file saved at:", out_path, "\n")
cat("✔ Rows:", nrow(merged), " | Columns:", ncol(merged), "\n")
