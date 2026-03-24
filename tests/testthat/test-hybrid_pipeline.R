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

  mock_apply_fcm <- function(data, centers = 4, m = 2) {
    tibble::as_tibble(data) |>
      dplyr::mutate(cluster = rep(1L, nrow(data)))
  }

  mock_detect_outliers <- function(data, alpha = 0.95, reg_eps = 1e-6) {
    tibble::as_tibble(data) |>
      dplyr::mutate(outlier = FALSE)
  }

  if ("windCleanHybrid" %in% loadedNamespaces()) {
    res <- testthat::with_mocked_bindings(
      run_hybrid_pipeline(
        d,
        centers = 2,
        m = 2.5,
        alpha = 0.8,
        refinement_method = "ann",
        epochs = 25
      ),
      apply_fcm_clustering = mock_apply_fcm,
      detect_outliers_mahalanobis = mock_detect_outliers,
      refine_ann = mock_refine_ann,
      .package = "windCleanHybrid"
    )
  } else {
    old_apply_fcm <- get("apply_fcm_clustering", envir = globalenv())
    old_detect_outliers <- get("detect_outliers_mahalanobis", envir = globalenv())
    old_refine_ann <- get("refine_ann", envir = globalenv())
    on.exit(assign("apply_fcm_clustering", old_apply_fcm, envir = globalenv()), add = TRUE)
    on.exit(assign("detect_outliers_mahalanobis", old_detect_outliers, envir = globalenv()), add = TRUE)
    on.exit(assign("refine_ann", old_refine_ann, envir = globalenv()), add = TRUE)
    assign("apply_fcm_clustering", mock_apply_fcm, envir = globalenv())
    assign("detect_outliers_mahalanobis", mock_detect_outliers, envir = globalenv())
    assign("refine_ann", mock_refine_ann, envir = globalenv())
    res <- run_hybrid_pipeline(
      d,
      centers = 2,
      m = 2.5,
      alpha = 0.8,
      refinement_method = "ann",
      epochs = 25
    )
  }

  expect_named(res, c("cleaned_data", "metrics", "config"))
  expect_s3_class(res$cleaned_data, c("tbl_df", "tbl", "data.frame"))
  expect_named(res$metrics, c("RMSE", "MAE", "MAPE", "R2", "CA"))
  expect_equal(
    res$config,
    list(centers = 2, m = 2.5, alpha = 0.8, refinement_method = "ann", epochs = 25)
  )
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
        run_hybrid_pipeline(d, centers = 2, refinement_method = "ann"),
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
      run_hybrid_pipeline(d, centers = 2, refinement_method = "ann"),
      paste0("Pipeline failed: ", keras_error)
    )
  }
})

test_that("run_hybrid_pipeline supports linear model refinement without keras", {
  d <- example_positive_scada()

  mock_apply_fcm <- function(data, centers = 4, m = 2) {
    tibble::as_tibble(data) |>
      dplyr::mutate(cluster = rep(1L, nrow(data)))
  }

  mock_detect_outliers <- function(data, alpha = 0.95, reg_eps = 1e-6) {
    tibble::as_tibble(data) |>
      dplyr::mutate(outlier = FALSE)
  }

  if ("windCleanHybrid" %in% loadedNamespaces()) {
    res <- testthat::with_mocked_bindings(
      run_hybrid_pipeline(d, centers = 2, refinement_method = "linear_model"),
      apply_fcm_clustering = mock_apply_fcm,
      detect_outliers_mahalanobis = mock_detect_outliers,
      .package = "windCleanHybrid"
    )
  } else {
    old_apply_fcm <- get("apply_fcm_clustering", envir = globalenv())
    old_detect_outliers <- get("detect_outliers_mahalanobis", envir = globalenv())
    on.exit(assign("apply_fcm_clustering", old_apply_fcm, envir = globalenv()), add = TRUE)
    on.exit(assign("detect_outliers_mahalanobis", old_detect_outliers, envir = globalenv()), add = TRUE)
    assign("apply_fcm_clustering", mock_apply_fcm, envir = globalenv())
    assign("detect_outliers_mahalanobis", mock_detect_outliers, envir = globalenv())
    res <- run_hybrid_pipeline(d, centers = 2, refinement_method = "linear_model")
  }

  expect_equal(res$config$refinement_method, "linear_model")
  expect_named(res$cleaned_data, c("wind_speed", "power", "pred", "residual"))
  expect_true(all(is.finite(unlist(res$metrics))))
})
