#' Run Full Hybrid Pipeline
#' @param data data.frame with wind_speed, power.
#' @param centers integer number of clusters.
#' @param m fuzzifier parameter for fuzzy c-means clustering.
#' @param alpha confidence level used by Mahalanobis outlier detection.
#' @param epochs integer number of ANN training epochs.
#' @return list with cleaned data and metrics.
#' @export
run_hybrid_pipeline <- function(data, centers = 4, m = 2, alpha = 0.95, epochs = 80) {
  tryCatch({
    pre <- preclean_data(data)
    message("[1/4] Pre-cleaning done: ", nrow(pre))
    clustered <- apply_fcm_clustering(pre, centers = centers, m = m)
    message("[2/4] FCM clustering done")
    flagged <- detect_outliers_mahalanobis(clustered, alpha = alpha)
    cleaned <- flagged |> dplyr::filter(!outlier)
    message("[3/4] Outliers removed: ", nrow(cleaned))
    refined <- refine_ann(cleaned, epochs = epochs)
    metrics <- evaluate_metrics(refined)
    message("[4/4] ANN refinement completed")
    list(
      cleaned_data = refined,
      metrics = metrics,
      config = list(
        centers = centers,
        m = m,
        alpha = alpha,
        epochs = epochs
      )
    )
  }, error = function(e) {
    stop(glue::glue("Pipeline failed: {e$message}"), call. = FALSE)
  })
}
