#' Refine with Linear Model
#'
#' Fits a simple linear model on cleaned data and computes residuals.
#'
#' @param data tibble with numeric columns wind_speed and power.
#' @return tibble with predictions and residuals.
#' @export
refine_linear_model <- function(data) {
  required_cols <- c("wind_speed", "power")
  if (!all(required_cols %in% names(data))) {
    stop("Input data must contain 'wind_speed' and 'power' columns.", call. = FALSE)
  }

  model <- stats::lm(power ~ wind_speed, data = data)
  preds <- as.numeric(stats::predict(model, newdata = data))
  residuals <- data$power - preds

  tibble::tibble(
    wind_speed = data$wind_speed,
    power = data$power,
    pred = preds,
    residual = residuals
  )
}
