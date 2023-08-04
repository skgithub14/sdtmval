#' Standardize white space trimming and NA for character columns
#'
#' Trims the white space on both sides and replaces blank values with `NA` for
#'  all character columns.
#'
#' This function should be applied as one of the first steps in the data process
#'  to ensure consistent handling of strings.
#'
#' @param tbl a data frame, the SDTM QC table
#'
#' @returns a modified copy of the `tbl` data frame
trim_and_make_blanks_NA <- function (tbl) {
  tbl %>%
    dplyr::mutate(
      dplyr::across(.cols = dplyr::where(is.character), ~ stringr::str_trim(.)),
      dplyr::across(.cols = dplyr::where(is.character), ~ dplyr::na_if(., ""))
    )
}


#' Standardize formatting of date and character columns for QC SDTM tables
#'
#' Converts all date columns to character class and replaces all `NA` values in
#'  character/date columns with `""`.
#'
#' This function should be applied as one of the last steps in the data process
#'  but before `assign_meta_data()`.
#'
#' @param tbl a data frame, the SDTM QC table
#'
#' @returns a modified copy of the `tbl` data frame
format_chars_and_dates <- function (tbl) {
  tbl %>%
    dplyr::mutate(dplyr::across(.cols = dplyr::where(is.Date), ~ as.character(.))) %>%
    dplyr::mutate(dplyr::across(.cols = dplyr::where(is.character), ~ tidyr::replace_na(., "")))
}
