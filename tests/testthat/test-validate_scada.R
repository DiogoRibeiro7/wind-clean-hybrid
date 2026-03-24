test_that("validate_scada_data reports schema and type issues", {
  not_df <- validate_scada_data(list(a = 1))
  expect_false(not_df$valid)
  expect_match(not_df$issues[[1]], "data.frame")

  missing_cols <- validate_scada_data(data.frame(wind_speed = 1:3))
  expect_false(missing_cols$valid)
  expect_match(missing_cols$issues[[1]], "Missing required columns")

  wrong_type <- validate_scada_data(
    data.frame(wind_speed = 1:3, power = letters[1:3], stringsAsFactors = FALSE)
  )
  expect_false(wrong_type$valid)
  expect_match(wrong_type$issues[[1]], "Columns must be numeric")
})

test_that("validate_scada_data returns summary counts for valid data frames", {
  d <- data.frame(
    wind_speed = c(1, 2, NA, -1),
    power = c(10, NA, 30, -5)
  )

  res <- validate_scada_data(d)

  expect_true(res$valid)
  expect_equal(res$issues, character())
  expect_equal(res$summary$rows, 4)
  expect_equal(res$summary$missing_wind_speed, 1)
  expect_equal(res$summary$missing_power, 1)
  expect_equal(res$summary$negative_wind_speed, 1)
  expect_equal(res$summary$negative_power, 1)
})
