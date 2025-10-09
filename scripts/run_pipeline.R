#!/usr/bin/env Rscript
library(windCleanHybrid)
library(readr)
data <- read_csv("data/example_scada.csv")
result <- run_hybrid_pipeline(data)
print(result$metrics)
p <- plot_results(result$cleaned_data)
print(p)
