# CRAB Genomics Analysis Pipeline (R Scripts)

[[DOI](https://zenodo.org/badge/20152693.svg)](https://doi.org/10.5281/zenodo.20152693)

## Overview

This repository contains R scripts developed for the genomic analysis of carbapenem-resistant *Acinetobacter baumannii* (CRAB) isolates. The workflow integrates outputs from multiple bioinformatics tools to enable comprehensive investigation of antimicrobial resistance (AMR), mobile genetic elements (MGEs), phylogenetic relationships, and population structure.

---

## Repository Structure

```
scripts/
├── processing/       # Data cleaning, parsing, and integration of tool outputs
├── analysis/         # Downstream genomic and statistical analyses
└── visualization/    # Generation of publication-ready figures
```

---

## Analytical Scope

The pipeline supports the integration and interpretation of outputs from multiple tools, including:

* AMRFinder (AMR gene detection)
* MEFinder (mobile genetic elements)
* MOB-suite (plasmid classification)
* APT / BLAST-based plasmid detection
* MLST (sequence typing)
* PopPUNK (clonal clustering)
* Kaptive (capsule and outer core typing)
* Parsnp (phylogenetic reconstruction)

---

## Core Analyses

The scripts in this repository enable:

* Identification and profiling of key carbapenemase genes
  (*blaNDM-1, blaOXA-23, blaOXA-66*)

* Characterization of insertion sequences and their genomic context

* Flanking region analysis to assess gene–MGE associations

* Contig-level integration of AMR, plasmid, and mobility information

* Comparative analysis of phylogenetic distances and resistance profiles

* Population structure analysis using sequence types (STs) and clonal complexes (CCs)

* Integration of capsule (KL) and outer core (OCL) locus typing

---

## Output

The workflow produces:

* Integrated contig-level datasets combining multiple genomic annotations
* Summary tables of AMR and MGE distributions
* Quantitative analyses of gene associations and genomic context
* Figures suitable for downstream reporting and publication

---

## Requirements

The analysis was performed in R (≥ 4.0) using the following packages:

```r
tidyverse
dplyr
readr
stringr
purrr
ggplot2
pheatmap
ape
patchwork
janitor
```

---

## Usage

The scripts are modular and designed to be executed sequentially:

1. Data preparation and integration (`scripts/processing/`)
2. Analytical workflows (`scripts/analysis/`)
3. Visualization and figure generation (`scripts/visualization/`)

File paths should be updated within scripts prior to execution.

---

## Notes

* Input datasets are not included in this repository
* Scripts assume standardized sample identifiers across tools
* The workflow is designed for contig-level analyses and may require adaptation for complete genomes

---

## Author

**Nidhi Guntgatti**

---

## Citation

If you use this repository, please cite:

Guntgatti, N. (2026). *CRAB Genomics Analysis Pipeline (R Scripts)* (v1.1). Zenodo. https://doi.org/10.5281/zenodo.20152693
