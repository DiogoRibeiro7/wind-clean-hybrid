#' Run Full Hybrid Pipeline
#' @param data data.frame with wind_speed, power.
#' @param centers integer number of clusters.
#' @param m fuzzifier parameter for fuzzy c-means clustering.
#' @param alpha confidence level used by Mahalanobis outlier detection.
#' @param refinement_method refinement stage implementation. Supported values
#'   are `"ann"` and `"linear_model"`.
#' @param epochs integer number of ANN training epochs.
#' @return list with cleaned data and metrics.
#' @export
run_hybrid_pipeline <- function(
    data,
    centers = 4,
    m = 2,
    alpha = 0.95,
    refinement_method = c("ann", "linear_model"),
    epochs = 80
) {
  tryCatch({
    refinement_method <- match.arg(refinement_method)
    pre <- preclean_data(data)
    message("[1/4] Pre-cleaning done: ", nrow(pre))
    clustered <- apply_fcm_clustering(pre, centers = centers, m = m)
    message("[2/4] FCM clustering done")
    flagged <- detect_outliers_mahalanobis(clustered, alpha = alpha)
    cleaned <- flagged |> dplyr::filter(!outlier)
    message("[3/4] Outliers removed: ", nrow(cleaned))
    refined <- switch(
      refinement_method,
      ann = refine_ann(cleaned, epochs = epochs),
      linear_model = refine_linear_model(cleaned)
    )
    metrics <- evaluate_metrics(refined)
    message("[4/4] Refinement completed using method: ", refinement_method)
    list(
      cleaned_data = refined,
      metrics = metrics,
      config = list(
        centers = centers,
        m = m,
        alpha = alpha,
        refinement_method = refinement_method,
        epochs = epochs
      )
    )
  }, error = function(e) {
    stop(glue::glue("Pipeline failed: {e$message}"), call. = FALSE)
  })
}
