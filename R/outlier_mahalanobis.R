#' Detect Outliers via Mahalanobis Distance
#'
#' @param data data.frame with columns wind_speed, power, and cluster.
#' @param alpha confidence level for chi-squared threshold (default 0.95).
#' @param reg_eps regularization epsilon added to diagonal when covariance is
#'   singular (default 1e-6). Set to 0 to disable regularization.
#' @return tibble with added `outlier` column. The returned object carries a
#'   `"singular_clusters"` attribute — a named list mapping cluster ids to the
#'   reason (e.g. `"regularized"`, `"diagonal_fallback"`, `"skipped"`) when the
#'   covariance could not be used as-is.
#' @export
detect_outliers_mahalanobis <- function(data, alpha = 0.95, reg_eps = 1e-6) {
  if (!"cluster" %in% names(data)) stop("Column 'cluster' missing.")
  if (!is.numeric(alpha) || alpha <= 0 || alpha >= 1)
    stop("'alpha' must be between 0 and 1.")

  scaled <- scale(data[, c("wind_speed", "power")])
  p <- ncol(scaled)
  data$outlier <- FALSE
  singular_info <- list()

  for (k in unique(data$cluster)) {
    sub <- scaled[data$cluster == k, , drop = FALSE]
    n <- nrow(sub)

    # Need at least p+1 points for a non-singular covariance
    if (n < p + 1) {
      singular_info[[as.character(k)]] <- "skipped"
      warning(glue::glue("Skipping cluster {k}: fewer than {p + 1} observations"))
      next
    }

    covmat <- tryCatch(cov(sub), error = function(e) NULL)

    if (is.null(covmat)) {
      # Extreme failure — fall back to diagonal covariance
      covmat <- diag(apply(sub, 2, var))
      singular_info[[as.character(k)]] <- "diagonal_fallback"
    } else if (reg_eps > 0 && det(covmat) < .Machine$double.eps * nrow(covmat)) {
      # Near-singular: regularise with small diagonal jitter
      covmat <- covmat + diag(reg_eps, nrow = p)
      singular_info[[as.character(k)]] <- "regularized"
    }

    md <- tryCatch(
      stats::mahalanobis(sub, colMeans(sub), covmat),
      error = function(e) {
        # Last resort: diagonal covariance
        diag_cov <- diag(diag(covmat))
        singular_info[[as.character(k)]] <<- "diagonal_fallback"
        stats::mahalanobis(sub, colMeans(sub), diag_cov)
      }
    )

    thr <- qchisq(alpha, df = p)
    idx <- which(md > thr)
    data$outlier[data$cluster == k][idx] <- TRUE
  }

  attr(data, "singular_clusters") <- singular_info
  data
}
