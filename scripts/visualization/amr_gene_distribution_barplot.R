library(readr)
library(dplyr)
library(ggplot2)

# Input file
input_file <- "/data/internship_data/nidhi/aba/output/amrfinder_output/gene_level_AMR_frequency.csv"

# Read data
df <- read_csv(input_file, show_col_types = FALSE)

# Filter AMR genes present in more than 20 isolates
df_filt <- df %>%
  filter(Isolate_Count > 20) %>%
  arrange(desc(Isolate_Count))

# Plot
p <- ggplot(df_filt, aes(x = reorder(`Element symbol`, -Isolate_Count),
                         y = Isolate_Count)) +
  geom_bar(stat = "identity", fill = "orange") +
  labs(
    title = "Presence of AMR Genes",
    x = "AMR Gene",
    y = "Number of Isolates"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text.x = element_text(size = 12, angle = 90, vjust = 0.5, hjust = 1),
    axis.text.y = element_text(size = 12)
  )

# Show plot
print(p)

# Save PNG in same directory as input
ggsave(
  filename = "/data/internship_data/nidhi/aba/output/amrfinder_output/AMR_genes_gt20.png",
  plot = p,
  width = 12,
  height = 6,
  dpi = 300
)
