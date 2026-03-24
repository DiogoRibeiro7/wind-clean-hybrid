test_that("apply_fcm_clustering returns one cluster assignment per row", {
  d <- example_positive_scada()

  res <- apply_fcm_clustering(d, centers = 2)

  expect_s3_class(res, c("tbl_df", "tbl", "data.frame"))
  expect_equal(nrow(res), nrow(d))
  expect_true("cluster" %in% names(res))
  expect_true(all(res$cluster %in% c(1L, 2L)))
})

test_that("apply_fcm_clustering validates tuning parameters", {
  d <- example_positive_scada()

  expect_error(apply_fcm_clustering(d, centers = 1), "centers")
  expect_error(apply_fcm_clustering(d, m = 1), "'m'")
})

test_that("apply_fcm_clustering rejects zero-variance inputs before scaling", {
  d <- data.frame(
    wind_speed = rep(5, 5),
    power = rep(100, 5)
  )

  expect_error(
    apply_fcm_clustering(d, centers = 2),
    "Zero variance detected"
  )
})
