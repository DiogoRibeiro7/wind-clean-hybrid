#' Apply Fuzzy C-Means Clustering
#'
#' @param data data.frame with numeric columns wind_speed and power.
#' @param centers integer number of clusters.
#' @param m fuzzifier parameter (default 2).
#' @return tibble with cluster assignments.
#' @export
apply_fcm_clustering <- function(data, centers = 4, m = 2) {
  if (!is.numeric(centers) || centers < 2) stop("'centers' must be >= 2.")
  if (!is.numeric(m) || m <= 1) stop("'m' must be > 1.")
  scaled <- tryCatch(scale(data[, c("wind_speed", "power")]),
                     error = function(e) stop("Scaling failed.", call. = FALSE))
  res <- tryCatch(ppclust::fcm(scaled, centers = centers, m = m),
                  error = function(e) stop("FCM clustering failed: ", e$message, call. = FALSE))
  clusters <- apply(res$u, 1, which.max)
  tibble::as_tibble(data) |>
    dplyr::mutate(cluster = clusters)
}
