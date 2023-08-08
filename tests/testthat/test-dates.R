test_that("Reshape partial dates", {
  # an example with default output separator
  dates <- c(
    "UN-UNK-UNKN",
    "UN/UNK/UNKN",
    "UN-UNK-2017",
    "UN-Feb-2017",
    "05-Feb-2017",
    "05-UNK-2017",
    "05-Feb-UNKN",
    NA
  )
  expected_dates <- c(
    "UN/UN/UNKN",
    "UN/UN/UNKN",
    "UN/UN/2017",
    "02/UN/2017",
    "02/05/2017",
    "UN/05/2017",
    "02/05/UNKN",
    NA
  )
  expect_equal(reshape_pdates(dates), expected_dates)

  # an example with alternate outdate separator
  output_sep <- " "
  dates <- c(
    "UN-UNK-UNKN",
    "UN/UNK/UNKN",
    "UN-UNK-2017",
    "UN-Feb-2017",
    "05-Feb-2017",
    "05-UNK-2017",
    "05-Feb-UNKN",
    NA
  )
  expected_dates <- c(
    "UN UN UNKN",
    "UN UN UNKN",
    "UN UN 2017",
    "02 UN 2017",
    "02 05 2017",
    "UN 05 2017",
    "02 05 UNKN",
    NA
  )
  expect_equal(reshape_pdates(dates, output_sep = output_sep), expected_dates)
})


test_that("Reshape all dates", {
  dates <- c("02/05/2017", "UN/UN/2017", "02-05-2017", NA)
  expected_dates <- c("2017-02-05", "2017-UN-UN", "2017-02-05", NA)
  expect_equal(reshape_adates(dates), expected_dates)
})


test_that("Trim parital dates", {
  # an example with default input separator
  dates <- c(
    "UNKN-UN-UN",
    "2017-UN-UN",
    "2017-02-UN",
    "2017-UN-05",
    "2017-09-03",
    "UNKN-07-14",
    NA
  )
  expected_dates <- c(
    NA,
    "2017",
    "2017-02",
    "2017",
    "2017-09-03",
    NA,
    NA
  )
  expect_equal(trim_dates(dates), expected_dates)

  # an example with non-default input separator
  input_sep <- "."
  dates <- c(
    "UNKN.UN.UN",
    "2017.UN.UN",
    "2017.02.UN",
    "2017.UN.05",
    "2017.09.03",
    "UNKN.07.14",
    NA
  )
  expected_dates <- c(
    NA,
    "2017",
    "2017-02",
    "2017",
    "2017-09-03",
    NA,
    NA
  )
  expect_equal(trim_dates(dates, input_sep = input_sep), expected_dates)
})


test_that("Impute start dates", {
  # an example with the default input separator
  dates <- c(
    "UNKN-UN-UN",
    "2017-UN-UN",
    "2017-02-UN",
    "2017-UN-05",
    "2017-09-03",
    "UNKN-07-14",
    NA
  )
  expected_dates <- c(
    NA,
    "2017-01-01",
    "2017-02-01",
    "2017-01-05",
    "2017-09-03",
    NA,
    NA
  )
  expected_dates <- as.Date(expected_dates)
  expect_equal(impute_pdates(dates, ptype = "start"), expected_dates)

  # an example with a non-default input separator
  input_sep <- "."
  dates <- c(
    "UNKN.UN.UN",
    "2017.UN.UN",
    "2017.02.UN",
    "2017.UN.05",
    "2017.09.03",
    "UNKN.07.14",
    NA
  )
  expected_dates <- c(
    NA,
    "2017-01-01",
    "2017-02-01",
    "2017-01-05",
    "2017-09-03",
    NA,
    NA
  )
  expected_dates <- as.Date(expected_dates)
  expect_equal(
    impute_pdates(dates, ptype = "start", input_sep = input_sep),
    expected_dates
  )
})


test_that("Impute end dates", {
  dates <- c(
    "UNKN-UN-UN",
    "2017-UN-UN",
    "2017-02-UN",
    "2017-UN-05",
    "2017-09-03",
    "UNKN-07-14",
    NA
  )

  expected_dates <- c(
    NA,
    "2017-12-31",
    "2017-02-28",
    "2017-12-05",
    "2017-09-03",
    NA,
    NA
  )
  expected_dates <- as.Date(expected_dates)

  expect_equal(impute_pdates(dates, ptype = "end"), expected_dates)
})
