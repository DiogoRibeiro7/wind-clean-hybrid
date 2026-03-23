\name{windCleanHybrid-functions}
\alias{preclean_data}
\alias{apply_fcm_clustering}
\alias{detect_outliers_mahalanobis}
\alias{refine_ann}
\alias{evaluate_metrics}
\alias{plot_results}
\alias{run_hybrid_pipeline}
\title{Core Functions for the windCleanHybrid Package}
\description{
Core functions for cleaning, clustering, outlier detection, ANN refinement,
metric evaluation, plotting, and end-to-end pipeline execution.
}
\usage{
preclean_data(data)

apply_fcm_clustering(data, centers = 4, m = 2)

detect_outliers_mahalanobis(data, alpha = 0.95, reg_eps = 1e-6)

refine_ann(data, epochs = 80)

evaluate_metrics(data)

plot_results(data)

run_hybrid_pipeline(data, centers = 4)
}
\arguments{
  \item{data}{A data frame or tibble containing the required columns for the given function.}

  \item{centers}{Integer number of clusters for fuzzy c-means.}

  \item{m}{Fuzzifier parameter for fuzzy c-means.}

  \item{alpha}{Confidence level used to derive the chi-squared outlier threshold.}

  \item{reg_eps}{Regularization value added to the covariance diagonal for singular clusters.}

  \item{epochs}{Integer number of ANN training epochs.}
}
\value{
Depending on the function, returns a cleaned data frame, clustered tibble,
data frame with outlier flags, refined tibble with predictions and residuals,
a named metrics list, a \code{ggplot} object, or a list containing cleaned
data and metrics.
}
\details{
\code{refine_ann()} requires the optional \code{keras} package and a configured
backend. \code{run_hybrid_pipeline()} will fail if ANN refinement is requested
without that dependency being available.
}
\examples{
data <- data.frame(
  wind_speed = c(3, 5, 7, 9),
  power = c(100, 300, 700, 1200)
)

cleaned <- preclean_data(data)
clustered <- apply_fcm_clustering(cleaned, centers = 2)
flagged <- detect_outliers_mahalanobis(clustered)
}
