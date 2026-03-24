test_that("run_hybrid_pipeline returns cleaned data and metrics with stubbed ANN", {
  d <- example_positive_scada()

  mock_refine_ann <- function(data, epochs = 80) {
    tibble::tibble(
      wind_speed = data$wind_speed,
      power = data$power,
      pred = data$power * 0.98,
      residual = data$power - (data$power * 0.98)
    )
  }

  if ("windCleanHybrid" %in% loadedNamespaces()) {
    res <- testthat::with_mocked_bindings(
      run_hybrid_pipeline(d, centers = 2),
      refine_ann = mock_refine_ann,
      .package = "windCleanHybrid"
    )
  } else {
    old_refine_ann <- get("refine_ann", envir = globalenv())
    on.exit(assign("refine_ann", old_refine_ann, envir = globalenv()), add = TRUE)
    assign("refine_ann", mock_refine_ann, envir = globalenv())
    res <- run_hybrid_pipeline(d, centers = 2)
  }

  expect_named(res, c("cleaned_data", "metrics"))
  expect_s3_class(res$cleaned_data, c("tbl_df", "tbl", "data.frame"))
  expect_named(res$metrics, c("RMSE", "MAE", "MAPE", "R2", "CA"))
  expect_true(all(is.finite(unlist(res$metrics))))
})

test_that("run_hybrid_pipeline wraps ANN dependency failures", {
  d <- example_positive_scada()

  keras_error <- paste0(
    "Package 'keras' must be installed to use ANN refinement. ",
    "Install it with install.packages\\('keras'\\) and configure the backend before running refine_ann\\(\\)."
  )

  if ("windCleanHybrid" %in% loadedNamespaces()) {
    expect_error(
      testthat::with_mocked_bindings(
        run_hybrid_pipeline(d, centers = 2),
        refine_ann = function(data, epochs = 80) {
          stop(
            "Package 'keras' must be installed to use ANN refinement. ",
            "Install it with install.packages('keras') and configure the backend before running refine_ann().",
            call. = FALSE
          )
        },
        .package = "windCleanHybrid"
      ),
      paste0("Pipeline failed: ", keras_error)
    )
  } else {
    old_refine_ann <- get("refine_ann", envir = globalenv())
    on.exit(assign("refine_ann", old_refine_ann, envir = globalenv()), add = TRUE)
    assign(
      "refine_ann",
      function(data, epochs = 80) {
        stop(
          "Package 'keras' must be installed to use ANN refinement. ",
          "Install it with install.packages('keras') and configure the backend before running refine_ann().",
          call. = FALSE
        )
      },
      envir = globalenv()
    )

    expect_error(
      run_hybrid_pipeline(d, centers = 2),
      paste0("Pipeline failed: ", keras_error)
    )
  }
})
