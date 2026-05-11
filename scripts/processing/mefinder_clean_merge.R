# ============================================
# Script: MEFinder Cleaning & Merging Pipeline
# Purpose:
#   - Clean raw MEFinder CSV outputs
#   - Standardize structure across files
#   - Add isolate identifiers (species_id)
#   - Merge all processed files into a single dataset
# ============================================

# --------------------------------------------
# 1. Load required libraries
# --------------------------------------------
library(tools)
library(dplyr)
library(readr)
library(tibble)

# --------------------------------------------
# PART 1 — CLEAN EACH MEFINDER OUTPUT FILE
# --------------------------------------------

# Define input (raw files) and output (cleaned files) directories
input_dir  <- "path/to/input/directory"
clean_dir  <- "path/to/output/directory"

# Create output directory if it does not exist
if (!dir.exists(clean_dir)) dir.create(clean_dir, recursive = TRUE)

# List all CSV files in input directory
files <- list.files(input_dir, pattern = "\\.csv$", full.names = TRUE)

# Loop through each MEFinder output file
for (f in files) {
  
  # ----------------------------------------
  # 1.1 Read file (skip metadata header)
  # ----------------------------------------
  
  # MEFinder outputs contain a 5-line metadata block → skip it
  df <- tryCatch(
    read.csv(f, skip = 5, header = TRUE, stringsAsFactors = FALSE),
    error = function(e) NULL
  )
  
  # Skip unreadable or empty files
  if (is.null(df) || nrow(df) == 0) {
    message("Skipping file (empty or unreadable): ", basename(f))
    next
  }
  
  # ----------------------------------------
  # 1.2 Add species_id from filename
  # ----------------------------------------
  
  # Extract isolate name from filename (without extension)
  species_id <- tools::file_path_sans_ext(basename(f))
  df$species_id <- species_id
  
  # Move species_id to first column for consistency
  df <- df[, c("species_id", setdiff(names(df), "species_id"))]
  
  # ----------------------------------------
  # 1.3 Save cleaned file
  # ----------------------------------------
  
  out_file <- file.path(clean_dir, paste0(species_id, "_processed.csv"))
  write.csv(df, out_file, row.names = FALSE)
  
  message("Processed: ", basename(f))
}

# --------------------------------------------
# PART 2 — MERGE ALL PROCESSED FILES
# --------------------------------------------

# Define input (cleaned files) and output (merged file)
clean_input_dir <- "path/to/input/directory"
output_file     <- "path/to/output/file"

# List all processed files
files <- list.files(clean_input_dir, pattern = "_processed.csv$", full.names = TRUE)

# Initialize master column list (starting with species_id)
all_columns <- c("species_id")

# --------------------------------------------
# 2.1 Function to fix unnamed columns
# --------------------------------------------

# Some files may contain missing/blank column names
# → replace them with generic names (X1, X2, ...)
repair_names <- function(x) {
  nm <- names(x)
  nm[nm == "" | is.na(nm)] <- paste0("X", seq_len(sum(nm == "" | is.na(nm))))
  names(x) <- nm
  x
}

# --------------------------------------------
# 2.2 Build master column structure
# --------------------------------------------

# Collect all unique column names across files
for (f in files) {
  df <- suppressMessages(read_csv(f, col_types = cols(.default = "c")))
  df <- repair_names(df)
  all_columns <- union(all_columns, names(df))
}

# --------------------------------------------
# 2.3 Merge all cleaned files
# --------------------------------------------

merged <- tibble()

for (f in files) {
  
  # Read file (force all columns as character for consistency)
  df <- suppressMessages(read_csv(f, col_types = cols(.default = "c")))
  df <- repair_names(df)
  
  # Extract species_id again (used if file is empty)
  species_id <- tools::file_path_sans_ext(basename(f))
  
  if (nrow(df) > 0) {
    
    # ------------------------------------
    # Handle missing columns
    # ------------------------------------
    
    # Add any columns missing in this file
    missing_cols <- setdiff(all_columns, names(df))
    df[missing_cols] <- NA
    
    # Reorder columns to match master structure
    df <- df[, all_columns]
    
    # Append to merged dataset
    merged <- bind_rows(merged, df)
    
    # Add blank separator row (visual separation between isolates)
    blank <- as_tibble(setNames(as.list(rep(NA, length(all_columns))), all_columns))
    merged <- bind_rows(merged, blank)
    
  } else {
    
    # ------------------------------------
    # Handle completely empty files
    # ------------------------------------
    
    empty_row <- as.list(rep(NA, length(all_columns)))
    names(empty_row) <- all_columns
    empty_row$species_id <- species_id
    
    merged <- bind_rows(merged, as_tibble(empty_row))
    
    # Add separator row
    blank <- as_tibble(setNames(as.list(rep(NA, length(all_columns))), all_columns))
    merged <- bind_rows(merged, blank)
  }
}

# --------------------------------------------
# 2.4 Final cleanup
# --------------------------------------------

# Remove trailing blank row if present
if (all(is.na(merged[nrow(merged), ]))) {
  merged <- merged[-nrow(merged), ]
}

# --------------------------------------------
# 2.5 Save merged dataset
# --------------------------------------------

write_csv(merged, output_file)

message("Merge complete! File saved to: ", output_file)