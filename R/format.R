#' Trim white space and make blanks NA
#'
#' Trims the white space on both sides of strings in a character vector and
#' replaces blank values (`""` and `" "`) with `NA` for all columns in a data
#' frame that have a character class.
#'
#' This function should be applied as one of the first steps in the data process
#' to ensure consistent handling of all strings.
#'
#' @param tbl a data frame, the SDTM table
#'
#' @returns a modified copy of the `tbl` data frame
#' @export
#'
#' @seealso [format_chars_and_dates()]
#'
#' @examples
#' df <- data.frame(one = c("   a", "", " "))
#' trim_and_make_blanks_NA(df)
#'
trim_and_make_blanks_NA <- function(tbl) {
  tbl %>%
    dplyr::mutate_if(.predicate = is.character,
                     .funs = list(~ stringr::str_trim(.))) %>%
    dplyr::mutate_if(.predicate = is.character,
                     .funs = list(~ dplyr::na_if(., ""))) %>%
    dplyr::mutate_if(.predicate = is.character,
                     .funs = list(~ dplyr::na_if(., " ")))
}


#' Format date and character columns for SDTM tables
#'
#' Converts all date columns to character class and replaces all `NA` values in
#' character/date columns with `""`.
#'
#' This function should be applied as one of the last steps in the data process
#' but before [assign_meta_data()].
#'
#' @param tbl a data frame, the SDTM table
#'
#' @returns a modified copy of the `tbl` data frame
#' @export
#'
#' @seealso [trim_and_make_blanks_NA()]
#'
#' @examples
#' df <- data.frame(
#'   dates = as.Date(c("2017-02-05", NA)),
#'   strings = c(NA_character_, "this"),
#'   nums = c(1, NA)
#' )
#' format_chars_and_dates(df)
#'
format_chars_and_dates <- function(tbl) {

  tbl <- tbl %>%
    dplyr::mutate_if(.predicate = lubridate::is.Date,
                     .funs = list(~ as.character(.))) %>%
    dplyr::mutate_if(.predicate = is.character,
                     .funs = list(~ tidyr::replace_na(., "")))

  return(tbl)
}
