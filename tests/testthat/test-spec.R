test_that("get_data_spec()", {
  work_dir <- system.file("extdata", package = "sdtmval")
  spec <- get_data_spec(domain = "XX",
                        dir = work_dir,
                        filename = "spec.xlsx")
  expect_equal(spec, sdtmval::spec_XX)
})


test_that("get_key_vars()", {
  work_dir <- system.file("extdata", package = "sdtmval")
  key_vars <- get_key_vars(domain = "XX",
                           dir = work_dir,
                           filename = "spec.xlsx")
  expected_key_vars <- sdtmval::spec_datasets$`Key Variables`[1] %>%
    stringr::str_split_1(pattern = ", ")
  expect_equal(key_vars, expected_key_vars)
})


test_that("get_codelist()", {
  work_dir <- system.file("extdata", package = "sdtmval")
  codelists <- get_codelist(domain = 'XX',
                            dir = work_dir,
                            filename = "spec.xlsx")
  expect_equal(codelists, sdtmval::spec_codelists)
})


test_that("get_valuelevel()", {

  work_dir <- system.file("extdata", package = "sdtmval")
  valuelevel <- get_valuelevel(domain = "SUPPXX",
                               dir = work_dir,
                               filename = "spec.xlsx") %>%
    dplyr::mutate(dplyr::across(.cols = tidyselect::where(is.logical),
                                ~ as.character(.)))
  expect_equal(valuelevel, sdtmval::spec_valuelevel)

})


test_that("assign_meta_data()", {
  work_dir <- system.file("extdata", package = "sdtmval")
  spec <- get_data_spec(domain = "XX",
                        dir = work_dir,
                        filename = "spec.xlsx")
  after_meta_data <- assign_meta_data(sdtmval::xx_no_meta_data, spec = spec)
  expected <- sdtmval::xx_no_meta_data
  attr(expected$STUDYID, "label") <- "Study Identifier"
  attr(expected$USUBJID, "label") <- "Unique Subject Identifier"
  attr(expected$XXSEQ, "label") <- "Sequence Number"
  attr(expected$XXTESTCD, "label") <- "XX Test Short Name"
  attr(expected$XXTEST, "label") <- "XX Test Name"
  attr(expected$XXORRES, "label") <- "Result or Finding in Original Units"
  attr(expected$XXBLFL, "label") <- "Baseline Flag"
  attr(expected$VISIT, "label") <- "Visit Name"
  attr(expected$EPOCH, "label") <- "Epoch"
  attr(expected$XXDTC, "label") <- "Date/Time of Measurements"
  attr(expected$XXDY, "label") <- "Study Day of XX"
  attr(expected$STUDYID, "width") <- 200
  attr(expected$USUBJID, "width") <- 200
  attr(expected$XXSEQ, "width") <- 8
  attr(expected$XXTESTCD, "width") <- 8
  attr(expected$XXTEST, "width") <- 40
  attr(expected$XXORRES, "width") <- 200
  attr(expected$XXBLFL, "width") <- 1
  attr(expected$VISIT, "width") <- 200
  attr(expected$EPOCH, "width") <- 200
  attr(expected$XXDTC, "width") <- 19
  attr(expected$XXDY, "width") <- 8
  expect_equal(after_meta_data, expected)
})














