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
write_tbl_to_xpt <- function(tbl, filename, dir) {
  haven::write_xpt(tbl,
    file.path(dir, paste0(tolower(filename), ".xpt")),
    version = 5,
    name = filename
  )
}


#' Convert SDTM QC code from a .Rmd file to .R script
#'
#' Wraps `knitr::purl()` to create an .R script from a .Rmd file and also
#' auto-archives the .Rmd file to an `[dir]/archive` sub-directory.
#'
#' The function assumes the name of the .Rmd file is `"v_[domain].Rmd"` where
#'  the domain is all lowercase. The resulting script will take the same name,
#'  with a different extension (.R).
#'
#' @param dir string, the directory where the .Rmd file is and the .R file will
#'  be written
#' @param domain string, the SDTM domain abbreviation
#'
#' @returns nothing
#' @export
convert_to_script <- function(dir, domain) {
  fname <- paste0("v_", stringr::str_to_lower(domain))
  fnameRmd <- paste0(fname, ".Rmd")

  # create the R script from the Rmd file
  knitr::purl(
    input = file.path(dir, fnameRmd),
    output = file.path(dir, paste0(fname, ".R"))
  )

  # archive the Rmd file
  if (!dir.exists(file.path(dir, "archive"))) {
    dir.create(file.path(dir, "archive"))
  }
  file.copy(
    from = file.path(dir, fnameRmd),
    to = file.path(dir, "archive", fnameRmd)
  )

  # delete html notebook and Rmd file from previous location
  file.remove(file.path(dir, paste0(fname, ".nb")))
  file.remove(file.path(dir, fnameRmd))
}
