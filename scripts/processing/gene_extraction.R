# ============================================
# Script: Extract MGE profiles from isolates carrying specific genes (blaOXA-23 isolates used here)
#
# Purpose:
#   - Identify isolates carrying blaOXA-23
#   - Subset merged AMR + ME dataset for these isolates
#   - Extract associated mobile genetic elements (MGEs)
#   - Summarize MGEs per isolate
#
# ============================================

# --------------------------------------------
# 1. Load required library
# --------------------------------------------
library(dplyr)

# --------------------------------------------
# 2. Read list of blaOXA-23 positive samples
# --------------------------------------------

# Input file contains one sample_id per line
sample_list <- read.delim(
  "/path/to/text/file/containing/sample/ids",
  header = FALSE,
  stringsAsFactors = FALSE
)

# Assign column name
colnames(sample_list) <- "sample_id"

# --------------------------------------------
# 3. Load merged AMR + ME dataset
# --------------------------------------------

merged <- read.delim(
  "/path/to/amr_me_merged/file",
  stringsAsFactors = FALSE
)

# --------------------------------------------
# 4. Standardize column names
# --------------------------------------------

# Convert to lowercase, trim whitespace, and ensure uniqueness
# → prevents issues from duplicate column names after merging
colnames(merged) <- make.unique(tolower(trimws(colnames(merged))))

# --------------------------------------------
# 5. Identify correct sample_id column
# --------------------------------------------

# Find all columns containing "sample"
sample_cols <- grep("sample", colnames(merged), value = TRUE)
print(sample_cols)

# Inspect candidate columns manually
for (col in sample_cols) {
  cat("\nChecking column:", col, "\n")
  print(head(merged[[col]]))
}

# IMPORTANT:
# After inspection, manually confirm correct column name
sample_col <- "sample_id"   # ← change if needed (e.g., "sample_id.1")

# --------------------------------------------
# 6. Filter dataset for blaOXA-23 isolates
# --------------------------------------------

filtered <- merged %>%
  filter(.data[[sample_col]] %in% sample_list$sample_id)

# --------------------------------------------
# 7. Extract MGE information per isolate
# --------------------------------------------

# Steps:
#   - Remove rows without MGE annotation (name column)
#   - Keep unique sample–MGE pairs
#   - Collapse multiple MGEs per sample into a single string
mge_per_sample <- filtered %>%
  filter(!is.na(name)) %>%   # 'name' = MGE identifier
  select(sample_id = .data[[sample_col]], name) %>%
  distinct() %>%
  group_by(sample_id) %>%
  summarise(
    mge_list = paste(unique(name), collapse = ", "),
    .groups = "drop"
  )

# --------------------------------------------
# 8. Save output
# --------------------------------------------

write.table(
  mge_per_sample,
  "path/to/output/file",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)

# --------------------------------------------
# 9. Completion message
# --------------------------------------------

print("MGE extraction completed successfully!")