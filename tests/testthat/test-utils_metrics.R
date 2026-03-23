test_that("evaluate_metrics returns the expected metric fields", {
  d <- data.frame(
    power = c(100, 150, 200, 250),
    pred = c(102, 147, 198, 255)
  )

  metrics <- evaluate_metrics(d)

  expect_named(metrics, c("RMSE", "MAE", "MAPE", "R2", "CA"))
  expect_true(all(vapply(metrics, is.numeric, logical(1))))
  expect_true(all(is.finite(unlist(metrics))))
})

test_that("evaluate_metrics requires power and pred columns", {
  expect_error(
    evaluate_metrics(data.frame(power = c(1, 2, 3))),
    "all\\(c\\(\"power\", \"pred\"\\) %in% names\\(data\\)\\) is not TRUE"
  )
})

test_that("evaluate_metrics currently returns NaN for zero-power MAPE regression", {
  d <- data.frame(
    power = c(0, 100, 200),
    pred = c(0, 110, 190)
  )

  metrics <- evaluate_metrics(d)

  expect_true(is.nan(metrics$MAPE))
  expect_true(is.nan(metrics$CA))
})
