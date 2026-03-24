#' Validate SCADA Input Data
#'
#' Performs a preflight validation of the SCADA input schema and value ranges
#' expected by the package.
#'
#' @param data object expected to be a data.frame or tibble containing
#'   `wind_speed` and `power`.
#' @return A list with validation results:
#'   \describe{
#'     \item{valid}{Logical scalar indicating whether the input passed schema and type checks.}
#'     \item{issues}{Character vector of validation issues.}
#'     \item{summary}{Named list with row counts for missing and negative values.}
#'   }
#' @export
validate_scada_data <- function(data) {
  issues <- character()

  if (!is.data.frame(data)) {
    return(list(
      valid = FALSE,
      issues = "Input must be a data.frame or tibble.",
      summary = NULL
    ))
  }

  required_cols <- c("wind_speed", "power")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    issues <- c(
      issues,
      glue::glue("Missing required columns: {paste(missing_cols, collapse = ', ')}")
    )
  }

  present_required <- intersect(required_cols, names(data))
  non_numeric_cols <- present_required[!vapply(data[present_required], is.numeric, logical(1))]
  if (length(non_numeric_cols) > 0) {
    issues <- c(
      issues,
      glue::glue("Columns must be numeric: {paste(non_numeric_cols, collapse = ', ')}")
    )
  }

  if (length(issues) > 0) {
    return(list(valid = FALSE, issues = issues, summary = NULL))
  }

  summary <- list(
    rows = nrow(data),
    missing_wind_speed = sum(is.na(data$wind_speed)),
    missing_power = sum(is.na(data$power)),
    negative_wind_speed = sum(data$wind_speed < 0, na.rm = TRUE),
    negative_power = sum(data$power < 0, na.rm = TRUE)
  )

  list(valid = TRUE, issues = character(), summary = summary)
}
