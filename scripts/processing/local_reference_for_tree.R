# ============================================
# Script: Reference Genome Selection
# Purpose:
#   - Identify the most suitable local reference assembly
#     from a collection of FASTA assemblies
#
# Selection criteria:
#   1. Genome size between 3.5–4.5 Mb
#   2. Lowest number of contigs
#   3. Closest genome size to 4 Mb
#
# Input:
#   - Directory containing assembled genomes (*.fasta)
#
# Output:
#   - Best reference assembly path
#   - Contig count
#   - Size difference from target genome size
# ============================================


# --------------------------------------------
# Initialize variables
# --------------------------------------------

best_file=""
best_contigs=1000000
best_size_diff=10000000


# --------------------------------------------
# Iterate through assembly files
# --------------------------------------------

for f in /data/internship_data/nidhi/aba/output/nextflow_output/assemblies/*.fasta; do

# Calculate total genome size
size=$(awk '!/^>/ {sum += length($0)} END {print sum}' "$f")

# Count number of contigs
contigs=$(grep -c "^>" "$f")

# Calculate difference from target genome size (4 Mb)
diff=$(( size > 4000000 ? size - 4000000 : 4000000 - size ))


# ----------------------------------------
# Apply genome size filter
# ----------------------------------------

if [ "$size" -gt 3500000 ] && [ "$size" -lt 4500000 ]; then

# Select assembly with:
#   1. Fewer contigs
#   2. Smaller size difference if contigs are equal

if [ "$contigs" -lt "$best_contigs" ] || \
{ [ "$contigs" -eq "$best_contigs" ] && \
  [ "$diff" -lt "$best_size_diff" ]; }; then

best_file="$f"
best_contigs="$contigs"
best_size_diff="$diff"

fi
fi

done


# --------------------------------------------
# Report best reference assembly
# --------------------------------------------

echo "Best reference assembly: $best_file"
echo "Number of contigs: $best_contigs"
echo "Genome size difference from 4 Mb: $best_size_diff"