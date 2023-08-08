#' Write a SAS transport file (.xpt)
#'
#' Writes a data frame to a SAS transport file (.xpt) named like `"[domain].xpt"`
#'
#' Files will be written using version 5 .xpt files
#'
#' @param tbl a data frame to write
#' @param filename a string, the SDTM domain or supplemental domain name which
#'  will become the file name and the name attribute of the transport file
#' @param dir a string, the directory to write to
#'
#' @returns nothing
#' @export
#'
#' @examples
#' work_dir <- system.file("extdata", package = "sdtmval")
#' write_tbl_to_xpt(sdtmval::edc_xx, filename = "test", dir = work_dir)
#'
write_tbl_to_xpt <- function(tbl, filename, dir) {
  haven::write_xpt(tbl,
    file.path(dir, paste0(tolower(filename), ".xpt")),
    version = 5,
    name = filename
  )
}


#' Convert SDTM QC code from a .Rmd file to .R script
#'
#' Wraps `knitr::purl()` to create an .R script from a .Rmd file. It can also
#' auto-archive the .Rmd file to a `[dir]/archive` sub-directory.
#'
#' @details
#'  * The resulting script will take the same name as the .Rmd file but with a
#' different extension (.R)
#'  * If `[dir]/archive` does not already exist, it will be created
#'
#' @param dir string, the directory where the .Rmd file is and the .R file will
#'  be written
#' @param filename string, the .Rmd file name (without the .Rmd extension)
#' @param archive logical, whether to auto-archive the .Rmd file; default is
#'  `FALSE`
#'
#' @returns nothing
#' @export
convert_to_script <- function(dir, filename, archive = F) {
  filenameRmd <- paste0(filename, ".Rmd")

  # create the R script from the Rmd file
  knitr::purl(
    input = file.path(dir, filenameRmd),
    output = file.path(dir, paste0(filename, ".R"))
  )

  # archive the Rmd file, if requested
  if (archive) {
    if (!dir.exists(file.path(dir, "archive"))) {
      dir.create(file.path(dir, "archive"))
    }
    file.copy(
      from = file.path(dir, filenameRmd),
      to = file.path(dir, "archive", filenameRmd)
    )

    # delete html notebook and Rmd file from previous location
    file.remove(file.path(dir, paste0(filename, ".nb")))
    file.remove(file.path(dir, filenameRmd))
  }
}
