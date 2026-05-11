# ============================================
# Script: Convert MOB-suite contig reports to TSV
#
# Purpose:
#   - Recursively locate contig_report files (.text / .txt)
#   - Handle empty or malformed files safely
#   - Convert all files to standardized TSV format
#   - Rename outputs based on parent folder (sample ID)
#
# NOTE:
#   - Update input/output paths before running
#
# Output:
#   - Individual TSV files for each sample
# ============================================

# --------------------------------------------
# 1. Define input and output paths
# --------------------------------------------

# Input directory (MOB-suite outputs)
source_dir <- "path/to/mobsuite_output"

# Output directory
output_dir <- "path/to/output/contig_report"

# Create output directory if it does not exist
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# --------------------------------------------
# 2. Locate input files
# --------------------------------------------

# Find all contig_report files (recursive search)
all_files <- list.files(
  path = source_dir,
  pattern = "contig_report\\.(text|txt)$",
  full.names = TRUE,
  recursive = TRUE
)

# Debug: check number of files found
cat("Number of files found:", length(all_files), "\n")

# Stop if no files found
if (length(all_files) == 0) {
  stop("No files found! Check your 'source_dir' path or file naming.")
}

# --------------------------------------------
# 3. Process each file
# --------------------------------------------

for (file_path in all_files) {
  
  # Extract parent folder name (used as sample ID)
  parent_folder <- basename(dirname(file_path))
  
  # Create output filename
  new_filename <- paste0(parent_folder, "_contig_report.tsv")
  dest_path <- file.path(output_dir, new_filename)
  
  # ----------------------------------------
  # 3.1 Skip empty files
  # ----------------------------------------
  
  if (file.info(file_path)$size == 0) {
    message("Skipping empty file: ", file_path)
    next
  }
  
  # ----------------------------------------
  # 3.2 Read file safely
  # ----------------------------------------
  
  data <- tryCatch({
    read.table(
      file_path,
      header = TRUE,
      sep = "\t",
      fill = TRUE,           # handle missing columns
      quote = "",            # avoid quote parsing issues
      stringsAsFactors = FALSE
    )
  }, error = function(e) {
    message("Error reading: ", file_path, " - ", e$message)
    return(NULL)
  })
  
  # ----------------------------------------
  # 3.3 Write output
  # ----------------------------------------
  
  if (!is.null(data) && nrow(data) > 0) {
    
    write.table(
      data,
      dest_path,
      sep = "\t",
      row.names = FALSE,
      quote = FALSE
    )
    
    cat("Created:", new_filename, "\n")
    
  } else {
    message("No valid data in: ", file_path)
  }
}
