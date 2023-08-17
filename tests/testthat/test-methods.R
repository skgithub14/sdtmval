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


test_that("SEQ", {
  df <- tibble::tibble(
    USUBJID = paste("Subject", c(rep(1, 3), rep(2, 3))),
    XXTESTCD = paste0("T", rep(c(2, 3, 1), 2))
  )
  expected <- df %>%
    dplyr::arrange(USUBJID, XXTESTCD) %>%
    dplyr::mutate(XXSEQ = c(1, 2, 3, 1, 2, 3))
  actual <- assign_SEQ(df,
                       key_vars = c("USUBJID", "XXTESTCD"),
                       seq_prefix = "XX")
  expect_equal(actual, expected)
})


test_that("STAT", {

  df <- tibble::tibble(
    USUBJID = paste("Subject", c(rep("A", 2), rep("B", 4), rep("C", 2))),
    VISIT = paste("Visit",   c(1  , 2  , 1  , 1  , 2  , 2  , 2  , 2)),
    XXTESTCD = paste("Test", c(1  , 2  , 1  , 2  , 1  , 2  , 1  , 2)),
    ND =                     c("N", "N", "Y", "Y", "N", "N", "Y", "Y")
  )

  expected <- tibble::tibble(
    USUBJID = paste("Subject", c(rep("A", 2), rep("B", 3), rep("C", 1))),
    VISIT = paste("Visit",   c(1, 2, 1, 2, 2, 2)),
    XXTESTCD = c("Test 1", "Test 2", "XXALL", "Test 1", "Test 2", "XXALL"),
    ND =                     c("N", "N", "Y", "N", "N", "Y"),
    XXSTAT =                 c(NA , NA , "NOT DONE", NA , NA , "NOT DONE")
  )

  actual <- create_STAT(df = df,
                        domain = "XX",
                        nd_ind = "ND",
                        nd_ind_cd = "Y")

  expect_equal(actual, expected)

})
