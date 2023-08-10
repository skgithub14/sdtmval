test_that("write_tbl_to_xpt", {

  tbl <- dplyr::tibble(one = as.numeric(1:3), two = letters[1:3])
  path <- tempfile()
  write_tbl_to_xpt(tbl, filename = paste0(path, ".xpt"))
  check <- haven::read_xpt(paste0(path, ".xpt"))
  expect_identical(tbl, check)

})


test_that("write_sessionInfo", {

  # what is expected to be returned
  path_expected <- tempfile()
  utils::sessionInfo() %>%
    utils::capture.output() %>%
    writeLines(paste0(path_expected, ".txt"))
  out_expected <- readLines(paste0(path_expected, ".txt"))

  # what is actually returned
  path_actual <- tempfile()
  write_sessionInfo(paste0(path_actual, ".R"))
  out_actual <- readLines(paste0(path_actual, "_sessionInfo.txt"))

  expect_equal(out_actual, out_expected)
})


test_that("convert_to_script", {

  # get test notebook from the sdtmval/inst/extdata dir and copy it to temp dir
  test_file_dir <- system.file("extdata", package = "sdtmval")
  filename <- "test_notebook"
  temp_path <- tempdir()
  file.copy(from = file.path(test_file_dir, paste0(filename, ".Rmd")),
            to = file.path(temp_path, paste0(filename, ".Rmd")))

  # create the script and archive the .Rmd file
  convert_to_script(dir = temp_path, filename = filename, archive = T)

  # check the script exists
  expect_true(file.exists(file.path(temp_path, paste0(filename, ".R"))))

  # check the .Rmd is archived exists
  expect_true(
    file.exists(
      file.path(temp_path, "archive", paste0(filename, ".Rmd"))
    )
  )

  # check the .Rmd is no longer in the original directory
  expect_false(
    file.exists(
      file.path(temp_path, paste0(filename, ".Rmd"))
    )
  )

})
