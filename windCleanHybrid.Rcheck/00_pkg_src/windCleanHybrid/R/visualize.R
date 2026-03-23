#' Plot Cleaned Power Curve
#' @param data tibble with columns wind_speed, power, pred.
#' @return ggplot object.
#' @export
plot_results <- function(data) {
  ggplot2::ggplot(data, ggplot2::aes(x = wind_speed)) +
    ggplot2::geom_point(ggplot2::aes(y = power), color = "#1f77b4", alpha = 0.6) +
    ggplot2::geom_line(ggplot2::aes(y = pred), color = "#d62728", linewidth = 1.1) +
    ggplot2::labs(title = "Hybrid Cleaned Wind Turbine Power Curve",
                  x = "Wind Speed (m/s)", y = "Power (kW)") +
    ggplot2::theme_minimal()
}
