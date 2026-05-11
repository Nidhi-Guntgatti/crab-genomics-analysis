library(ggplot2)
library(readr)
library(dplyr)
library(stringr)

# Load AMR class summary file
amr_class_summary <- read_tsv("/home/nidhi/projects/analysis/AMR_class_summary.tsv",
                              show_col_types = FALSE)

# Replace "/" with " /\n" to force proper line break
amr_class_summary$AMR_class_wrapped <- gsub("/", " /\n", amr_class_summary$AMR_class)

# Also wrap long names (secondary wrap)
amr_class_summary$AMR_class_wrapped <- str_wrap(amr_class_summary$AMR_class_wrapped, width = 12)

# Plot
p <- ggplot(amr_class_summary, 
            aes(x = reorder(AMR_class_wrapped, -No_of_isolates), 
                y = No_of_isolates)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  labs(
    title = "Distribution of AMR Classes Across Isolates",
    x = "AMR Class",
    y = "Number of Isolates with AMR Genes"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
    axis.text.x = element_text(size = 12, angle = 90, vjust = 0.5, hjust = 1),
    axis.text.y = element_text(size = 12)
  )

print(p)

# Save plot
ggsave(
  filename = "/home/nidhi/projects/analysis/AMR_class_distribution.png",
  plot = p,
  width = 12,
  height = 6,
  dpi = 300
)
