library(testthat)

repo_root <- normalizePath(test_path("..", ".."), winslash = "/", mustWork = TRUE)

if (!exists("run_hybrid_pipeline", mode = "function")) {
  source(file.path(repo_root, "R", "preclean.R"), local = globalenv())
  source(file.path(repo_root, "R", "clustering_fcm.R"), local = globalenv())
  source(file.path(repo_root, "R", "outlier_mahalanobis.R"), local = globalenv())
  source(file.path(repo_root, "R", "refine_ann.R"), local = globalenv())
  source(file.path(repo_root, "R", "utils_metrics.R"), local = globalenv())
  source(file.path(repo_root, "R", "visualize.R"), local = globalenv())
  source(file.path(repo_root, "R", "hybrid_model.R"), local = globalenv())
}

example_positive_scada <- function() {
  data.frame(
    wind_speed = c(3, 4, 5, 6, 7, 8, 9, 10),
    power = c(120, 180, 260, 410, 600, 820, 980, 1100)
  )
}
