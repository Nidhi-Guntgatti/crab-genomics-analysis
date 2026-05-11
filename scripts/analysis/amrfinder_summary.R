# ============================================
# Script: AMR class presence/absence and summary
# Purpose:
#   - Load AMRFinder output (TSV)
#   - Extract key AMR annotations (class, subclass)
#   - Generate a presence/absence matrix of AMR classes per isolate
#   - Summarize number and percentage of isolates per AMR class
#   - Specifically quantify key beta-lactam subclasses:
#       * Carbapenemases
#       * ESBLs (Extended-Spectrum Beta-Lactamases)
#   - Export all results as TSV files
# ============================================

# --------------------------------------------
# 1. Load required libraries
# --------------------------------------------
library(dplyr)
library(tidyr)
library(readr)

# --------------------------------------------
# 2. Load AMRFinder output file
# --------------------------------------------

# Read merged AMR results (TSV format)
amr <- read_tsv("your/input/path/here") # your amrfinder output file here

# --------------------------------------------
# 3. Select and rename relevant columns
# --------------------------------------------

# Keep only key columns:
#   - isolate ID
#   - gene (AMR determinant)
#   - class (broad AMR category)
#   - subclass (more specific mechanism)
amr <- amr %>%
  select(
    isolate = species_id,
    gene = `Element symbol`,
    class = Class,
    subclass = Subclass
  )

# --------------------------------------------
# 4. Create presence/absence matrix (AMR class)
# --------------------------------------------

# For each isolate-class combination:
#   - keep unique pairs
#   - assign presence = 1
#   - convert to wide format (one column per class)
#   - fill missing values with 0 (absence)
amr_binary <- amr %>%
  distinct(isolate, class) %>%
  mutate(present = 1) %>%
  pivot_wider(
    names_from = class,
    values_from = present,
    values_fill = 0
  )

# --------------------------------------------
# 5. Compute summary statistics per AMR class
# --------------------------------------------

# Total number of unique isolates
total_isolates <- length(unique(amr$isolate))

# For each AMR class:
#   - count number of isolates carrying it
#   - calculate percentage of total isolates
amr_summary <- amr_binary %>%
  select(-isolate) %>%
  summarise(across(everything(), sum)) %>%
  pivot_longer(
    cols = everything(),
    names_to = "AMR_class",
    values_to = "No_of_isolates"
  ) %>%
  mutate(
    Percentage = round((No_of_isolates / total_isolates) * 100, 1)
  )

# --------------------------------------------
# 6. Subclass-specific analysis
#    Focus: beta-lactam resistance mechanisms
# --------------------------------------------

# 6A. Carbapenemases
# Identify isolates carrying carbapenemase-related genes
carb_summary <- amr %>%
  filter(grepl("CARBAPENEM", subclass, ignore.case = TRUE)) %>%
  distinct(isolate) %>%
  summarise(No_of_isolates = n()) %>%
  mutate(
    Percentage = round(No_of_isolates / total_isolates * 100, 1),
    Type = "Carbapenemase"
  )

# 6B. ESBLs (Extended-Spectrum Beta-Lactamases)
# Identify isolates with ESBL/cephalosporin resistance
esbl_summary <- amr %>%
  filter(grepl("CEPHALOSPORIN|ESBL", subclass, ignore.case = TRUE)) %>%
  distinct(isolate) %>%
  summarise(No_of_isolates = n()) %>%
  mutate(
    Percentage = round(No_of_isolates / total_isolates * 100, 1),
    Type = "ESBL"
  )

# --------------------------------------------
# 7. Save outputs
# --------------------------------------------

# Presence/absence matrix
write_tsv(amr_binary, "AMR_class_presence_absence.tsv")

# Summary of AMR classes
write_tsv(amr_summary, "AMR_class_summary.tsv")

# Beta-lactam subclass summary (combined)
write_tsv(
  bind_rows(carb_summary, esbl_summary),
  "beta_lactam_subclasses_summary.tsv"
)