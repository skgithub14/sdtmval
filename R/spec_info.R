#' Read in the variable specification sheet for a SDTM data set
#'
#' Reads the specified domain variable specification sheet from an MS Excel file.
#'
#' The `read_excel()` function will causes an access denied warning when reading
#'  in a read-only specification file. This does not affect the data import.
#'  Variables will be arranged in descending order per the `"Order"` column in
#'  the specification.
#'
#' @param domain string, SDTM domain or supplemental domain code
#' @param dir_spec string, specification directory
#' @param filename_spec string, file name of the specification
#'
#' @returns a data frame of the variable specification for `domain`
get_data_spec <- function (domain, dir_spec, filename_spec) {
  readxl::read_excel(file.path(dir_spec, filename_spec), sheet = domain) %>%
    dplyr::arrange(Order)
}


#' Read in the key variables for a SDTM domain
#'
#' Reads the `"Key Variables"` column from the SDTM specification MS Excel file's
#'  `"Datasets"` sheet for the specified `domain`.
#'
#' The `read_excel()` function will causes an access denied warning when reading
#'  in a read-only specification file. This does not affect the data import.
#'
#' @param domain string, SDTM domain or supplemental domain code
#' @param dir_spec string, specification directory
#' @param filename_spec string, file name of the specification
#'
#' @returns a character vector of key variables for the specified `domain`
get_key_vars <- function (domain, dir_spec, filename_spec) {
  readxl::read_excel(file.path(dir_spec, filename_spec), sheet = "Datasets") %>%
    dplyr::filter(Dataset %in% domain) %>%
    dplyr::pull(`Key Variables`) %>%
    stringr::str_split(pattern = ", ") %>%
    unlist()
}


#' Read in the code list from the specification for a specific domain
#'
#' Reads-in the `"Codelists"` sheet from the study's specification MS Excel file
#'  and then filters that code list by the variables in the domain
#'
#' @param dir_spec string, specification directory
#'
#' @returns a data frame with the code list
get_codelist <- function (dir_spec, filename_spec) {
  spec_vars <- get_data_spec(domain, dir_spec, filename_spec)$Variable
  readxl::read_excel(file.path(dir_spec, filename_spec), sheet = "Codelists") %>%
    dplyr::filter(ID %in% spec_vars) %>%
    dplyr::filter(ID != "DOMAIN")
}
