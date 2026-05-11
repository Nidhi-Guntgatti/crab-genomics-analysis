# 🧬 CRAB Genomics Analysis Pipeline (R)

This repository contains R scripts for the analysis of **carbapenem-resistant *Acinetobacter baumannii* (CRAB)** isolates, focusing on antimicrobial resistance (AMR), mobile genetic elements (MGEs), plasmid context, and phylogenetic relationships.

---

## 📂 Repository Structure

```text
scripts/
├── processing/       # Data cleaning, parsing, and merging
├── analysis/         # Core biological analyses
└── visualization/    # Figures and plots
```

---

## 🔬 Workflow Overview

The pipeline is organized into three main stages:

### 1. Data Processing

* Cleaning and formatting outputs from:

  * AMRFinder
  * MEFinder
  * MOB-suite
  * APT (plasmid BLAST)
* Standardizing sample and contig identifiers
* Merging multi-tool outputs into unified datasets

---

### 2. Analysis

* Detection of key carbapenemase genes:

  * **blaNDM-1**
  * **blaOXA-23**
  * **blaOXA-66**
* Identification of insertion sequences (IS elements)
* Flanking region analysis (gene–IS relationships)
* Gene distance calculations
* Phylogenetic distance vs AMR context
* Sequence type (ST) and clonal complex (CC) mapping
* Capsule (KL) and outer core (OCL) typing integration

---

### 3. Visualization

* AMR gene distribution plots
* IS co-occurrence heatmaps
* MDR/XDR classification heatmaps
* Gene genomic location (chromosome vs plasmid)
* ST and CC distribution plots
* Assembly quality visualizations

---

## ⚙️ Requirements

R (≥ 4.0) with the following packages:

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

## ▶️ Usage

Scripts are modular and can be run independently.

Typical workflow:

1. Run scripts in `scripts/processing/`
2. Perform analyses using `scripts/analysis/`
3. Generate figures from `scripts/visualization/`

---

## 📁 Notes

* File paths in scripts use placeholders (`path/to/...`) and must be updated before execution.
* Input data files are not included in this repository.
* Scripts are designed for contig-level integration of multiple genomic tools.

---

## 👩‍🔬 Author

**Nidhi Guntgatti**
Bioinformatics & Genomics Analysis

---

## 📌 Project Focus

This repository supports genomic investigation of CRAB isolates to:

* Understand resistance mechanisms
* Identify mobile genetic elements driving AMR
* Explore clonal spread and population structure
* Integrate multiple typing and annotation tools

---

## 📜 License

This project is for academic and research purposes.
