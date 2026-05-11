# ============================================
# Script: Contig-level merge of AMR, MGE, APT, and MOB data
#
# Purpose:
#   - For each sample:
#       * Load AMR, MGE, plasmid (APT), and MOB data
#       * Standardize contig IDs
#       * Merge datasets at contig level
#   - Combine all samples into one final dataset
#
# Output:
#   - final_amr_mge_apt_mob.csv
# ============================================

# --------------------------------------------
# 1. Load required libraries
# --------------------------------------------
library(dplyr)
library(readr)
library(stringr)
library(purrr)

# --------------------------------------------
# 2. Define input folders
# --------------------------------------------

amr_dir <- "path/to/amrfinder_cleaned_tsvs"
mge_dir <- "path/to/mefinder_cleaned_csv"
plasmid_dir <- "path/to/apt_cleaned"
mob_dir <- "path/to/mobsuite_contig_report"

# --------------------------------------------
# 3. List AMR files (anchor dataset)
# --------------------------------------------

amr_files <- list.files(amr_dir, pattern = "\\.tsv$", full.names = TRUE)

# --------------------------------------------
# 4. Helper: extract contig ID
# --------------------------------------------

# Extract first token from contig string (e.g., contig00001)
extract_contig <- function(x) {
  str_extract(x, "^\\S+")
}

# --------------------------------------------
# 5. Function: process one sample
# --------------------------------------------

process_sample <- function(amr_file) {
  
  # Extract sample ID from filename
  sample_id <- str_extract(basename(amr_file), "^[^_]+")
  cat("Processing:", sample_id, "\n")
  
  # ----------------------------------------
  # 5.1 Locate matching files
  # ----------------------------------------
  
  mge_file <- list.files(mge_dir, pattern = sample_id, full.names = TRUE)[1]
  plasmid_file <- list.files(plasmid_dir, pattern = sample_id, full.names = TRUE)[1]
  mob_file <- list.files(mob_dir, pattern = sample_id, full.names = TRUE)[1]
  
  # Check for missing files
  if (is.na(mge_file) | is.na(plasmid_file) | is.na(mob_file)) {
    cat("⚠️ Missing files for:", sample_id, "\n")
    return(NULL)
  }
  
  # ----------------------------------------
  # 5.2 Read datasets
  # ----------------------------------------
  
  amr <- read_delim(amr_file, "\t", show_col_types = FALSE)
  mge <- read_csv(mge_file, show_col_types = FALSE)
  plasmid <- read_delim(plasmid_file, "\t", show_col_types = FALSE)
  mob <- read_delim(mob_file, "\t", show_col_types = FALSE)
  
  # ----------------------------------------
  # 5.3 Standardize contig column (AMR)
  # ----------------------------------------
  
  amr <- amr %>%
    rename(contig_id = `Contig id`)
  
  # ----------------------------------------
  # 5.4 Standardize contig column (APT)
  # ----------------------------------------
  
  if ("sseqid" %in% colnames(plasmid)) {
    plasmid <- plasmid %>%
      rename(contig_id = sseqid)
  } else if ("contig_id" %in% colnames(plasmid)) {
    # already correct
  } else {
    cat("❌ APT contig column missing:", sample_id, "\n")
    return(NULL)
  }
  
  # ----------------------------------------
  # 5.5 Clean MGE contig IDs
  # ----------------------------------------
  
  mge <- mge %>%
    rename(contig_id = contig) %>%
    mutate(contig_id = extract_contig(contig_id))
  
  # ----------------------------------------
  # 5.6 Clean MOB contig IDs
  # ----------------------------------------
  
  if ("contig_id" %in% colnames(mob)) {
    mob <- mob %>%
      mutate(contig_id = extract_contig(contig_id))
  } else if ("contig" %in% colnames(mob)) {
    mob <- mob %>%
      rename(contig_id = contig) %>%
      mutate(contig_id = extract_contig(contig_id))
  } else {
    cat("❌ MOB contig column missing:", sample_id, "\n")
    return(NULL)
  }
  
  # ----------------------------------------
  # 5.7 Ensure contig_id is character
  # ----------------------------------------
  
  amr$contig_id <- as.character(amr$contig_id)
  mge$contig_id <- as.character(mge$contig_id)
  plasmid$contig_id <- as.character(plasmid$contig_id)
  mob$contig_id <- as.character(mob$contig_id)
  
  # ----------------------------------------
  # 5.8 Optional: select best plasmid hit
  # ----------------------------------------
  
  if ("bitscore" %in% colnames(plasmid)) {
    plasmid <- plasmid %>%
      group_by(contig_id) %>%
      slice_max(bitscore, n = 1, with_ties = FALSE) %>%
      ungroup()
  }
  
  # ----------------------------------------
  # 5.9 Merge datasets (AMR as anchor)
  # ----------------------------------------
  
  merged <- amr %>%
    left_join(mge, by = "contig_id") %>%
    left_join(plasmid, by = "contig_id") %>%
    left_join(mob, by = "contig_id")
  
  # ----------------------------------------
  # 5.10 Add sample ID
  # ----------------------------------------
  
  merged <- merged %>%
    mutate(sample_id = sample_id)
  
  # ----------------------------------------
  # 5.11 Prevent type mismatch
  # ----------------------------------------
  
  merged <- merged %>%
    mutate(across(everything(), as.character))
  
  return(merged)
}

# --------------------------------------------
# 6. Process all samples
# --------------------------------------------

final_all_samples <- map_dfr(amr_files, process_sample)

# --------------------------------------------
# 7. Save output
# --------------------------------------------

write_csv(final_all_samples, "path/to/output/final_amr_mge_apt_mob.csv")

# --------------------------------------------
# 8. Completion message
# --------------------------------------------

cat("DONE — correct contig-level merge\n")