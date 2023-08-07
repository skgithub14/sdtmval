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
