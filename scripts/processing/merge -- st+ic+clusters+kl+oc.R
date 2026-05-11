library(dplyr)
library(readr)
library(stringr)

mlst_file      <- "/data/internship_data/nidhi/aba/output/mlst_output/MLST_with_IC.csv"
poppunk_file   <- "/data/internship_data/nidhi/aba/output/poppunk_output/query_assignment/query_assignment_clusters.csv"
kaptive_kl     <- "/data/internship_data/nidhi/aba/output/kaptive_output/kaptive_db/KL_results.tsv"
kaptive_oc     <- "/data/internship_data/nidhi/aba/output/kaptive_output/kaptive_db/OC_results.tsv"

# Load files
mlst <- read_csv(mlst_file, show_col_types = FALSE)

poppunk <- read_csv(
  poppunk_file,
  col_types = cols(
    Taxon = col_character(),
    Cluster = col_double()
  )
)

kl <- read_tsv(kaptive_kl, show_col_types = FALSE)
oc <- read_tsv(kaptive_oc, show_col_types = FALSE)

############################################
### SAMPLE ID EXTRACTION
############################################

mlst <- mlst %>%
  mutate(sample_id = str_extract(file, "G[0-9]+"),
         file = sample_id)    # overwrite long path with clean name

poppunk <- poppunk %>%
  mutate(
    sample_id = str_extract(Taxon, "G[0-9]+"),
    poppunk_cluster = Cluster
  ) %>%
  select(sample_id, poppunk_cluster)

# Kaptive KL (use correct column names)
kl <- kl %>%
  mutate(
    sample_id = str_extract(`Assembly`, "G[0-9]+"),
    KL = `Best match locus`,
    KL_confidence = `Match confidence`
  ) %>%
  select(sample_id, KL, KL_confidence)

# Kaptive OC
oc <- oc %>%
  mutate(
    sample_id = str_extract(`Assembly`, "G[0-9]+"),
    OCL = `Best match locus`,
    OCL_confidence = `Match confidence`
  ) %>%
  select(sample_id, OCL, OCL_confidence)

############################################
### MERGE TABLES
############################################

merged <- mlst %>%
  left_join(poppunk, by = "sample_id") %>%
  left_join(kl,      by = "sample_id") %>%
  left_join(oc,      by = "sample_id")

############################################
### SAVE OUTPUT
############################################

out_path <- "/data/internship_data/nidhi/aba/output/MLST_PopPUNK_Kaptive_merged.csv"
write_csv(merged, out_path)

cat("\n✔ Merged file saved at:", out_path, "\n")
cat("✔ Rows:", nrow(merged), " | Columns:", ncol(merged), "\n")


