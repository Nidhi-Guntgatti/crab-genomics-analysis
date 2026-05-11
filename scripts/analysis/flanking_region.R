# ============================================
# Script: Gene flanking analysis
#
# Purpose:
#   - Parse GFF3 annotation files
#   - Identify target gene(s)
#   - Extract immediate upstream and downstream features
#   - Detect insertion sequences (IS elements)
#   - Calculate flanking statistics
#
# Usage:
#   - Modify gene_pattern and is_pattern as needed
#
# Examples:
#   gene_pattern <- "NDM-1"
#   gene_pattern <- "OXA-66"
#   gene_pattern <- "NDM"
#
#   is_pattern <- "ISAba24|ISVsa3|ISAba13"
#   is_pattern <- "transposase|insertion sequence"
#
# Output:
#   - Detailed flanking results
#   - Summary statistics
# ============================================

# --------------------------------------------
# 1. Load libraries
# --------------------------------------------
library(dplyr)

# --------------------------------------------
# 2. USER INPUT (EDIT THESE)
# --------------------------------------------

# Input directory containing GFF3 files
gff_dir <- "path/to/gff3_folder"

# Output files
output_file  <- "path/to/output/flanking_results.tsv"
summary_file <- "path/to/output/flanking_summary.tsv"

# Target gene pattern (regex)
gene_pattern <- "NDM-1"

# IS detection pattern (regex)
is_pattern <- "ISAba24|ISVsa3|ISAba13"

# --------------------------------------------
# 3. Initialize
# --------------------------------------------

results <- data.frame()

files <- list.files(gff_dir, pattern = "\\.gff3$", full.names = TRUE)

cat("Total GFF files found:", length(files), "\n")

# --------------------------------------------
# 4. Process each file
# --------------------------------------------

for (file in files) {
  
  sample <- basename(file)
  cat("Processing:", sample, "\n")
  
  # Read GFF3
  gff <- read.delim(file, comment.char = "#", header = FALSE, sep = "\t")
  
  colnames(gff) <- c(
    "contig","source","type","start","end",
    "score","strand","phase","attributes"
  )
  
  # ----------------------------------------
  # 4.1 Find target gene
  # ----------------------------------------
  
  gene_hits <- gff %>%
    filter(grepl(gene_pattern, attributes, ignore.case = TRUE))
  
  if (nrow(gene_hits) == 0) {
    cat("No match found in:", sample, "\n")
    next
  }
  
  # ----------------------------------------
  # 4.2 Process each gene occurrence
  # ----------------------------------------
  
  for (i in 1:nrow(gene_hits)) {
    
    gene_row <- gene_hits[i,]
    
    same_contig <- gff %>%
      filter(contig == gene_row$contig) %>%
      arrange(start)
    
    # Robust index detection
    idx <- which.min(abs(same_contig$start - gene_row$start))
    
    if (length(idx) == 0) next
    
    # ----------------------------------------
    # 4.3 Get neighbors
    # ----------------------------------------
    
    upstream   <- if (idx > 1) same_contig[idx - 1, ] else NULL
    downstream <- if (idx < nrow(same_contig)) same_contig[idx + 1, ] else NULL
    
    up_name   <- if (!is.null(upstream)) upstream$attributes else NA
    down_name <- if (!is.null(downstream)) downstream$attributes else NA
    
    # ----------------------------------------
    # 4.4 Detect IS elements
    # ----------------------------------------
    
    up_IS <- if (!is.null(upstream)) {
      grepl(is_pattern, upstream$attributes, ignore.case = TRUE)
    } else FALSE
    
    down_IS <- if (!is.null(downstream)) {
      grepl(is_pattern, downstream$attributes, ignore.case = TRUE)
    } else FALSE
    
    # ----------------------------------------
    # 4.5 Store results
    # ----------------------------------------
    
    results <- rbind(results, data.frame(
      sample = sample,
      contig = gene_row$contig,
      gene_start = gene_row$start,
      gene_end = gene_row$end,
      upstream_feature = up_name,
      downstream_feature = down_name,
      upstream_IS = up_IS,
      downstream_IS = down_IS,
      flanked = up_IS & down_IS
    ))
  }
}

cat("Total rows in results:", nrow(results), "\n")

# --------------------------------------------
# 5. Save outputs
# --------------------------------------------

if (nrow(results) > 0) {
  
  write.table(
    results,
    file = output_file,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
  )
  
  summary_table <- results %>%
    summarise(
      total_genes = n(),
      flanked_count = sum(flanked),
      percent_flanked = round((flanked_count / total_genes) * 100, 2)
    )
  
  write.table(
    summary_table,
    file = summary_file,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
  )
  
  cat("Done!\n")
  cat("Detailed results:", output_file, "\n")
  cat("Summary:", summary_file, "\n")
  
} else {
  cat("No results found — check patterns or input data\n")
}