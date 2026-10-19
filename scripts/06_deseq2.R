# GSE145889 H929 RNA-seq differential expression
# Comparison: THZ1 Treatment vs DMSO Control

suppressPackageStartupMessages({
  library(DESeq2)
  library(ggplot2)
})

dir.create("results/deseq2", recursive = TRUE, showWarnings = FALSE)
dir.create("figures/pca", recursive = TRUE, showWarnings = FALSE)
dir.create("figures/differential_expression",
           recursive = TRUE, showWarnings = FALSE)

# Read sample metadata
samples <- read.csv(
  "metadata/samples.csv",
  stringsAsFactors = FALSE
)

stopifnot(nrow(samples) == 4)
stopifnot(all(table(samples$condition) == 2))

samples$condition <- factor(
  samples$condition,
  levels = c("Control", "Treatment")
)

rownames(samples) <- samples$sample_id

# Read featureCounts output
counts_raw <- read.delim(
  "results/counts/gene_counts.txt",
  comment.char = "#",
  check.names = FALSE
)

# First six columns contain genomic annotation
count_matrix <- counts_raw[, -(1:6), drop = FALSE]
rownames(count_matrix) <- counts_raw$Geneid

# Extract biological sample names from BAM paths
bam_names <- colnames(count_matrix)
bam_names <- basename(bam_names)
bam_names <- sub(
  "_Aligned.sortedByCoord.out.bam$",
  "",
  bam_names
)

colnames(count_matrix) <- bam_names

# Ensure all samples are present and ordered correctly
stopifnot(
  setequal(colnames(count_matrix), samples$sample_id)
)

count_matrix <- count_matrix[, samples$sample_id, drop = FALSE]
stopifnot(!anyNA(count_matrix))
stopifnot(all(count_matrix >= 0))
stopifnot(all(count_matrix == floor(count_matrix)))

# Construct DESeq2 dataset
dds <- DESeqDataSetFromMatrix(
  countData = count_matrix,
  colData = samples,
  design = ~ condition
)

# Remove very low-count genes
dds <- dds[rowSums(counts(dds)) >= 10, ]

# Run differential expression
dds <- DESeq(dds)

res <- results(
  dds,
  contrast = c("condition", "Treatment", "Control"),
  alpha = 0.05
)

res_df <- as.data.frame(res)
res_df$gene_id <- rownames(res_df)

res_df <- res_df[
  order(res_df$padj, na.last = TRUE),
]

write.csv(
  res_df,
  "results/deseq2/DESeq2_all_genes.csv",
  row.names = FALSE
)

# Define exploratory DEG thresholds
sig <- !is.na(res_df$padj) &
       res_df$padj < 0.05 &
       abs(res_df$log2FoldChange) > 1

res_df$category <- "Not significant"
res_df$category[
  sig & res_df$log2FoldChange > 0
] <- "Upregulated"

res_df$category[
  sig & res_df$log2FoldChange < 0
] <- "Downregulated"

write.csv(
  res_df[sig, ],
  "results/deseq2/DESeq2_significant_genes.csv",
  row.names = FALSE
)

# Variance-stabilising transformation
vsd <- vst(dds, blind = FALSE)

# Save transformed values
write.csv(
  assay(vsd),
  "results/deseq2/VST_expression_matrix.csv"
)

# PCA plot
pca <- plotPCA(
  vsd,
  intgroup = "condition"
)

ggsave(
  "figures/pca/PCA_plot.png",
  pca,
  width = 7,
  height = 5,
  dpi = 300
)

# Volcano plot
res_df$plot_padj <- pmax(
  res_df$padj,
  .Machine$double.xmin
)

volcano <- ggplot(
  res_df,
  aes(
    x = log2FoldChange,
    y = -log10(plot_padj),
    colour = category
  )
) +
  geom_point(alpha = 0.65, size = 1.2, na.rm = TRUE) +
  scale_colour_manual(
    values = c(
      "Upregulated" = "#D55E00",
      "Downregulated" = "#0072B2",
      "Not significant" = "grey70"
    )
  ) +
  theme_classic() +
  labs(
    title = "THZ1 vs DMSO in H929 cells",
    x = "Log2 fold change",
    y = "-Log10 adjusted p-value"
  )

ggsave(
  "figures/differential_expression/volcano_plot.png",
  volcano,
  width = 8,
  height = 6,
  dpi = 300
)

saveRDS(dds, "results/deseq2/deseq2_object.rds")

capture.output(
  sessionInfo(),
  file = "results/deseq2/R_session_info.txt"
)

cat("DESeq2 analysis completed.\n")

