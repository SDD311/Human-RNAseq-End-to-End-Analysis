# Hallmark GSEA for GSE145889 H929 RNA-seq
# Uses DESeq2 Wald statistics to rank genes

suppressPackageStartupMessages({
  library(fgsea)
  library(msigdbr)
  library(org.Hs.eg.db)
  library(AnnotationDbi)
  library(ggplot2)
})

dir.create("results/enrichment", recursive = TRUE,
           showWarnings = FALSE)
dir.create("figures/pathways", recursive = TRUE,
           showWarnings = FALSE)

# Read differential expression results
de <- read.csv(
  "results/differential_expression/DESeq2_all_genes.csv"
)

# Remove Ensembl version numbers, if present
de$ensembl_id <- sub("\\..*$", "", de$gene_id)

# Convert Ensembl IDs to gene symbols
de$symbol <- mapIds(
  org.Hs.eg.db,
  keys = de$ensembl_id,
  keytype = "ENSEMBL",
  column = "SYMBOL",
  multiVals = "first"
)

# Keep valid genes and test statistics
de <- de[
  !is.na(de$symbol) &
  !is.na(de$stat) &
  is.finite(de$stat),
]

# Resolve duplicated gene symbols by largest
# absolute Wald statistic
de <- de[order(-abs(de$stat)), ]
de <- de[!duplicated(de$symbol), ]

ranks <- de$stat
names(ranks) <- de$symbol
ranks <- sort(ranks, decreasing = TRUE)

if (length(ranks) < 20) {
  stop("Too few ranked genes for GSEA")
}

# Retrieve human Hallmark gene sets
hallmark <- msigdbr(
  species = "Homo sapiens",
  collection = "H"
)

pathways <- split(
  hallmark$gene_symbol,
  hallmark$gs_name
)

set.seed(123)

gsea <- fgseaMultilevel(
  pathways = pathways,
  stats = ranks,
  minSize = 15,
  maxSize = 500,
  eps = 0
)

gsea <- as.data.frame(gsea)

# Convert list column for CSV output
gsea$leadingEdge <- vapply(
  gsea$leadingEdge,
  paste,
  collapse = ";",
  FUN.VALUE = character(1)
)

gsea <- gsea[order(gsea$padj), ]

write.csv(
  gsea,
  "results/enrichment/hallmark_gsea.csv",
  row.names = FALSE
)

# Display top pathways, if available
plot_data <- gsea[
  !is.na(gsea$padj) & gsea$padj < 0.05,
]

plot_data <- head(plot_data, 15)

if (nrow(plot_data) > 0) {

  plot_data$pathway <- factor(
    plot_data$pathway,
    levels = rev(plot_data$pathway)
  )

  p <- ggplot(
    plot_data,
    aes(x = NES, y = pathway, fill = NES > 0)
  ) +
    geom_col() +
    scale_fill_manual(
      values = c("#0072B2", "#D55E00"),
      guide = "none"
    ) +
    theme_classic() +
    labs(
      title = "Hallmark GSEA: THZ1 vs DMSO",
      x = "Normalised Enrichment Score",
      y = "Hallmark pathway"
    )

  ggsave(
    "figures/pathways/hallmark_gsea.png",
    p,
    width = 10,
    height = 6,
    dpi = 300
  )
}

cat("Hallmark GSEA completed.\n")

