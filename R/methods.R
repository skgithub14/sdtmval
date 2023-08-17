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
#' `"RFSTDTC"`; this columns should either have a date class or a characer class
#' in the YYYY-MM-DD format
#' @param compare_date_method a string, one of `c("on or before", "before")`
#'  indicating where the baseline measurement should be evaluated on or before
#'  the study start date or just before; default is `"on or before"`
#'
#' @returns a modified copy of `tbl` with the new column `[domain]BLFL`
#' @export
#'
#' @seealso [create_EPOCH()], [calc_DY()]
#'
#' @examples
#' df <- dplyr::tibble(
#'   USUBJID = c(
#'     rep(1, 3),
#'     rep(2, 3)
#'   ),
#'   XXORRES = c(
#'     1, 2, 2,
#'     1, 2, NA
#'   ),
#'   XXDTC = as.Date(c(
#'     "2017-02-05", "2017-02-06", "2017-02-07",
#'     "2017-02-05", "2017-02-06", "2017-02-07"
#'   )),
#'   RFSTDTC = as.Date(c(
#'     rep("2017-02-05", 3),
#'     rep("2017-02-07", 3)
#'   ))
#' )
#' create_BLFL(df, sort_date = "XXDTC", domain = "XX")
#'
create_BLFL <- function(tbl,
                        sort_date,
                        domain,
                        grouping_vars = "USUBJID",
                        RFSTDTC = "RFSTDTC",
                        compare_date_method = "on or before") {

  # create a name for a temporary column
  PDVN <- paste0(sample(letters, size = 25), collapse = "")
  while (any(colnames(tbl) == PDVN)) {
    PDVN <- paste0(sample(letters, size = 25), collapse = "")
  }

  tbl <- tbl %>%
    dplyr::arrange(dplyr::across(tidyselect::all_of(c(grouping_vars, sort_date)))) %>%
    dplyr::group_by(dplyr::across(tidyselect::all_of(grouping_vars)))

    # evaluate baseline differently based on `compare_date_method`
    if (compare_date_method == "on or before") {
      tbl <- tbl %>%
        dplyr::mutate(
          "{PDVN}" := dplyr::if_else(
            as.Date((!!rlang::sym(sort_date))) <= as.Date((!!rlang::sym(RFSTDTC))) &
              !is.na(!!rlang::sym(paste0(stringr::str_to_upper(domain), "ORRES"))),
            dplyr::row_number(),
            NA_integer_)
          )
    } else if (compare_date_method == "before") {
      tbl <- tbl %>%
        dplyr::mutate(
          "{PDVN}" := dplyr::if_else(
            as.Date((!!rlang::sym(sort_date))) < as.Date((!!rlang::sym(RFSTDTC))) &
              !is.na(!!rlang::sym(paste0(stringr::str_to_upper(domain), "ORRES"))),
            dplyr::row_number(),
            NA_integer_)
          )
    } else {
      stop("Argument `compare_date_method` must be one of `c('on or before', 'before')`")
    }

  tbl <- tbl %>%
    dplyr::mutate(
    "{stringr::str_to_upper(domain)}BLFL" := dplyr::case_when(
      all(is.na(!!rlang::sym(PDVN))) ~ NA_character_,
      is.na(!!rlang::sym(PDVN)) ~ NA_character_,
      (!!rlang::sym(PDVN)) == suppressWarnings(max(!!rlang::sym(PDVN),
                                                   na.rm = T)) ~ "Y",
      TRUE ~ NA_character_
    )
  ) %>%
  dplyr::select(-tidyselect::all_of(PDVN)) %>%
  dplyr::ungroup()

  return(tbl)
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
#' `"RFXSTDTC"`; this column can either have a date class or a character class in
#'  the YYYY-MM-DD format
#' @param RFXENDTC a string, the date column to use for `RFXENDTC`, default is
#' `"RFXENDTC"`; this column can either have a date class or a character class in
#'  the YYYY-MM-DD format
#'
#' @returns a modified copy of `tbl` with the `EPOCH` column
#' @export
#'
#' @seealso [create_BLFL()], [calc_DY()]
#'
#' @examples
#' df <- data.frame(
#'   DTC = c("2023-08-01", "2023-08-02", "2023-08-03", "2023-08-04"),
#'   RFXSTDTC = rep("2023-08-02", 4),
#'   RFXENDTC = rep("2023-08-03", 4)
#' )
#' create_EPOCH(df, date_col = "DTC")
#'
create_EPOCH <- function(tbl,
                         date_col,
                         RFXSTDTC = "RFXSTDTC",
                         RFXENDTC = "RFXENDTC") {
  tbl %>%
    dplyr::mutate(
      EPOCH = dplyr::case_when(
        is.na(!!rlang::sym(date_col)) ~ NA_character_,
        as.Date(!!rlang::sym(date_col)) < as.Date(!!rlang::sym(RFXSTDTC)) ~
          "SCREENING",
        as.Date(!!rlang::sym(date_col)) >= as.Date(!!rlang::sym(RFXSTDTC)) &
          as.Date(!!rlang::sym(date_col)) <= as.Date(!!rlang::sym(RFXENDTC)) ~
          "TREATMENT",
        as.Date(!!rlang::sym(date_col)) > as.Date(!!rlang::sym(RFXENDTC)) ~
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
#' `"RFSTDTC"`; should either already have a date class or be a
#'  character vector in the format YYYY-MM-DD
#'
#' @returns a modified copy of `tbl` with the new DY column
#' @export
#'
#' @seealso [create_BLFL()], [create_EPOCH()]
#'
#' @examples
#' df <- data.frame(
#'   DTC = c("2023-08-01", "2023-08-02", "2023-08-03", "2023-08-04"),
#'   RFSTDTC = rep("2023-08-02", 4)
#' )
#' calc_DY(df, DY_col = "XXDY", DTC_col = "DTC")
#'
calc_DY <- function(tbl, DY_col, DTC_col, RFSTDTC = "RFSTDTC") {
  tbl %>%
    dplyr::mutate(
      "{DY_col}" := dplyr::case_when(
        as.Date(!!rlang::sym(DTC_col)) >= as.Date((!!rlang::sym(RFSTDTC))) ~
          as.numeric(as.Date(!!rlang::sym(DTC_col)) - as.Date(!!rlang::sym(RFSTDTC)) + 1),
        (as.Date(!!rlang::sym(DTC_col))) < (!!rlang::sym(RFSTDTC)) ~
          as.numeric(as.Date(!!rlang::sym(DTC_col)) - as.Date(!!rlang::sym(RFSTDTC))),
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
#'
#' @examples
#' df <- data.frame(
#'   USUBJID = paste("Subject", c(rep(1, 3), rep(2, 3))),
#'   XXTESTCD = paste("T", rep(c(2, 3, 1), 2))
#' )
#' assign_SEQ(df, key_vars = c("USUBJID", "XXTESTCD"), seq_prefix = "XX")
#'
assign_SEQ <- function(tbl, key_vars, seq_prefix, USUBJID = "USUBJID") {
  tbl %>%
    dplyr::arrange(dplyr::across(.cols = tidyselect::all_of(key_vars))) %>%
    dplyr::group_by(dplyr::across(tidyselect::all_of(USUBJID))) %>%
    dplyr::mutate("{seq_prefix}SEQ" := dplyr::row_number()) %>%
    dplyr::ungroup()
}


#' Assign STAT 'NOT DONE' status
#'
#' Creates a --STAT variable and, if all measurements for a visit were not done,
#' also changes all --TESTCD values as "--ALL"
#'
#' @param df a data frame to modify
#' @param domain a string, the domain abbreviation in all caps
#' @param nd_ind a string, the variable name in `df` that indicates if a test
#'  was not performed, usually a `"Yes"`/`"No"` or `"Y"`/`"N"` column
#' @param nd_ind_cd a string, the code from the `nd_ind` column that signifies
#'  a test was not done, default is `"Yes"`
#' @param USUBJID a string, the variable name in `df` that contains the subject
#'  identifier, default is `"USUBJID"`
#' @param VISIT a string, the variable name in `df` that indicates a VISIT field,
#'  default is `"VISIT"`
#'
#' @returns a modified copy of `df`
#' @export
#'
#' @examples
#' df <- dplyr::tibble(
#'   USUBJID = paste("Subject", c(rep("A", 2), rep("B", 4), rep("C", 2))),
#'   VISIT = paste("Visit", c(1  , 2  , 1  , 1  , 2  , 2  , 2  , 2)),
#'   XXTESTCD = paste("Test", c(1  , 2  , 1  , 2  , 1  , 2  , 1  , 2)),
#'   ND = c("N", "N", "Y", "Y", "N", "N", "Y", "Y")
#' )
#' create_STAT(df = df, domain = "XX", nd_ind = "ND", nd_ind_cd = "Y")
#'
create_STAT <- function(df,
                        domain,
                        nd_ind,
                        nd_ind_cd = "Yes",
                        USUBJID = "USUBJID",
                        VISIT = "VISIT") {

  # check the required variables are present
  must_have_cols <- c(nd_ind, USUBJID, VISIT, paste0(domain, "TESTCD"))
  stopifnot(all(must_have_cols %in% colnames(df)))

  # create a temporary variable for storing row numbers
  tmp_var <- paste0(sample(letters, 25), collapse = "")
  while (tmp_var %in% colnames(df)) {
    tmp_var <- sample(letters, 25)
  }

  df <- df %>%

    # mark not done status and create STAT variable
    dplyr::mutate("{domain}STAT" := dplyr::if_else(
      !!rlang::sym(nd_ind) == nd_ind_cd,
      "NOT DONE",
      NA_character_
    )) %>%

    # consolidate all rows for the same subject and visit with NOT DONE tests
    #  into one --TESTCD with --ALL values
    dplyr::group_by(dplyr::across(tidyselect::all_of(c(USUBJID, VISIT)))) %>%
    dplyr::mutate("{domain}TESTCD" := dplyr::case_when(
      all(!is.na(!!rlang::sym(paste0(domain, "STAT")))) ~ paste0(domain, "ALL"),
      TRUE ~ !!rlang::sym(paste0(domain, "TESTCD"))
    )) %>%

    # remove duplicates of --ALL values
    dplyr::mutate(
      "{tmp_var}" := dplyr::row_number(),

      "{tmp_var}" := dplyr::case_when(
      !!rlang::sym(paste0(domain, "TESTCD")) != paste0(domain, "ALL") ~ NA_integer_,
      TRUE ~ !!rlang::sym(tmp_var)
    )) %>%
    dplyr::filter(is.na(!!rlang::sym(tmp_var)) | (!!rlang::sym(tmp_var)) == 1) %>%
    dplyr::select(-tidyselect::all_of(tmp_var)) %>%
    dplyr::ungroup()

  return(df)
}






















