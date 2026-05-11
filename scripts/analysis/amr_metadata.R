# ============================================
# Script: Generate AMR gene context metadata
#
# Purpose:
#   - Create sample-level metadata from AMR gene table
#   - Detect presence of key resistance genes:
#       * NDM
#       * OXA-23
#       * OXA-66
#   - Assign a combined "context" label per sample
#
# NOTE:
#   - Assumes input dataframe 'amr' is already loaded
#
# Output:
#   - metadata.csv (sample-level AMR context)
# ============================================

# --------------------------------------------
# 1. Load required libraries
# --------------------------------------------
library(dplyr)
library(stringr)

# --------------------------------------------
# 2. Clean gene names
# --------------------------------------------

# Standardize gene names to lowercase for consistent matching
amr$gene_clean <- tolower(amr$`element.symbol`)

# --------------------------------------------
# 3. Create sample-level metadata
# --------------------------------------------

meta <- amr %>%
  group_by(sample_id) %>%
  summarise(
    NDM   = as.integer(any(str_detect(gene_clean, "ndm"))),
    OXA23 = as.integer(any(str_detect(gene_clean, "oxa-23"))),
    OXA66 = as.integer(any(str_detect(gene_clean, "oxa-66"))),
    .groups = "drop"
  )

# --------------------------------------------
# 4. Create combined context label
# --------------------------------------------

meta <- meta %>%
  mutate(
    context = paste0(
      ifelse(NDM == 1, "NDM+", ""),
      ifelse(OXA23 == 1, "OXA23+", ""),
      ifelse(OXA66 == 1, "OXA66+", "")
    )
  )

# --------------------------------------------
# 5. Clean formatting
# --------------------------------------------

# Remove trailing "+"
meta$context <- gsub("\\+$", "", meta$context)

# Replace empty labels with "none"
meta$context[meta$context == ""] <- "none"

# --------------------------------------------
# 6. Save output
# --------------------------------------------

write.csv(meta, "metadata.csv", row.names = FALSE)
