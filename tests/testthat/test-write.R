test_that("write_tbl_to_xpt", {

  tbl <- dplyr::tibble(one = as.numeric(1:3), two = letters[1:3])
  path <- tempdir()
  write_tbl_to_xpt(tbl, filename = "test.xpt", dir = path)
  check <- haven::read_xpt(file.path(path, "test.xpt"))
  expect_identical(tbl, check)

})


test_that("write_sessionInfo", {

  # what is expected to be returned
  path_expected <- tempdir()
  utils::sessionInfo() %>%
    utils::capture.output() %>%
    writeLines(file.path(path_expected, "expected.txt"))
  out_expected <- readLines(file.path(path_expected, "expected.txt"))

  # what is actually returned
  path_actual <- tempdir()
  write_sessionInfo(filename = "actual.R", dir = path_actual)
  out_actual <- readLines(file.path(path_actual, "actual_sessionInfo.txt"))

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
