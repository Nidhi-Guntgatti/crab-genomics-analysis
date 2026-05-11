# ============================================
# Script: Map sample names to regions
#
# Purpose:
#   - Read a list of sample names from a text file
#   - Match them with an Excel dataset
#   - Extract region information
#   - Save mapped results to a new Excel file
# ============================================

# --------------------------------------------
# 1. Load required libraries
# --------------------------------------------
library(readxl)
library(writexl)
library(dplyr)
library(tidyr)

# --------------------------------------------
# 2. Load sample names from text file
# --------------------------------------------

# Creates dataframe with column: Sample_Name
names_to_find <- data.frame(
  Sample_Name = readLines("path/to/ndm.txt"),
  stringsAsFactors = FALSE
)

# --------------------------------------------
# 3. Load Excel dataset
# --------------------------------------------

excel_data <- read_excel("path/to/set_1_data.xlsx")

# --------------------------------------------
# 4. Process and map samples to regions
# --------------------------------------------

result <- excel_data %>%
  
  # Extract Region from 'Region.Province.Department'
  separate(
    col = `Region.Province.Department`,
    into = c("Region"),
    sep = "\\.",
    extra = "drop",
    remove = FALSE
  ) %>%
  
  # Join with sample list
  # NOTE: Replace "Name" with actual column name in Excel if different
  inner_join(names_to_find, by = c("Name" = "Sample_Name")) %>%
  
  # Select final columns
  select(
    Sample_Name = Name,
    Region
  )

# --------------------------------------------
# 5. Save output
# --------------------------------------------

write_xlsx(result, "path/to/output/final_mapped_output.xlsx")

cat("Done! Matching samples have been mapped to their regions.\n")