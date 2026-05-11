# ============================================
# Script: AMR + Mobile Element (MEFinder) Merge
#
# Purpose:
#   - Load AMRFinder and MEFinder merged outputs
#   - Standardize column names across datasets
#   - Handle potential file format inconsistencies
#   - Merge datasets using sample_id
#   - Generate a unified dataset for downstream analysis

# ============================================

# --------------------------------------------
# 1. Load required library
# --------------------------------------------
library(dplyr)

# --------------------------------------------
# 2. Read input files
# --------------------------------------------

# AMR dataset (AMRFinder merged output)
amr <- read.delim(
  "/your/amrfinder/output/path",
  stringsAsFactors = FALSE
)

# ME dataset (MEFinder merged output)
# Initially read as tab-delimited (expected format)
me <- read.delim(
  "/your/mefinder/output/path",
  sep = "\t",
  stringsAsFactors = FALSE
)

# --------------------------------------------
# 3. Standardize column names
# --------------------------------------------

# Convert all column names to lowercase and trim whitespace
# → ensures consistent merging (avoids case/spacing mismatches)
colnames(amr) <- tolower(trimws(colnames(amr)))
colnames(me)  <- tolower(trimws(colnames(me)))

# --------------------------------------------
# 4. Verify column structures
# --------------------------------------------

# Print column names for manual inspection/debugging
print("AMR columns:")
print(colnames(amr))

print("ME columns:")
print(colnames(me))

# --------------------------------------------
# 5. Merge datasets
# --------------------------------------------

# Left join ensures:
#   - all AMR entries are retained
#   - ME data is added where available
#   - unmatched ME entries are ignored
merged <- amr %>%
  left_join(me, by = "sample_id")

# --------------------------------------------
# 6. Save merged dataset
# --------------------------------------------

write.table(
  merged,
  "/your/output/path",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)

# --------------------------------------------
# 7. Completion message
# --------------------------------------------

print("Merge completed successfully!")