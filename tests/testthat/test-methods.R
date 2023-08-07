test_that("BLFL", {
  df <- dplyr::tibble(
    USUBJID = c(
      rep(1, 3),
      rep(2, 3)
    ),
    XXORRES = c(
      1, 2, 2,
      1, 2, NA
    ),
    XXDTC = as.Date(c(
      "2017-02-05", "2017-02-06", "2017-02-07",
      "2017-02-05", "2017-02-06", "2017-02-07"
    )),
    RFSTDTC = as.Date(c(
      rep("2017-02-05", 3),
      rep("2017-02-07", 3)
    ))
  )
  expected_df <- df %>%
    dplyr::mutate(XXBLFL = c(
      "Y"          , NA_character_, NA_character_,
      NA_character_, "Y"          , NA_character_
    ))
  expect_equal(
    create_BLFL(df, sort_date = "XXDTC", domain = "XX"),
    expected_df
  )
})


test_that("EPOCH", {
  df <- data.frame(
    DTC = c("2023-08-01", "2023-08-02", "2023-08-03", "2023-08-04"),
    RFXSTDTC = rep("2023-08-02", 4),
    RFXENDTC = rep("2023-08-03", 4)
  )
  expected_df <- df %>%
    dplyr::mutate(
      EPOCH = c("SCREENING", "TREATMENT", "TREATMENT", "FOLLOW-UP")
    )
  expect_equal(create_EPOCH(df, date_col = "DTC"),
               expected_df)
})


test_that("DY", {
  df <- data.frame(
    DTC = c("2023-08-01", "2023-08-02", "2023-08-03", "2023-08-04"),
    RFSTDTC = rep("2023-08-02", 4)
  )
  expected_df <- df %>%
    dplyr::mutate(
      XXDY = c(-1, 1, 2, 3)
    )
  expect_equal(calc_DY(df, DY_col = "XXDY", DTC_col = "DTC"),
               expected_df)
})
