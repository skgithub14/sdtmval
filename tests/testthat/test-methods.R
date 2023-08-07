test_that("BLFL", {
  df <- dplyr::tibble(
    USUBJID = c(rep(1, 3),
                rep(2, 3)),
    XXORRES = c(1, 2, 2,
                1, 2, NA),
    XXDTC = as.Date(c("2017-02-05", "2017-02-06", "2017-02-07",
                      "2017-02-05", "2017-02-06", "2017-02-07")),
    RFSTDTC = as.Date(c(rep("2017-02-05", 3),
                        rep("2017-02-07", 3)))
  )
  expected_df <- df %>%
    dplyr::mutate(XXBLFL = c("Y", NA_character_, NA_character_,
                             NA_character_, "Y", NA_character_))
  expect_equal(create_BLFL(df, sort_date = "XXDTC", domain = "XX"),
               expected_df)
})