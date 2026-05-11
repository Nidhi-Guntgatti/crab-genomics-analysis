# ============================================
# Script: Replicon cluster visualization
# Purpose:
#   - Load MOB-suite replicon summary output
#   - Filter for valid and abundant replicon clusters
#   - Improve readability of cluster labels
#   - Generate a bar plot of replicon cluster counts
#   - Save the plot as a high-resolution PNG
# ============================================

# --------------------------------------------
# 1. Load required libraries
# --------------------------------------------
library(readr)
library(dplyr)
library(ggplot2)

# --------------------------------------------
# 2. Define input and output paths
# --------------------------------------------

# Input: replicon summary file from MOB-suite
input_file <- "your/input/path/here"

# Output directory for saving plots
output_dir <- "your/output/path/here"

# --------------------------------------------
# 3. Load replicon summary data
# --------------------------------------------

# Read TSV file; suppress column type messages
rep_summary <- read_tsv(input_file, show_col_types = FALSE)

# --------------------------------------------
# 4. Filter replicon clusters
# --------------------------------------------

# Steps:
#   - Remove rows with missing replicon type (NA)
#   - Remove placeholder values ("-")
#   - Retain only clusters with count > 10 (focus on dominant replicons)
rep_filt <- rep_summary %>%
  filter(!is.na(rep_type_s_)) %>% 
  filter(rep_type_s_ != "-") %>% 
  filter(count > 10)

# --------------------------------------------
# 5. Improve label readability
# --------------------------------------------

# Function to wrap labels containing multiple cluster names
# (comma-separated values → split into multiple lines)
label_wrap <- function(x) {
  sapply(x, function(label) {
    if (grepl(",", label)) {
      return(gsub(",", "\n", label))  # Replace commas with line breaks
    } else {
      return(label)  # Keep single labels unchanged
    }
  })
}

# --------------------------------------------
# 6. Generate bar plot
# --------------------------------------------

# Plot count of replicon clusters
#   - X-axis: replicon cluster type (ordered by count)
#   - Y-axis: frequency (count)
p <- ggplot(rep_filt, aes(x = reorder(rep_type_s_, -count), y = count)) +
  geom_bar(stat = "identity", fill = "olivedrab3") +
  scale_x_discrete(labels = label_wrap) +
  labs(
    title = "Replicon Clusters",
    x = "Replicon Cluster",
    y = "Count"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text.x = element_text(size = 12, angle = 90, vjust = 0.5, hjust = 1),
    axis.text.y = element_text(size = 12)
  )

# --------------------------------------------
# 7. Display plot
# --------------------------------------------

print(p)

# --------------------------------------------
# 8. Save plot to file
# --------------------------------------------

# Save as high-resolution PNG
ggsave(
  filename = file.path(output_dir, "replicon_clusters_gt10.png"),
  plot = p,
  width = 14,
  height = 7,
  dpi = 300
)