# Load libraries
library(readr)
library(dplyr)
library(ggplot2)

# Define paths
input_file <- "/data/internship_data/nidhi/aba/output/mobsuite_output/merged/replicon_summary.tsv"
output_dir <- "/data/internship_data/nidhi/aba/output/mobsuite_output/merged"

# Read replicon summary file
rep_summary <- read_tsv(input_file, show_col_types = FALSE)

# Remove NA and "-" rows, then filter clusters with count > 10
rep_filt <- rep_summary %>%
  filter(!is.na(rep_type_s_)) %>% 
  filter(rep_type_s_ != "-") %>% 
  filter(count > 10)

# Wrap only labels that contain multiple clusters (comma)
label_wrap <- function(x) {
  sapply(x, function(label) {
    # If the label contains a comma → split into new lines
    if (grepl(",", label)) {
      return(gsub(",", "\n", label))
    } else {
      return(label)  # Leave single labels unchanged
    }
  })
}

# Plot
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

# Show plot
print(p)

# Save PNG in same directory
ggsave(
  filename = file.path(output_dir, "replicon_clusters_gt10.png"),
  plot = p,
  width = 14,
  height = 7,
  dpi = 300
)

