#' Pre-clean SCADA Data
#'
#' Removes invalid entries such as negative or missing wind speed and power values.
#'
#' @param data data.frame with numeric columns `wind_speed` and `power`.
#' @return Cleaned tibble with valid rows.
#' @export
preclean_data <- function(data) {
  validation <- validate_scada_data(data)
  if (!validation$valid) {
    stop(paste(validation$issues, collapse = "; "), call. = FALSE)
  }
  cleaned <- data |>
    dplyr::filter(!is.na(wind_speed), !is.na(power)) |>
    dplyr::filter(wind_speed >= 0, power >= 0)
  if (nrow(cleaned) == 0) warning("No valid observations remain after pre-cleaning.")
  return(cleaned)
}
