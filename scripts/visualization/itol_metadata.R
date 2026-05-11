# ============================================
# Script: Generate iTOL TREE_COLORS (range)
#
# Purpose:
#   - Assign specific colors to each context group
#   - Create range-style annotation for iTOL
# ============================================

# --------------------------------------------
# 1. Load data
# --------------------------------------------

df <- read.delim(
  "path/to/labels.tsv",
  sep = "\t",
  header = TRUE,
  check.names = FALSE
)

# --------------------------------------------
# 2. Define color palette
# --------------------------------------------

my_colors <- c(
  "#F9C6C9", "#F9DCC4", "#D6D7AC",
  "#AAC4BB", "#C7CEEA", "#CEE5ED", "#998CA2"
)

# --------------------------------------------
# 3. Clean context and extract groups
# --------------------------------------------

df$context <- trimws(as.character(df$context))

unique_groups <- unique(df$context[df$context != "none"])

# Map groups → colors
color_map <- setNames(
  my_colors[1:length(unique_groups)],
  unique_groups
)

# --------------------------------------------
# 4. Assign colors
# --------------------------------------------

df$mapped_color <- color_map[df$context]
df$mapped_color[df$context == "none"] <- "#FFFFFF"

# --------------------------------------------
# 5. Prepare TREE_COLORS range dataset
# --------------------------------------------

range_header <- c("TREE_COLORS", "SEPARATOR COMMA", "DATA")

range_df <- data.frame(
  id = df$taxa,
  type = "range",
  color = df$mapped_color,
  label = df$context,
  stringsAsFactors = FALSE
)

# --------------------------------------------
# 6. Write output file
# --------------------------------------------

file_path <- "path/to/output/itol_specific_ranges.txt"

file_conn <- file(file_path, "w")

writeLines(range_header, file_conn)

write.table(
  range_df,
  file_conn,
  sep = ",",
  row.names = FALSE,
  col.names = FALSE,
  append = TRUE,
  quote = FALSE
)

close(file_conn)

message("Success! Colors assigned to groups: ", paste(unique_groups, collapse = ", "))