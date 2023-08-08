#' Reshape format of partial dates
#'
#' Re-arranges partial dates from a format of `"UN-UNK-UNKN"` (`"DD-MMM-YYYY"`)
#' to `"UN/UN/UNKN"` (`"MM/DD/YYYY"`).
#'
#' @details
#'  * The separator character between dates components for the input vector
#'   `dates` can be any commonly used date separator (`"/"`, `"-"`, `"."`,
#'   `" "`).
#'  * In the starting format, the month (`"UNK"`) is a three letter abbreviation
#'   but, in the output format, the month is converted to a number
#'  * The output format is a character vector, not a Date vector, to make some
#'   common SDTM date workflow operations easier
#'  * The case of the input month abbreviation does not matter; `"Feb"`,
#'   `"feb"`, and `"FEB"` will yield the same results
#'
#' @param dates a character vector of partial dates
#' @param output_sep the date component separator for the output, default is
#'  `"/"`
#'
#' @returns a character vector of partial dates in the format `"UN/UN/UNKN"`
#' (`"MM/DD/YYYY"`)
#' @export
#'
#' @examples
#' dates <- c(
#'   "UN-UNK-UNKN",
#'   "UN/UNK/UNKN",
#'   "UN-UNK-2017",
#'   "UN-Feb-2017",
#'   "05-Feb-2017",
#'   "05-UNK-2017",
#'   "05-Feb-UNKN",
#'   NA
#' )
#' reshape_pdates(dates)
reshape_pdates <- function(dates, output_sep = "/") {
  # only process non-NA values
  no_NA_dates <- dates[which(!is.na(dates))]

  # separate date components
  dys <- stringr::str_sub(no_NA_dates, 1, 2)
  yrs <- stringr::str_sub(no_NA_dates, 8, 11)

  # convert months to number format
  mths <- stringr::str_sub(no_NA_dates, 4, 6)
  mths <- stringr::str_to_lower(mths)
  mths[which(mths != "unk")] <- match(
    mths[which(mths != "unk")],
    stringr::str_to_lower(month.abb)
  )
  mths[which(mths == "unk")] <- "UN"
  mths <- stringr::str_pad(mths, width = 2, side = "left", pad = "0")

  # re-arrange and consolidate
  dates2 <- glue::glue("{mths}/{dys}/{yrs}")

  # customize the date component separator
  if (output_sep != "/") {
    dates2 <- stringr::str_replace_all(dates2,
      pattern = "\\/",
      replacement = output_sep
    )
  }

  dates[which(!is.na(dates))] <- dates2
  return(dates)
}


#' Reshape format of all dates (full and partial)
#'
#' Re-arranges full and partial dates in the general form of `"MM/DD/YYYY"` to
#' the ISO 8601 format (`"YYYY-MM-DD"`). This function is appropriate for
#' vectors with mixed full and partial dates because it will not convert the
#' partial dates to `NA` which would occur if you used
#' `as.Date("02/UN/2017", format = "%m/%d/%Y")`.
#'
#' The date component separator in the input vector `dates` can be any
#' character.
#'
#' @param dates a character vector of full and/or partial dates
#'
#' @returns a character vector of full and/or partial dates in the format
#' `"YYYY-MM-DD"`
#' @export
#'
#' @examples
#' dates <- c("02/05/2017", "UN/UN/2017", "02-05-2017", NA)
#' reshape_adates(dates)
reshape_adates <- function(dates) {
  # only perform on non-NA values
  no_NA_dates <- dates[which(!is.na(dates))]

  # separate date into components
  yrs <- stringr::str_sub(no_NA_dates, 7, 10)
  mths <- stringr::str_sub(no_NA_dates, 1, 2)
  dys <- stringr::str_sub(no_NA_dates, 4, 5)

  # re-combine
  dates2 <- glue::glue("{yrs}-{mths}-{dys}")

  dates[which(!is.na(dates))] <- dates2
  return(dates)
}


#' Impute start or end dates
#'
#' Imputes missing date elements for start or end dates. Partial dates should be
#' in the format `"UNKN-UN-UN"` or some combination of those characters and
#' numbers (ie `"2017-UN-UN"`). Dates with no information or dates with a
#' missing year will be converted to `NA`. For start dates, missing days are
#' assumed to be the first of the month while missing months are assumed to be
#' January. For end dates, missing days are assumed to be the last day of the
#' month and missing months are assumed to be December.
#'
#' @param dates a character vector of partial dates (which could also contain
#'  full dates) in the format YYYY-MM-DD
#' @param ptype a string of either `"start"` or `"end"` indicating whether start
#'  or end dates should be imputed, respectively
#' @param input_sep the character that separates date components in `dates`,
#'  default is `"-"`
#'
#' @returns a date vector of imputed dates in the format YYYY-MM-DD
#' @export
#'
#' @examples
#' dates <- c(
#'   "UNKN-UN-UN",
#'   "2017-UN-UN",
#'   "2017-02-UN",
#'   "2017-UN-05",
#'   "2017-09-03",
#'   "UNKN-07-14",
#'   NA
#' )
#' impute_pdates(dates, ptype = "start")
#' impute_pdates(dates, ptype = "end")
impute_pdates <- function(dates, ptype, input_sep = "-") {
  # if input separator is not the default, make them the default
  if (input_sep != "-") {
    # if the input separator needs to be escaped for regex to find it
    if (input_sep == ".") {
      input_sep <- paste0("\\", input_sep)
    }

    dates <- stringr::str_replace_all(dates,
      pattern = input_sep,
      replacement = "-"
    )
  }

  # return NA for UNKN-UN-UN dates
  dates[which(stringr::str_detect(dates, "^UNKN"))] <- NA_character_

  # impute start dates: assume January and 1st of the month
  if (ptype == "start") {
    dates <- stringr::str_replace(dates, pattern = "-UN-", replacement = "-01-")
    dates <- stringr::str_replace(dates, pattern = "UN$", replacement = "01")

    # impute end dates: assume December and last of the month
  } else if (ptype == "end") {
    dates <- stringr::str_replace(dates, pattern = "-UN-", replacement = "-12-")
    eom <- dates[stringr::str_which(dates, pattern = "UN$")]
    eom <- stringr::str_replace(eom, pattern = "UN$", replacement = "01")
    eom <- as.Date(eom) + lubridate::period(num = 1, units = "month") - 1
    dates[stringr::str_which(dates, pattern = "UN$")] <- as.character(eom)
  }

  # convert to date format
  dates <- as.Date(dates)

  return(dates)
}


#' Trim unknown elements in partial dates
#'
#' Removes unknown elements from a partial date. For example, `"2017-UN-UN"`
#' is trimmed to `"2017"` and `"2017-05-UN"` is trimmed to `"2017-05"`.
#' Values of `"UNKN-UN-UN"` are converted to `NA`. Values where only
#' the year and day are known are converted to just the year, ie `"2017-UN-01"`
#' converts to `"2017"`. Full dates are not modified.
#'
#' @param dates a character vector of partial dates in the format `"UNKN-UN-UN"`
#' (`"YYYY-MM-DD"`); full dates can also be included
#' @param input_sep the character that separates date components in the input
#'  vector `dates`, default is `"-"`
#'
#' @returns a character vector of trimmed partial dates and full dates
#' @export
#'
#' @examples
#' dates <- c(
#'   "UNKN-UN-UN",
#'   "2017-UN-UN",
#'   "2017-02-UN",
#'   "2017-UN-05",
#'   "2017-09-03",
#'   "UNKN-07-14",
#'   NA
#' )
#' trim_dates(dates)
trim_dates <- function(dates, input_sep = "-") {
  # input has a non-default date separator, make them the default
  if (input_sep != "-") {
    # if the input separator needs to be escaped for regex to find it
    if (input_sep == ".") {
      input_sep <- paste0("\\", input_sep)
    }

    dates <- stringr::str_replace_all(dates,
      pattern = input_sep,
      replacement = "-"
    )
  }

  # convert anything with an unknown year to NA
  dates[stringr::str_which(dates, pattern = "^UNKN")] <- NA_character_

  # drop all unknown days
  dates <- stringr::str_remove(dates, pattern = "-UN$")

  # if the year and days are known but the month is not, only keep the year
  year_and_day <- dates[which(nchar(dates) == 10 &
    stringr::str_detect(dates, pattern = "-UN"))]
  year_and_day <- stringr::str_sub(year_and_day, 1, 4)
  dates[which(nchar(dates) == 10 &
    stringr::str_detect(dates, pattern = "-UN"))] <- year_and_day

  # drop all unknown months
  dates <- stringr::str_remove(dates, pattern = "-UN$")

  return(dates)
}
