#' View `compareDF::compare_df()` summary
#'
#' Prints two items, the first being the `change_summary` element of a
#' `compareDF::compare_df()` output list that shows a comparison of the total
#' number or records between the two data frames being compared. The second
#' printed item is a two column matrix that shows the number of `"+"` entries
#' (adds) and the number of `"-"` entries (dels) from a `compare_df()` output
#' list. The rows of the matrix are the columns in the two data frames being
#' compared. This function is used to summarize the output of
#' `compareDF::compare_df()` so the user can quickly see which columns have the
#' most differences.
#'
#' @param comp a list output from `compareDF::compare_df()`
#'
#' @returns nothing
#' @export
summary_diffs <- function(comp) {
  print("comp$change_summary")
  print(comp$change_summary)

  print("Counts by Column")
  adds <- apply(comp$comparison_table_diff, 2, function(x) sum(x == "+"))
  dels <- apply(comp$comparison_table_diff, 2, function(x) sum(x == "-"))
  mat <- cbind(adds, dels)
  colnames(mat) <- c("adds", "dels")
  print(mat)
}


#' Inspect differences by column using `compareDF::compare_df()` output
#'
#' Provides a filtered data frame which shows only the rows of
#' `comparison_df` element of `compareDF::compare_df()` output list that has
#' differences. Only the column names specified in `diff_col`, `id_cols`, and
#' `other_cols`, along with `grp` and `chng_type` will be shown.
#'
#' @param comp a list which output from `compareDF::compare_df()`
#' @param diff_col a string, the column name to show difference for
#' @param id_cols a character vector of column names that collectively form a
#'  unique row, generally this should be the same vector supplied to the
#'  `group_col` argument of the original `compareDF::compare_df()` call.
#' @param other_cols optional, a character vector of additional columns to show
#'  in the output data frame.
#'
#' @returns a data frame
#' @export
inspect_diffs <- function(comp, diff_col, id_cols, other_cols = NULL) {
  # use comp$comparison_table_diff, which shows changes by cell using +, -, and =,
  #  to get the row numbers where a column has differences
  diff_rows <- comp$comparison_table_diff %>%
    dplyr::mutate(rownum = dplyr::row_number()) %>%
    dplyr::filter((!!rlang::sym(diff_col)) %in% c("+", "-")) %>%
    dplyr::pull(rownum)

  # filter comp$comparison_df to inspect the change
  diffs <- comp$comparison_df %>%
    dplyr::mutate(rownum = dplyr::row_number()) %>%
    dplyr::filter(rownum %in% diff_rows) %>%
    dplyr::select(
      grp,
      chng_type,
      dplyr::all_of(c(id_cols, diff_col)),
      dplyr::any_of(other_cols)
    )

  # if in interactive mode, view the diffs data frame in separate window
  if (interactive()) {
    View(diffs)
  }

  return(diffs)
}


#' Compare production to QC versions of an SDTM table
#'
#' Wraps `compareDF::compare_df()` function and prints a high level summary
#' using \code{\link{summary_diffs}}. The arguments of `compareDF::compare_df()`
#' are set to `stop_on_error = F` to avoid errors if the data frames are the
#' same, and `group_col` is set to `key_vars`.
#'
#' @param qc a data frame, the SDTM QC table
#' @param prod a data frame, the SDTM production table
#' @param group_col a character vector, the columns to use a unique keys for
#' comparing `qc` and `prod`. Ideally this is the key variables for the domain
#' as set out in the specification.
#'
#' @returns a named list as returned by `compareDF::compare_df()`. A side effect
#' also prints a high level summary using `summary_diff()`.
#' @export
compare_qc_to_prod <- function(qc, prod, group_col) {
  comp <- compareDF::compare_df(qc,
    prod,
    group_col = group_col,
    stop_on_error = F
  )
  print("")
  summary_diffs(comp)
  return(comp)
}
