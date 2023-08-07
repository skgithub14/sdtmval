test_that("read_edc_tbls", {
  edc_tbls <- c("xx", "vd")
  edc_dir <- system.file("extdata", package = "sdtmval")
  expected_edc_dat <- list(
    xx = sdtmval::edc_xx,
    vd = sdtmval::vd
  )
  expect_equal(read_edc_tbls(edc_tbls, dir = edc_dir),
               expected_edc_dat)
})


test_that("read_sdtm_tbls", {
  sdtm_tbls <- "dm"
  sdtm_dir <- system.file("extdata", package = "sdtmval")
  expected_sdtm_dat <- list(
    dm = sdtmval::dm
  )
  expect_equal(read_sdtm_tbls(sdtm_tbls, dir = sdtm_dir),
               expected_sdtm_dat)
})
