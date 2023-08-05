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
#' @param dir string, specification directory
#' @param filename string, file name of the specification
#' @param arrange_by character vector, the column(s) by which to sort the domain
#' sheet, default is `"Order"`
#'
#' @returns a data frame of the variable specification for `domain`
#' @export
get_data_spec <- function (domain, dir, filename, arrange_by = "Order") {
  readxl::read_excel(file.path(dir, filename), sheet = domain) %>%
    dplyr::arrange(dplyr::across(dplyr::all_of(arrange_by)))
}


#' Read in the key variables for a SDTM domain
#'
#' Reads the `"Key Variables"` column from the SDTM specification MS Excel
#' file's `"Datasets"` sheet for the specified `domain`.
#'
#' The `readxl::read_excel()` function will causes an access denied warning when
#' reading in a read-only specification file. This does not affect the data
#' import.
#'
#' @inheritParams get_data_spec
#' @param datasets_sheet a string, the sheet name in the specification Excel
#' file that has the key variables, default is `"Datasets"`
#' @param dataset_col a string, the column name of the domains in the table in
#' `datasets_sheet`, default is `"Dataset"`
#' @param keyvar_col a string, the column name of the key variables in the table
#' in `datasets_sheet`, default is `"Key Variables"`
#'
#' @returns a character vector of key variables for the specified `domain`
#' @export
get_key_vars <- function (domain,
                          dir,
                          filename,
                          datasets_sheet = "Datasets",
                          dataset_col = "Dataset",
                          keyvar_col = "Key Variables") {
  readxl::read_excel(file.path(dir, filename),
                     sheet = datasets_sheet) %>%
    dplyr::filter(!!rlang::sym(dataset_col) %in% domain) %>%
    dplyr::pull(!!rlang::sym(keyvar_col)) %>%
    stringr::str_split(pattern = ", ") %>%
    unlist()
}


#' Read in the code list from the specification for a specific domain
#'
#' Reads-in the `"Codelists"` sheet from the study's specification MS Excel file
#'  and then filters that code list by the variables in the domain
#'
#' @inheritParams get_data_spec
#' @param var_col a string, the column name in the domain spec sheet that
#' contains the variables for that domain, default is `"Variable"`
#' @param codelist_sheet a string, the sheet name of the spec's code list from
#' the spec's .xlsx file, default is `"Codelists"`
#' @param varid_col a string, the column name in the `codelist_sheet` table
#' from the spec's .xlsx file that contains the variable names, default is
#' `"ID"`
#'
#' @returns a data frame with the code list
#' @export
get_codelist <- function (domain,
                          dir,
                          filename,
                          var_col = "Variable",
                          codelist_sheet = "Codelists",
                          varid_col = "ID") {
  spec_vars <- get_data_spec(domain, dir, filename)[[var_col]]
  readxl::read_excel(file.path(dir, filename), sheet = codelist_sheet) %>%
    dplyr::filter(!!rlang::sym(varid_col) %in% spec_vars) %>%
    dplyr::filter(!!rlang::sym(varid_col) != "DOMAIN")
}


#' Assign meta data to columns in a SDTM table based on specification file
#'
#' Trims the length of each text and date variable to the length specified in
#'  the spec and then assigns the attributes `"label"` and `"width"` to each
#'  column.
#'
#' @param tbl a data frame containing a SDTM table
#' @param spec a data frame with the columns `"Variable"` which has a value for
#'  each column in `tbl`, `"Data Type"` which specifies data types by column,
#'  `"Length"` which specifies the character limit for each column, and `"Label"`
#'  which specifies the label for each column
#' @param datatype_col a string, the column in `spec` that contains the data
#' types (which should include the values `"text"` and `"date"`); default is
#' `"Data Type"`
#' @param var_col a string, the column in `spec` that contains the domain
#' variable names
#' @param length_col a string, the column in `spec` that contains the character
#' count limits for each variable
#' @param label_col a string, the column in `spec` that contains the labels for
#' each variable
#'
#' @returns a modified copy of `tbl` with the meta data per specification
#' @export
assign_meta_data <- function (tbl,
                              spec,
                              datatype_col = "Data Type",
                              var_col = "Variable",
                              length_col = "Length",
                              label_col = "Label") {

  # for each column in the table
  for (i in 1:ncol(tbl)) {

    # trim character variables to max length specified
    if (spec[[datatype_col]][which(spec[[var_col]] == names(tbl)[i])] %in%
         c("text", "date")) {
      tbl[[i]] <-
        strtrim(tbl[[i]],
                spec[[length_col]][which(spec[[var_col]] == names(tbl)[i])])
    }

    # assign variable labels and lengths
    attr(tbl[[names(tbl)[i]]], "label") <-
      spec[[label_col]][which(spec[[var_col]] == names(tbl)[i])]
    attr(tbl[[names(tbl)[i]]], "width") <-
      spec[[length_col]][which(spec[[var_col]] == names(tbl)[i])]
  }

  return(tbl)
}
