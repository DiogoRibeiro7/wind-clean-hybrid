test_that("detect_outliers_mahalanobis flags an extreme outlier in a stable cluster", {
  d <- data.frame(
    wind_speed = c(5, 5.1, 4.9, 5.2, 5.05, 60),
    power      = c(500, 510, 490, 505, 495, 7000),
    cluster    = rep(1, 6)
  )
  res <- detect_outliers_mahalanobis(d, alpha = 0.8)
  expect_true(res$outlier[6])
  expect_false(any(res$outlier[1:5]))
})

test_that("singular covariance is tracked through the singular_clusters attribute", {
  # Collinear data: power is exactly proportional to wind_speed
  d <- data.frame(
    wind_speed = c(1, 2, 3, 4, 10),
    power      = c(10, 20, 30, 40, 100),
    cluster    = rep(1, 5)
  )
  res <- detect_outliers_mahalanobis(d, alpha = 0.8)
  info <- attr(res, "singular_clusters")
  expect_equal(info[["1"]], "regularized")
  expect_equal(res$outlier, rep(FALSE, 5))
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
  expect_true(info[["1"]] %in% c("regularized", "diagonal_fallback"))
  expect_equal(res$outlier, rep(FALSE, 5))
})

test_that("multi-cluster handling: healthy cluster unaffected by singular sibling", {
  d <- data.frame(
    wind_speed = c(5, 5.1, 4.9, 5.2, 1, 2, 3, 4, 10),
    power      = c(500, 510, 490, 505, 10, 20, 30, 40, 100),
    cluster    = c(rep(1, 4), rep(2, 5))
  )
  res <- detect_outliers_mahalanobis(d, alpha = 0.8)
  # Cluster 1 should work normally
  expect_false(any(res$outlier[1:4]))
  info <- attr(res, "singular_clusters")
  # Cluster 2 should be flagged
  expect_equal(info[["2"]], "regularized")
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
