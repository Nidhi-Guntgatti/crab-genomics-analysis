# ============================================
# Script: Upstream IS detection for blaOXA-66
#
# Purpose:
#   - Identify insertion sequences (IS elements)
#     located upstream of blaOXA-66 genes
#   - Compute distances within a defined window
#
# Output:
#   - CSV with upstream IS annotations
# ============================================

# --------------------------------------------
# 1. Load required libraries
# --------------------------------------------
library(dplyr)
library(readr)

# --------------------------------------------
# 2. Load input data
# --------------------------------------------

# AMR gene annotations
genes <- read_delim(
  "path/to/amr_merged_cleaned.tsv",
  delim = "\t",
  show_col_types = FALSE
)

# IS element annotations (MEFinder)
is_elements <- read_csv(
  "path/to/me_merged_output.csv",
  show_col_types = FALSE
)

# --------------------------------------------
# 3. Standardize column names
# --------------------------------------------

genes <- genes %>%
  rename(
    start = `Start`,
    end = `Stop`,
    strand = `Strand`,
    contig_id = `Contig id`,
    gene = `Element symbol`
  )

is_elements <- is_elements %>%
  rename(
    start = start,
    end = end,
    contig_id = contig,
    is_name = name
  )

# --------------------------------------------
# 4. Ensure correct data types
# --------------------------------------------

genes <- genes %>%
  mutate(
    start = as.numeric(start),
    end = as.numeric(end),
    strand = as.character(strand),
    contig_id = as.character(contig_id)
  )

is_elements <- is_elements %>%
  mutate(
    start = as.numeric(start),
    end = as.numeric(end),
    contig_id = as.character(contig_id)
  )

# --------------------------------------------
# 5. Define upstream search window (bp)
# --------------------------------------------

window <- 10000

# --------------------------------------------
# 6. Filter for target gene (blaOXA-66)
# --------------------------------------------

genes <- genes %>%
  filter(gene == "blaOXA-66")

# --------------------------------------------
# 7. Identify upstream IS elements
# --------------------------------------------

genes <- genes %>%
  rowwise() %>%
  mutate(
    upstream_IS = {
      
      # Subset IS elements on the same contig
      is_sub <- is_elements %>%
        filter(contig_id == contig_id)
      
      # Strand-specific upstream logic
      if (strand == "+") {
        
        hits <- is_sub %>%
          filter(end < start & (start - end) <= window) %>%
          mutate(distance = start - end)
        
      } else if (strand == "-") {
        
        hits <- is_sub %>%
          filter(start > end & (start - end) <= window) %>%
          mutate(distance = start - end)
        
      } else {
        hits <- data.frame()
      }
      
      # Format output
      if (nrow(hits) > 0) {
        paste(hits$is_name, "(dist:", hits$distance, ")", collapse = "; ")
      } else {
        "NO"
      }
    }
  ) %>%
  ungroup()

# --------------------------------------------
# 8. Save results
# --------------------------------------------

write_csv(
  genes,
  "path/to/output/blaOXA66_upstream_IS.csv"
)

# --------------------------------------------
# 9. Quick summary
# --------------------------------------------

table(genes$upstream_IS)

cat("Done — blaOXA-66 upstream IS analysis complete\n")