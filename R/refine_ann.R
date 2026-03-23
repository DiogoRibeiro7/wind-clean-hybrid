#' Refine with ANN
#'
#' Trains an ANN on cleaned data and computes residuals.
#' @param data tibble with numeric columns wind_speed and power.
#' @param epochs integer number of training epochs.
#' @return tibble with predictions and residuals.
#' @export
refine_ann <- function(data, epochs = 80) {
  if (!requireNamespace("keras", quietly = TRUE))
    stop(
      "Package 'keras' must be installed to use ANN refinement. ",
      "Install it with install.packages('keras') and configure the backend before running refine_ann().",
      call. = FALSE
    )
  if (!is.numeric(epochs) || epochs < 10)
    stop("'epochs' must be >= 10.")
  x <- as.matrix(data$wind_speed)
  y <- as.matrix(data$power)
  x_mean <- mean(x); x_sd <- sd(x)
  x <- scale(x, center = x_mean, scale = x_sd)
  model <- keras::keras_model_sequential() |>
    keras::layer_dense(units = 40, activation = "relu", input_shape = 1) |>
    keras::layer_dense(units = 40, activation = "relu") |>
    keras::layer_dense(units = 1)
  keras::compile(model, optimizer = "adam", loss = "mse")
  tryCatch({
    keras::fit(model, x, y, epochs = epochs, batch_size = 64, verbose = 0)
  }, error = function(e) stop("Training failed: ", e$message, call. = FALSE))
  preds <- as.numeric(stats::predict(model, x))
  residuals <- y - preds
  tibble::tibble(wind_speed = as.numeric(x) * x_sd + x_mean,
                 power = as.numeric(y), pred = preds, residual = residuals)
}
