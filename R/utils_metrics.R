#' Compute Evaluation Metrics
#' @param data tibble with columns power, pred.
#' @return list of RMSE, MAE, MAPE, R2, CA.
#' @export
evaluate_metrics <- function(data) {
  stopifnot(all(c("power", "pred") %in% names(data)))
  rmse_val <- Metrics::rmse(data$power, data$pred)
  mae_val  <- Metrics::mae(data$power, data$pred)
  mape_val <- Metrics::mape(data$power, data$pred)
  r2_val   <- 1 - sum((data$power - data$pred)^2) /
                    sum((data$power - mean(data$power))^2)
  CA <- (1 / 3) * ((1 / (1 + rmse_val)) + (1 / (1 + mape_val)) + r2_val)
  list(RMSE = rmse_val, MAE = mae_val, MAPE = mape_val, R2 = r2_val, CA = CA)
}
