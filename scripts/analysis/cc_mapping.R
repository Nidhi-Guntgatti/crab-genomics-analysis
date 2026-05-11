# ============================================
# Script: Match sample paths to PopPUNK clonal clusters
#
# Description:
#   This script:
#     (1) Reads a list of sample file paths
#     (2) Loads PopPUNK cluster assignment data
#     (3) Matches each sample to its clonal cluster
#     (4) Creates a mapping table
#     (5) Prints and optionally saves the results
# ============================================


# ===============================
# 1. Load required library
# ===============================
library(readr)


# ===============================
# 2. Read input files
# ===============================
# Text file containing full sample paths
sample_list <- readLines(
  "path/to/blaNDM-1_list.txt"
)

# PopPUNK cluster assignment table
data <- read_csv(
  "path/to/query_assignment_clusters.csv",
  show_col_types = FALSE
)


# ===============================
# 3. Match samples to clusters
# ===============================
# Finds matching row indices based on exact string match
row_indices <- match(sample_list, data$Name)


# ===============================
# 4. Create output table
# ===============================
# Extract clonal cluster information using matched indices
final_output <- data.frame(
  Full_Path = sample_list,
  Clonal_Cluster = data$`Clonal Cluster`[row_indices],
  stringsAsFactors = FALSE   # safe, non-breaking
)


# ===============================
# 5. View results
# ===============================
print(final_output)


# ===============================
# 6. Save output (optional)
# ===============================
write_csv(
  final_output,
  "path/to/output/blaNDM1_clonal_clusters.csv"
)