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

test_that("evaluate_metrics handles zero-power observations without returning NaN", {
  d <- data.frame(
    power = c(0, 100, 200),
    pred = c(0, 110, 190)
  )

  metrics <- evaluate_metrics(d)

  expect_equal(metrics$MAPE, Metrics::mape(c(100, 200), c(110, 190)))
  expect_true(is.finite(metrics$CA))
})

test_that("evaluate_metrics returns NA for MAPE when all observed power is zero", {
  d <- data.frame(
    power = c(0, 0, 0),
    pred = c(0, 5, 10)
  )

  metrics <- evaluate_metrics(d)

  expect_true(is.na(metrics$MAPE))
  expect_true(is.finite(metrics$CA))
})
