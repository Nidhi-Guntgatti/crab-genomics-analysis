# ============================================
# Script: Assembly quality visualization (QUAST + CheckM)
#
# Description:
#   This script:
#     (1) Loads QUAST and CheckM summary tables
#     (2) Standardizes column names for consistency
#     (3) Merges both datasets by sample ID
#     (4) Selects and cleans relevant QC metrics
#     (5) Creates a faceted boxplot + jitter visualization
#     (6) Generates additional distribution and correlation plots
#     (7) Saves publication-ready figures
# ============================================


# ===============================
# 0. Install packages (run once)
# ===============================
install.packages("janitor")
install.packages("ggbeeswarm")


# ===============================
# 1. Load required libraries
# ===============================
library(tidyverse)
library(patchwork)
library(janitor)
library(stringr)
library(ggbeeswarm)


# ===============================
# 2. Load input datasets
# ===============================
# QUAST summary
quast  <- read_csv("path/to/quast_clean.csv")

# CheckM summary
checkm <- read_csv("path/to/checkm_clean.csv")


# ===============================
# 3. Standardize column names
# ===============================
# Convert all column names to lowercase + consistent format
quast  <- quast  %>% clean_names()
checkm <- checkm %>% clean_names()


# ===============================
# 4. Merge datasets
# ===============================
# Combine QUAST and CheckM metrics by sample ID
df <- left_join(quast, checkm, by = "sample")


# ===============================
# 5. Inspect column names (optional)
# ===============================
print(colnames(df))


# ===============================
# 6. Select relevant QC metrics
# ===============================
# Use flexible matching to handle naming inconsistencies
df_plot <- df %>%
  select(
    sample,
    genome_size,
    n50,
    matches("contig"),
    matches("^gc"),
    matches("completeness"),
    matches("contamination")
    # ============================================
    # Script: Assembly quality visualization (QUAST + CheckM)
    #
    # Description:
    #   This script:
    #     (1) Loads QUAST and CheckM summary tables
    #     (2) Standardizes column names for consistency
    #     (3) Merges both datasets by sample ID
    #     (4) Selects and cleans relevant QC metrics
    #     (5) Creates a faceted boxplot + jitter visualization
    #     (6) Generates additional distribution and correlation plots
    #     (7) Saves publication-ready figures
    # ============================================
    
    
    # ===============================
    # 0. Install packages (run once)
    # ===============================
    install.packages("janitor")
    install.packages("ggbeeswarm")
    
    
    # ===============================
    # 1. Load required libraries
    # ===============================
    library(tidyverse)
    library(patchwork)
    library(janitor)
    library(stringr)
    library(ggbeeswarm)
    
    
    # ===============================
    # 2. Load input datasets
    # ===============================
    # QUAST summary
    quast  <- read_csv("path/to/quast_clean.csv")
    
    # CheckM summary
    checkm <- read_csv("path/to/checkm_clean.csv")
    
    
    # ===============================
    # 3. Standardize column names
    # ===============================
    # Convert all column names to lowercase + consistent format
    quast  <- quast  %>% clean_names()
    checkm <- checkm %>% clean_names()
    
    
    # ===============================
    # 4. Merge datasets
    # ===============================
    # Combine QUAST and CheckM metrics by sample ID
    df <- left_join(quast, checkm, by = "sample")
    
    
    # ===============================
    # 5. Inspect column names (optional)
    # ===============================
    print(colnames(df))
    
    
    # ===============================
    # 6. Select relevant QC metrics
    # ===============================
    # Use flexible matching to handle naming inconsistencies
    df_plot <- df %>%
      select(
        sample,
        genome_size,
        n50,
        matches("contig"),
        matches("^gc"),
        matches("completeness"),
        matches("contamination")
      )
    
    
    # ===============================
    # 7. Clean column names
    # ===============================
    # Standardize metric names for plotting
    df_plot <- df_plot %>%
      rename_with(~str_replace_all(., "x_contigs.*", "contigs")) %>%
      rename_with(~str_replace_all(., "gc.*", "gc"))
    
    
    # ===============================
    # 8. Convert to long format
    # ===============================
    df_long <- df_plot %>%
      pivot_longer(-sample, names_to = "metric", values_to = "value")
    
    
    # ===============================
    # 9. Rename metrics for display
    # ===============================
    df_long$metric <- recode(
      df_long$metric,
      completeness = "Completeness",
      contamination = "Contamination",
      contigs = "Contigs",
      gc = "GC (%)",
      genome_size = "Genome size (Mb)",
      n50 = "N50"
    )
    
    
    # ===============================
    # 10. Define color palette
    # ===============================
    teal <- "#01698c"
    red  <- "#e74c3c"
    bg   <- "#f7f7f7"
    
    
    # ===============================
    # 11. Create QC summary plot
    # ===============================
    p_qc <- ggplot(df_long, aes(x = "", y = value)) +
      geom_boxplot(
        fill = "white",
        color = "black",
        outlier.shape = NA,
        width = 0.5
      ) +
      geom_jitter(
        width = 0.3,
        height = 0,
        color = teal,
        alpha = 0.35,
        size = 0.8
      ) +
      stat_summary(
        fun = mean,
        geom = "point",
        color = red,
        size = 2
      ) +
      facet_wrap(~metric, scales = "free_y", ncol = 3) +
      theme_minimal(base_size = 12) +
      labs(
        x = "",
        y = "Assembly metrics"
      ) +
      theme(
        strip.text = element_text(face = "bold"),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        panel.background = element_rect(fill = bg, color = NA),
        plot.background  = element_rect(fill = "white", color = NA),
        panel.grid.major = element_line(color = "grey85"),
        panel.grid.minor = element_blank(),
        plot.margin = margin(10, 25, 10, 10)
      )
    
    # Display plot
    print(p_qc)
    
    
    # ===============================
    # 12. Save QC summary plot
    # ===============================
    ggsave(
      filename = "path/to/output/assembly_plot.png",
      plot = p_qc,
      width = 9.50,
      height = 6.21,
      units = "in",
      dpi = 600
    )
    
    
    # ===============================
    # 13. Define shared theme for subplots
    # ===============================
    base_theme <- theme(
      plot.margin = margin(10, 25, 10, 10),
      plot.title = element_text(
        face = "bold",
        size = 12,
        colour = "grey20",
        hjust = 0.5
      )
    )
    
    
    # ===============================
    # 14. Create individual plots
    # ===============================
    
    # Genome size distribution
    p1 <- ggplot(df, aes(genome_size)) +
      geom_histogram(fill = "#01698c", bins = 30) +
      theme_minimal() +
      labs(
        title = "Genome size distribution",
        x = "Genome size (Mb)",
        y = "Count"
      ) +
      base_theme
    
    # N50 distribution
    p2 <- ggplot(df, aes(n50)) +
      geom_histogram(fill = "#01698c", bins = 30) +
      theme_minimal() +
      labs(
        title = "N50 distribution",
        x = "N50 (bp)",
        y = "Count"
      ) +
      base_theme
    
    # Contigs vs N50
    p3 <- ggplot(df, aes(contigs, n50)) +
      geom_point(color = "#01698c", alpha = 0.35) +
      theme_minimal() +
      labs(
        title = "Contigs vs N50",
        x = "Number of contigs",
        y = "N50 (bp)"
      ) +
      base_theme
    
    # Genome size vs contigs
    p4 <- ggplot(df, aes(genome_size, contigs)) +
      geom_point(color = "#01698c", alpha = 0.35) +
      theme_minimal() +
      labs(
        title = "Genome size vs contigs",
        x = "Genome size (Mb)",
        y = "Number of contigs"
      ) +
      base_theme
    
    
    # ===============================
    # 15. Combine plots
    # ===============================
    new_plot <- (p1 | p2) / (p3 | p4)
    
    # Display combined plot
    new_plot
    
    
    # ===============================
    # 16. Save combined plot
    # ===============================
    ggsave(
      filename = "path/to/output/assembly_plot_2.png",
      plot = new_plot,
      width = 9.50,
      height = 6.21,
      units = "in",
      dpi = 600
    )