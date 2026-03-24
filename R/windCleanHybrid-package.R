#' windCleanHybrid package
#'
#' Utilities for cleaning and modelling wind-turbine SCADA data with a hybrid
#' pipeline based on pre-cleaning, fuzzy c-means clustering, Mahalanobis
#' distance, and ANN refinement.
#'
#' @keywords internal
#' @importFrom dplyr filter mutate
#' @importFrom glue glue
#' @importFrom ggplot2 aes geom_line geom_point ggplot labs theme_minimal
#' @importFrom Metrics mae mape rmse
#' @importFrom ppclust fcm
#' @importFrom stats cov predict qchisq sd var
#' @importFrom tibble as_tibble tibble
"_PACKAGE"

#' @keywords internal
#' @importFrom dplyr filter mutate
#' @importFrom glue glue
#' @importFrom ggplot2 aes geom_line geom_point ggplot labs theme_minimal
#' @importFrom Metrics mae mape rmse
#' @importFrom ppclust fcm
#' @importFrom stats cov predict qchisq sd var
#' @importFrom tibble as_tibble tibble
NULL
