#' Compute Evaluation Metrics
#' @param data tibble with columns power, pred.
#' @return list of RMSE, MAE, MAPE, R2, CA.
#' @export
evaluate_metrics <- function(data) {
  stopifnot(all(c("power", "pred") %in% names(data)))
  rmse_val <- Metrics::rmse(data$power, data$pred)
  mae_val  <- Metrics::mae(data$power, data$pred)
  nonzero_power <- data$power != 0
  mape_val <- if (any(nonzero_power)) {
    Metrics::mape(data$power[nonzero_power], data$pred[nonzero_power])
  } else {
    NA_real_
  }
  r2_denom <- sum((data$power - mean(data$power))^2)
  r2_val <- if (r2_denom > 0) {
    1 - sum((data$power - data$pred)^2) / r2_denom
  } else {
    NA_real_
  }
  ca_components <- c(1 / (1 + rmse_val))
  if (!is.na(r2_val)) {
    ca_components <- c(ca_components, r2_val)
  }
  if (!is.na(mape_val)) {
    ca_components <- c(ca_components, 1 / (1 + mape_val))
  }
  CA <- mean(ca_components)
  list(RMSE = rmse_val, MAE = mae_val, MAPE = mape_val, R2 = r2_val, CA = CA)
}
