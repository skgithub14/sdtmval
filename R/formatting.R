#' Trim white space and make blanks NA
#'
#' Trims the white space on both sides of strings in a character vector and
#' replaces blank values (`" "`) with `NA` for all columns in a data frame that
#' have a character class.
#'
#' This function should be applied as one of the first steps in the data process
#' to ensure consistent handling of all strings.
#'
#' @param tbl a data frame, the SDTM table
#'
#' @returns a modified copy of the `tbl` data frame
#' @export
#'
#' @examples
#' df <- data.frame(one = c("   a", ""))
#' trim_and_make_blanks_NA(df)
#'
trim_and_make_blanks_NA <- function (tbl) {
  tbl %>%
    dplyr::mutate(
      dplyr::across(.cols = dplyr::where(is.character), ~ stringr::str_trim(.)),
      dplyr::across(.cols = dplyr::where(is.character), ~ dplyr::na_if(., ""))
    )
}


#' Format date and character columns for SDTM tables
#'
#' Converts all date columns to character class and replaces all `NA` values in
#' character/date columns with `""`.
#'
#' This function should be applied as one of the last steps in the data process
#' but before \code{\link{assign_meta_data}}.
#'
#' @param tbl a data frame, the SDTM table
#'
#' @returns a modified copy of the `tbl` data frame
#' @export
#'
#' @examples
#' df <- data.frame(dates = as.Date(c("2017-02-05", NA)),
#'                  strings = c(NA_character_, "this"),
#'                  nums = c(1, NA))
#' format_chars_and_dates(df)
#'
format_chars_and_dates <- function (tbl) {
  tbl %>%
    dplyr::mutate(dplyr::across(.cols = dplyr::where(lubridate::is.Date),
                                ~ as.character(.))) %>%
    dplyr::mutate(dplyr::across(.cols = dplyr::where(is.character),
                                ~ tidyr::replace_na(., "")))
}
