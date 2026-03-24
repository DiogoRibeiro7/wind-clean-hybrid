test_that("preclean_data removes missing and negative values", {
  d <- data.frame(
    wind_speed = c(1, 2, NA, -1, 3),
    power = c(10, NA, 30, 40, -5)
  )

  res <- preclean_data(d)

  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 1)
  expect_equal(res$wind_speed, 1)
  expect_equal(res$power, 10)
})

test_that("preclean_data validates required columns and types", {
  expect_error(preclean_data(list(a = 1)), "data.frame")
  expect_error(
    preclean_data(data.frame(wind_speed = 1:3)),
    "Missing required columns"
  )
  expect_error(
    preclean_data(data.frame(wind_speed = 1:3, power = letters[1:3])),
    "must be numeric"
  )
})

test_that("preclean_data warns when no valid rows remain", {
  d <- data.frame(wind_speed = c(-1, NA), power = c(NA, -2))

  expect_warning(
    res <- preclean_data(d),
    "No valid observations remain after pre-cleaning"
  )
  expect_equal(nrow(res), 0)
})
