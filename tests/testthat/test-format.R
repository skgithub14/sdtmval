test_that("trim_and_make_blanks_NA()", {
  df <- data.frame(one = c("   a", "", " "))
  expected_df <- data.frame(one = c("a", NA_character_, NA_character_))
  expect_equal(trim_and_make_blanks_NA(df), expected_df)
})


test_that("format_chars_and_dates()", {
  df <- data.frame(
    dates = as.Date(c("2017-02-05", NA)),
    strings = c(NA_character_, "this"),
    nums = c(1, NA)
  )
  expected_df <- data.frame(
    dates = c("2017-02-05", ""),
    strings = c("", "this"),
    nums = c(1, NA)
  )
  expect_equal(format_chars_and_dates(df), expected_df)
})
