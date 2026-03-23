#' Detect Outliers via Mahalanobis Distance
#'
#' @param data data.frame with columns wind_speed, power, and cluster.
#' @param alpha confidence level for chi-squared threshold (default 0.95).
#' @return tibble with added `outlier` column.
#' @export
detect_outliers_mahalanobis <- function(data, alpha = 0.95) {
  if (!"cluster" %in% names(data)) stop("Column 'cluster' missing.")
  if (!is.numeric(alpha) || alpha <= 0 || alpha >= 1)
    stop("'alpha' must be between 0 and 1.")
  scaled <- scale(data[, c("wind_speed", "power")])
  p <- ncol(scaled)
  data$outlier <- FALSE
  for (k in unique(data$cluster)) {
    sub <- scaled[data$cluster == k, , drop = FALSE]
    if (nrow(sub) < p + 1) next
    md <- tryCatch({
      covmat <- cov(sub)
      stats::mahalanobis(sub, colMeans(sub), covmat)
    }, error = function(e) {
      warning(glue::glue("Skipping cluster {k}: {e$message}"))
      rep(0, nrow(sub))
    })
    thr <- qchisq(alpha, df = p)
    idx <- which(md > thr)
    data$outlier[data$cluster == k][idx] <- TRUE
  }
  data
}
