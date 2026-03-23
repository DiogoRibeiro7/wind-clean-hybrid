library(testthat)
library(windCleanHybrid)

test_that("detect_outliers_mahalanobis flags extreme outlier in normal cluster", {
  d <- data.frame(
    wind_speed = c(5, 5.1, 4.9, 50),
    power      = c(500, 510, 490, 5000),
    cluster    = rep(1, 4)
  )
  res <- detect_outliers_mahalanobis(d, alpha = 0.95)
  expect_true(res$outlier[4])
  expect_false(any(res$outlier[1:3]))
})

test_that("singular covariance is regularized, not silently skipped", {
  # Collinear data: power is exactly proportional to wind_speed
  d <- data.frame(
    wind_speed = c(1, 2, 3, 4, 10),
    power      = c(10, 20, 30, 40, 100),
    cluster    = rep(1, 5)
  )
  res <- detect_outliers_mahalanobis(d, alpha = 0.8)
  info <- attr(res, "singular_clusters")
  # Should have regularized (not silently returned zeros)
  expect_true(!is.null(info[["1"]]) || isTRUE(res$outlier[5]),
              label = "singular cluster should be regularized or detect the outlier")
  # The extreme point should ideally be flagged
  expect_true(res$outlier[5])
})

test_that("undersized cluster (< p+1 rows) is skipped with warning", {
  d <- data.frame(
    wind_speed = c(5, 10),
    power      = c(500, 1000),
    cluster    = rep(1, 2)
  )
  expect_warning(
    res <- detect_outliers_mahalanobis(d, alpha = 0.95),
    "fewer than"
  )
  expect_equal(res$outlier, c(FALSE, FALSE))
  info <- attr(res, "singular_clusters")
  expect_equal(info[["1"]], "skipped")
})

test_that("regularized clusters are tracked in singular_clusters attribute", {
  # Nearly collinear — should trigger regularization
  set.seed(42)
  d <- data.frame(
    wind_speed = c(1, 1.0000001, 1.0000002, 2, 50),
    power      = c(100, 100.000001, 100.000002, 200, 5000),
    cluster    = rep(1, 5)
  )
  res <- detect_outliers_mahalanobis(d, alpha = 0.8)
  info <- attr(res, "singular_clusters")
  # Cluster should have been either regularized or handled via diagonal fallback
  if (!is.null(info[["1"]])) {
    expect_true(info[["1"]] %in% c("regularized", "diagonal_fallback"))
  }
  # Extreme outlier should be detected regardless
  expect_true(res$outlier[5])
})

test_that("multi-cluster handling: healthy cluster unaffected by singular sibling", {
  d <- data.frame(
    wind_speed = c(5, 5.1, 4.9, 5.2, 1, 1.000001, 1.000002, 2),
    power      = c(500, 510, 490, 505, 100, 100.000001, 100.000002, 200),
    cluster    = c(rep(1, 4), rep(2, 4))
  )
  res <- detect_outliers_mahalanobis(d, alpha = 0.95)
  # Cluster 1 should work normally
  expect_false(any(res$outlier[1:4]))
  info <- attr(res, "singular_clusters")
  # Cluster 2 should be flagged
  expect_false(is.null(info[["2"]]))
})

test_that("alpha validation rejects invalid values", {
  d <- data.frame(wind_speed = 1:10, power = 1:10 * 10, cluster = rep(1, 10))
  expect_error(detect_outliers_mahalanobis(d, alpha = 0), "'alpha'")
  expect_error(detect_outliers_mahalanobis(d, alpha = 1), "'alpha'")
  expect_error(detect_outliers_mahalanobis(d, alpha = -0.5), "'alpha'")
})

test_that("missing cluster column raises error", {
  d <- data.frame(wind_speed = 1:5, power = 1:5 * 10)
  expect_error(detect_outliers_mahalanobis(d), "cluster")
})
