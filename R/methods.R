#' Create a BLFL column
#'
#' Utilizes the BLFL method from the SDTM spec to create a baseline flag: Equal
#' to "Y" for last record with non-missing --ORRES on or before first dose date
#' (RFSTDTC); `NA` otherwise.
#'
#' @param tbl a data frame with the variables `USUBJID`, `[domain]ORRES`,
#' `RFSTDTC`, and to column specified in the `sort_date` argument
#' @param sort_date a string, the column name by which to sort records within
#' each `USUBJID` entry before assigning the BLFL value. This is also the date
#' compared against `RFSTDTC` to determine the BLFL value. This column should
#' either already have a date class or be a character vector in the format
#' YYYY-MM-DD
#' @param domain a string, the SDTM domain abbreviation
#' @param grouping_vars a character vector of columns to group by when assigning
#' the BLFL, default is `"USUBJID"`. The order of this vector matters.
#' @param RFSTDTC a string, the column to use for `RFSTDTC`, default is
#' `"RFSTDTC"`
#'
#' @returns a modified copy of `tbl` with the new column `[domain]BLFL`
#' @export
#'
#' @examples
#' df <- dplyr::tibble(
#'   USUBJID = c(rep(1, 3),
#'               rep(2, 3)),
#'   XXORRES = c(1, 2, 2,
#'               1, 2, NA),
#'   XXDTC = as.Date(c("2017-02-05", "2017-02-06", "2017-02-07",
#'                     "2017-02-05", "2017-02-06", "2017-02-07")),
#'   RFSTDTC = as.Date(c(rep("2017-02-05", 3),
#'                       rep("2017-02-07", 3)))
#' )
#' create_BLFL(df, sort_date = "XXDTC", domain = "XX")
#'
create_BLFL <- function (tbl,
                         sort_date,
                         domain,
                         grouping_vars = "USUBJID",
                         RFSTDTC = "RFSTDTC") {
  tbl %>%
    dplyr::arrange(dplyr::across(dplyr::all_of(c(grouping_vars, sort_date)))) %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping_vars))) %>%
    dplyr::mutate(
      pre_dose_visit_num = dplyr::if_else(
        (!!rlang::sym(sort_date)) <= (!!rlang::sym(RFSTDTC)) &
          !is.na(!!rlang::sym(paste0(stringr::str_to_upper(domain), "ORRES"))),
        dplyr::row_number(),
        NA_integer_),

      "{stringr::str_to_upper(domain)}BLFL" := dplyr::case_when(
        all(is.na(pre_dose_visit_num)) ~ NA_character_,
        is.na(pre_dose_visit_num) ~ NA_character_,
        pre_dose_visit_num == max(pre_dose_visit_num, na.rm = T) ~ "Y",
        TRUE ~ NA_character_
      )
    ) %>%
    dplyr::select(-pre_dose_visit_num) %>%
    dplyr::ungroup()
}


#' Create the EPOCH variable
#'
#' Utilizes the EPOCH method from the SDTM spec: Missing when `--DTC` is blank;
#' equal to `'SCREENING'` if `--DTC` if before `RFXSTDTC`; equal to `'TREATMENT'`
#' if `--DTC` is on or after `RFXSTDTC` and on or before `RFXENDTC`; equal to
#' `'FOLLOW-UP'` if `--DTC` is after `RFXENDTC`.
#'
#' @param tbl a data frame with date class columns `RFXSTDTC` and `RFXENDTC` and
#'  the column given in the `date_col` argument
#' @param date_col a string, the column name of the event date used to determine
#'  the EPOCH; this column can either have a date class or a character class in
#'  the YYYY-MM-DD format
#' @param RFXSTDTC a string, the date column to use for `RFXSTDTC`, default is
#' `"RFXSTDTC"`
#' @param RFXENDTC a string, the date column to use for `RFXENDTC`, default is
#' `"RFXENDTC"`
#'
#' @returns a modified copy of `tbl` with the `EPOCH` column
#' @export
create_EPOCH <- function (tbl,
                          date_col,
                          RFXSTDTC = "RFXSTDTC",
                          RFXENDTC = "RFXENDTC") {
  tbl %>%
    dplyr::mutate(
      EPOCH = dplyr::case_when(
        is.na(!!rlang::sym(date_col)) ~ NA_character_,
        as.Date(!!rlang::sym(date_col)) <  (!!rlang::sym(RFXSTDTC)) ~
          "SCREENING",
        as.Date(!!rlang::sym(date_col)) >= (!!rlang::sym(RFXSTDTC)) &
          as.Date(!!rlang::sym(date_col)) <= (!!rlang::sym(RFXENDTC)) ~
          "TREATMENT",
        as.Date(!!rlang::sym(date_col)) > (!!rlang::sym(RFXENDTC)) ~
          "FOLLOW-UP"
      )
    )
}


#' Calculate a DY variable (day of study)
#'
#' Utilizes the DY method from the SDTM spec: `--DTC-RFSTDTC+1` if `--DTC` is on
#' or after RFSTDTC. `--DTC-RFSTDTC` if `--DTC` precedes `RFSTDTC`. This
#' function can also be used for the ENDY method from the spec which has the
#' same logic.
#'
#' @param tbl a data frame with the date column `RFSTDTC` and the column
#'  specified by the `DTC_col` argument
#' @param DY_col string, the name of the new DY column to create
#' @param DTC_col string, the column in `tbl` which has the dates for which to
#'  calculated the DY value; should either already have a date class or be a
#'  character vector in the format YYYY-MM-DD
#' @param RFSTDTC a string, the column to use for `RFSTDTC`, default is
#' `"RFSTDTC"`
#'
#' @returns a modified copy of `tbl` with the new DY column
#' @export
calc_DY <- function (tbl, DY_col, DTC_col, RFSTDTC = "RFSTDTC") {
  tbl %>%
    dplyr::mutate(
      "{DY_col}":= dplyr::case_when(
        (as.Date(!!rlang::sym(DTC_col))) >= (!!rlang::sym(RFSTDTC)) ~
          as.numeric((as.Date(!!rlang::sym(DTC_col))) - (!!rlang::sym(RFSTDTC)) + 1),

        (as.Date(!!rlang::sym(DTC_col))) <  (!!rlang::sym(RFSTDTC)) ~
          as.numeric((as.Date(!!rlang::sym(DTC_col))) - (!!rlang::sym(RFSTDTC))),
        TRUE ~ NA_real_
      )
    )
}


#' Assign SEQ numbers for a SDTM data set
#'
#' Assigns the `"[DOMAIN]SEQ"` number by sorting the data set by the specified
#'  variables and then grouping by `"USUBJID"`.
#'
#' @param tbl a data frame, the SDTM table
#' @param key_vars a character vector of the key variables to sort by
#' @param seq_prefix a string, the prefix for SEQ as per the spec (usually the
#' two letter domain abbreviation)
#' @param USUBJID a string, the column for the subject ID, USUBJID, default is
#' `"USUBJID"`
#'
#' @returns a sorted copy of the `tbl` data frame with the new SEQ column
#' @export
assign_SEQ <- function (tbl, key_vars, seq_prefix, USUBJID = "USUBJID") {
  tbl %>%
    dplyr::arrange(dplyr::across(.cols = dplyr::all_of(key_vars))) %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(USUBJID))) %>%
    dplyr::mutate("{seq_prefix}SEQ" := dplyr::row_number()) %>%
    dplyr::ungroup()
}

