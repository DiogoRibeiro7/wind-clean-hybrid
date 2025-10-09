#' Pre-clean SCADA Data
#'
#' Removes invalid entries such as negative or missing wind speed and power values.
#'
#' @param data data.frame with numeric columns `wind_speed` and `power`.
#' @return Cleaned tibble with valid rows.
#' @export
preclean_data <- function(data) {
  if (!is.data.frame(data)) stop("Input must be a data.frame or tibble.")
  required_cols <- c("wind_speed", "power")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0)
    stop(glue::glue("Missing required columns: {paste(missing_cols, collapse = ', ')}"))
  if (!all(sapply(data[required_cols], is.numeric)))
    stop("Columns 'wind_speed' and 'power' must be numeric.")
  cleaned <- data |>
    dplyr::filter(!is.na(wind_speed), !is.na(power)) |>
    dplyr::filter(wind_speed >= 0, power >= 0)
  if (nrow(cleaned) == 0) warning("No valid observations remain after pre-cleaning.")
  return(cleaned)
}
