# ============================================
# Script: Distance between two specific genes (blaOXA-66 and ISVsa3 used here)
#
# Purpose:
#   - Parse GFF3 annotation files (Bakta output)
#   - Identify locations of:
#       * gene 1 (blaOXA-66 - carbapenemase gene) 
#       * gene 1 (ISVsa3 - insertion sequence)
#   - Calculate genomic distance between them
#   - Determine whether they occur on the same contig
#
# Output:
#   - Table of pairwise distances per sample
# ============================================

# --------------------------------------------
# 1. Load required libraries
# --------------------------------------------
library(dplyr)
library(stringr)

# --------------------------------------------
# 2. Define input directory
# --------------------------------------------

# Folder containing GFF3 files
gff_dir <- "/path/to/gff3/folder"

# List all GFF3 files
files <- list.files(gff_dir, pattern = "\\.gff3$", full.names = TRUE)

# Initialize empty results dataframe
results <- data.frame()

# --------------------------------------------
# 3. Process each GFF3 file
# --------------------------------------------

for (file in files) {
  
  # ----------------------------------------
  # 3.1 Read and preprocess GFF3
  # ----------------------------------------
  
  # Read all lines and remove comment lines (#)
  lines <- readLines(file)
  lines <- lines[!grepl("^#", lines)]
  
  # Extract sample ID from filename
  sample_id <- sub("\\.gff3$", "", basename(file))
  
  # Split GFF3 fields (tab-delimited)
  split_lines <- strsplit(lines, "\t")
  
  # Extract key fields:
  #   - contig ID
  #   - start and end coordinates
  #   - attribute column (annotations)
  df <- data.frame(
    contig = sapply(split_lines, `[`, 1),
    start  = as.numeric(sapply(split_lines, `[`, 4)),
    end    = as.numeric(sapply(split_lines, `[`, 5)),
    attr   = sapply(split_lines, `[`, 9),
    stringsAsFactors = FALSE
  )
  
  # ----------------------------------------
  # 3.2 Extract annotation fields
  # ----------------------------------------
  
  # Extract 'product' annotation
  df$product <- str_extract(df$attr, "product=[^;]+")
  df$product <- sub("product=", "", df$product)
  
  # Extract 'Name' annotation (sometimes contains gene name)
  df$name <- str_extract(df$attr, "Name=[^;]+")
  df$name <- sub("Name=", "", df$name)
  
  # Combine both fields for robust matching
  df$product <- paste(df$product, df$name)
  
  # ----------------------------------------
  # 3.3 Identify features of interest
  # ----------------------------------------
  
  # Locate blaOXA-66
  oxa66 <- df %>%
    filter(str_detect(product, regex("OXA-66", ignore_case = TRUE)))
  
  # Locate ISVsa3 insertion sequence
  isvsa3 <- df %>%
    filter(str_detect(product, regex("ISVsa3", ignore_case = TRUE)))
  
  # Skip sample if either feature is absent
  if (nrow(oxa66) == 0 | nrow(isvsa3) == 0) next
  
  # ----------------------------------------
  # 3.4 Compute pairwise distances
  # ----------------------------------------
  
  # Compare all OXA-66 and ISVsa3 combinations
  for (i in 1:nrow(oxa66)) {
    for (j in 1:nrow(isvsa3)) {
      
      # Check if both are on the same contig
      same_contig <- oxa66$contig[i] == isvsa3$contig[j]
      
      # Calculate minimum distance between gene boundaries
      distance <- min(
        abs(oxa66$start[i] - isvsa3$end[j]),
        abs(oxa66$end[i] - isvsa3$start[j])
      )
      
      # Store result
      results <- rbind(results, data.frame(
        sample_id = sample_id,
        oxa66_contig = oxa66$contig[i],
        isvsa3_contig = isvsa3$contig[j],
        same_contig = same_contig,
        oxa66_start = oxa66$start[i],
        oxa66_end = oxa66$end[i],
        isvsa3_start = isvsa3$start[j],
        isvsa3_end = isvsa3$end[j],
        distance_bp = distance
      ))
    }  
  }
}

# --------------------------------------------
# 4. Save output
# --------------------------------------------

output_file <- "/path/to/output/distance/file"

# Handle case with no matches
if (nrow(results) == 0) {
  writeLines("No OXA-66 + ISVsa3 matches found", output_file)
  print("No matches found — check contig distribution.")
} else {
  write.table(
    results,
    output_file,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
  )
  print("Results written successfully!")
}