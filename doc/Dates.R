## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----example1, message=FALSE--------------------------------------------------
library(sdtmval)
library(dplyr)

raw_dates <- data.frame(
  raw_full = c(
    rep(NA, 8),
    "02/05/2017",
    "02-05-2017"
  ),
  raw_partial = c(
    "UN-UNK-UNKN",
    "UN/UNK/UNKN",
    "UN UNK UNKN",
    "UN-UNK-2017",
    "UN-Feb-2017",
    "05-FEB-2017",
    "05-UNK-2017",
    "05-Feb-UNKN",
    rep(NA, 2)
  )
)
knitr::kable(raw_dates)

## ----example2-----------------------------------------------------------------
working_dates <- raw_dates %>%
  mutate(
    partial = reshape_pdates(raw_partial),
    all = coalesce(raw_full, partial),
    all = reshape_adates(all)
  )
knitr::kable(working_dates)

## ----example3-----------------------------------------------------------------
trimmed_dates <- mutate(working_dates, trimmed = trim_dates(all))
knitr::kable(trimmed_dates)

## ----example4-----------------------------------------------------------------
imputed_dates <- working_dates %>%
  mutate(
    start = impute_pdates(all, ptype = "start"),
    end = impute_pdates(all, ptype = "end")
  )
knitr::kable(imputed_dates)

