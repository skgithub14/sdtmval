#' Write a SAS transport file (.xpt)
#'
#' Writes a data frame to a SAS transport file (.xpt) named like `"[domain].xpt"`
#'
#' Files will be written using version 5 .xpt files
#'
#' @param tbl a data frame to write
#' @param filename a string, the SDTM domain or supplemental domain name which
#'  will become the file name and the name attribute of the transport file, the
#'  .xpt file extension is optional
#' @param dir a string, the directory to write to, default is `NULL`
#' @param label a string, the data set name/label for the [haven::write_xpt()]
#'  `name` argument. The default is `NULL` in which case the `filename` will be
#'   used. `label` must be 8 characters or less.
#'
#' @returns nothing
#' @export
#'
#' @examples
#' tbl <- dplyr::tibble(one = as.numeric(1:3), two = letters[1:3])
#' path <- tempdir()
#' write_tbl_to_xpt(tbl, filename = "test.xpt", dir = path)
#'
write_tbl_to_xpt <- function(tbl, filename, dir = NULL, label = NULL) {

  # input checks
  if (stringr::str_detect(filename, "\\.xpt$")) {
    filename <- stringr::str_remove(filename, "\\.xpt$")
  }

  if (is.null(label)) {
    label <- filename
  }

  if (stringr::str_detect(label, "[:punct:]")) {
    label <- stringr::str_remove_all(label, "[:punct:]")
  }

  if (nchar(label) > 8) {
    label <- stringr::str_sub(label, 1, 8)
  }

  if (is.null(dir)) {
    write_path <- paste0(tolower(filename), ".xpt")
  } else {
    write_path <- file.path(dir, paste0(tolower(filename), ".xpt"))
  }

  haven::write_xpt(tbl,
    write_path,
    version = 5,
    name = label
  )
}


#' Convert SDTM QC code from a .Rmd file to .R script
#'
#' Wraps [knitr::purl()] to create an .R script from a .Rmd file. It can also
#' auto-archive the .Rmd file to a `[dir]/archive` sub-directory. This is useful
#' for turning first-attempt exploratory data analysis into production scripts
#' once the validation code is complete.
#'
#' @details
#'  * The resulting script will take the same name as the .Rmd file but with a
#' different extension (.R)
#'  * If `[dir]/archive` does not already exist, it will be created
#'
#' @param filename string, the file name of both the .Rmd file that will be read
#' and the file name of the .R file to be written (do not include .Rmd or .R
#' extension)
#' @param dir string, the directory where the .Rmd file is and the .R file will
#'  be written, default is `NULL` which means the current working directory
#'  will be used
#' @param archive logical, whether to auto-archive the .Rmd file; default is
#'  `FALSE`
#'
#' @returns nothing
#' @export
#'
#' @seealso [write_sessionInfo()]
#'
#' @examples
#' # get test notebook from the sdtmval/inst/extdata dir and copy it to temp dir
#' test_file_dir <- system.file("extdata", package = "sdtmval")
#' filename <- "test_notebook"
#' temp_path <- tempdir()
#' file.copy(from = file.path(test_file_dir, paste0(filename, ".Rmd")),
#'           to = file.path(temp_path, paste0(filename, ".Rmd")))
#'
#' # create the script and archive the .Rmd file
#' convert_to_script(dir = temp_path, filename = filename, archive = TRUE)
#'
convert_to_script <- function(filename, dir = NULL, archive = FALSE) {
  filenameRmd <- paste0(filename, ".Rmd")

  if (is.null(dir)) {
    current_Rmd <- filenameRmd
    archived_Rmd <- file.path("archive", filenameRmd)
    current_nb <- paste0(filename, ".nb")
    new_R <- paste0(filename, ".R")
    archive_dir <- "archive"
  } else {
    current_Rmd <- file.path(dir, filenameRmd)
    archived_Rmd <- file.path(dir, "archive", filenameRmd)
    current_nb <- file.path(dir, paste0(filename, ".nb"))
    new_R <- file.path(dir, paste0(filename, ".R"))
    archive_dir <- file.path(dir, "archive")
  }

  # create the R script from the Rmd file
  knitr::purl(input = current_Rmd, output = new_R)

  # archive the Rmd file, if requested
  if (archive) {
    if (!dir.exists(archive_dir)) { dir.create(archive_dir) }
    file.copy(from = current_Rmd, to = archived_Rmd)

    # delete html notebook and Rmd file from previous location
    if (file.exists(current_nb)) { file.remove(current_nb) }
    file.remove(current_Rmd)
  }
}


#' Write R session information for a script to a .txt file
#'
#' Writes a .txt file of the output from [utils::sessionInfo()] with the file
#' name `[filename]_sessionInfo.txt`. By creating a log of the R session
#' conditions a script was run with, results from the script can be reproduced
#' in the future.
#'
#' @param filename a string, the script file name (with or without .R extension)
#' @param dir a string, the directory to write to, default is `NULL` which means
#'  the current working directory will be used
#'
#' @returns nothing
#' @export
#'
#' @seealso [convert_to_script()]
#'
#' @examples
#' path <- tempdir()
#' write_sessionInfo(filename = "test.R", dir = path)
#'
write_sessionInfo <- function (filename, dir = NULL) {

  # input checks
  if (stringr::str_detect(filename, "\\.R$")) {
    filename <- stringr::str_remove(filename, "\\.R$")
  }

  # set the log file name and path
  log_fname <- paste0(filename, "_sessionInfo.txt")
  if (is.null(dir)) {
    write_path <- log_fname
  } else {
    write_path <- file.path(dir, log_fname)
  }

  # get session info and write it to a text file
  utils::sessionInfo() %>%
    utils::capture.output() %>%
    writeLines(write_path)
}
