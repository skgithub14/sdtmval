test_that("trim_and_make_blanks_NA()", {
  df <- data.frame(one = c("   a", ""))
  expected_df <- data.frame(one = c("a", NA_character_))
  expect_equal(trim_and_make_blanks_NA(df), expected_df)
})
