# ============================================
# Script: Transpose allele results TSV file
# Purpose: 
#   - Load a TSV file containing allele data
#   - Transpose the dataset (swap rows and columns)
#   - Set the first row as column headers
#   - Save the transposed output as a new TSV file
# ============================================

# --------------------------------------------
# 1. Install and load required packages
# --------------------------------------------

# Install 'readxl' (NOTE: not actually used in this script)
# install.packages("readxl")
install.packages("readxl")  # Required for excel files

# Load 'readr' for reading TSV files
library(readr)

# --------------------------------------------
# 2. Read the input TSV file
# --------------------------------------------

# Define the file path to the allele results file
file_path <- "your/input/path/here"

# Read the TSV file into a dataframe
df <- read_tsv(file_path)

# --------------------------------------------
# 3. Transpose the dataset
# --------------------------------------------

# Transpose the dataframe (rows <-> columns)
# t() returns a matrix, so convert back to dataframe
df_transposed <- as.data.frame(t(df))

# --------------------------------------------
# 4. Set column names from first row
# --------------------------------------------

# Use the first row of the transposed data as column headers
colnames(df_transposed) <- df_transposed[1, ]

# Remove the first row (now redundant since it's header)
df_transposed <- df_transposed[-1, ]

# --------------------------------------------
# 5. Save the transposed data
# --------------------------------------------

# Write the dataframe to a TSV file
# col.names = NA ensures proper formatting for row names
write.table(
  df_transposed,
  file = "transposed_results.tsv",
  sep = "\t",
  row.names = TRUE,
  col.names = NA,
  quote = FALSE
)
