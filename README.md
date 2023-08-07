
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sdtmval <a href="https://skgithub14.github.io/sdtmval/"><img src="man/figures/logo.png" align="right" height="139" alt="sdtmval website" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/skgithub14/sdtmval/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/skgithub14/sdtmval/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/skgithub14/sdtmval/branch/master/graph/badge.svg)](https://app.codecov.io/gh/skgithub14/sdtmval?branch=master)
<!-- badges: end -->

The goal of {sdtmval} is to provide a set of tools to assist statistical
programmers in validating Study Data Tabulation Model (SDTM) data sets.

## Installation

You can install the development version of {sdtmval} from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("skgithub14/sdtmval")
```

## A typical work flow example

In this example work flow, we will load in a raw EDC table and transform
it into a SDTM domain table. We will use the fake domain is ‘XX’.

``` r
# set-up
library(sdtmval)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

domain <- "XX"
work_dir <- system.file("extdata", package = "sdtmval")
```

The majority of the data needed is in the EDC form/table xx.csv. There
is also visit date data in the raw EDC form/table vd.csv and study start
and end dates by subject in the production SDTM table dm.sas7dbat. We
will start by importing all of the data we need using the two functions
`read_edc_tbls()` and `read_sdtm_tbls()`. The main difference between
these two functions is that the first reads in .csv files and the second
reads in .sas7dbat files.

``` r
# read in EDC tables from the forms XX and VD
edc_tbls <- c("xx", "vd")
edc_dat <- read_edc_tbls(edc_tbls, dir = work_dir)

# read in SDTM domain DM
sdtm_tbls <- c("dm")
sdtm_dat <- read_sdtm_tbls(sdtm_tbls, dir = work_dir)

knitr::kable(edc_dat$xx)
```

| STUDYID | USUBJID   | VISIT   | XXTESTCD | XXORRES |
|:--------|:----------|:--------|:---------|:--------|
| Study 1 | Subject 1 | Visit 1 | T1       | 1       |
| Study 1 | Subject 1 | Visit 2 | T1       | 0       |
| Study 1 | Subject 1 | Visit 3 | T1       | 2       |
| Study 1 | Subject 1 | Visit 3 | T2       | 100     |
| Study 1 | Subject 1 | Visit 4 | T3       | PASS    |
| Study 1 | Subject 2 | Visit 1 | T1       | 1       |
| Study 1 | Subject 2 | Visit 2 | T1       |         |
| Study 1 | Subject 2 | Visit 3 | T1       | 2       |
| Study 1 | Subject 2 | Visit 3 | T2       | 200     |
| Study 1 | Subject 2 | Visit 4 | T3       | FAIL    |

The next thing we will do is get the relevant information from the SDTM
specification for the study. The next set of functions assumes there is
a .xlsx file which contains the sheets: ‘Datasets’, ‘XX’, and
‘Codelists’. ‘Datasets’ contains the key variables by domain, ‘XX’ gives
the variable information for the XX domain, and ‘Codelists’ provides a
table of coded/decoded values by variable.

``` r
spec_fname <- "spec.xlsx"
spec <- get_data_spec(domain = domain, dir = work_dir, filename = spec_fname)
key_vars <- get_key_vars(domain = domain, dir = work_dir, filename = spec_fname)
codelists <- get_codelist(domain = domain, dir = work_dir, filename = spec_fname)
```

Now we will begin creating the SDTM XX domain using the EDC XX form as
the basis. First, it needs some pre-processing because there is extra
white space in some of the variable which needs trimming. We also want
to turn all NA equivalent values to `NA` for the entire data set for
consistency (in a step near the end these will all be converted back to
`""`).

``` r
sdtm_xx1 <- trim_and_make_blanks_NA(edc_dat$xx)
knitr::kable(sdtm_xx1)
```

| STUDYID | USUBJID   | VISIT   | XXTESTCD | XXORRES |
|:--------|:----------|:--------|:---------|:--------|
| Study 1 | Subject 1 | Visit 1 | T1       | 1       |
| Study 1 | Subject 1 | Visit 2 | T1       | 0       |
| Study 1 | Subject 1 | Visit 3 | T1       | 2       |
| Study 1 | Subject 1 | Visit 3 | T2       | 100     |
| Study 1 | Subject 1 | Visit 4 | T3       | PASS    |
| Study 1 | Subject 2 | Visit 1 | T1       | 1       |
| Study 1 | Subject 2 | Visit 2 | T1       | NA      |
| Study 1 | Subject 2 | Visit 3 | T1       | 2       |
| Study 1 | Subject 2 | Visit 3 | T2       | 200     |
| Study 1 | Subject 2 | Visit 4 | T3       | FAIL    |

In order to calculate the timing variables XXBLFL, EPOCH, and XXDY, we
need to the visit dates from the EDC VD table and the study start/end
dates by subject from the SDTM DM table.

``` r
sdtm_xx2 <- sdtm_xx1 %>%
  
  # get the VISITDTC column from the EDC VD form
  left_join(edc_dat$vd, by = c("USUBJID", "VISIT")) %>%
  rename(XXDTC = VISITDTC) %>%
  
  # get the 
  left_join(sdtm_dat$dm, by = "USUBJID")
  
knitr::kable(sdtm_xx2)
```

| STUDYID | USUBJID   | VISIT   | XXTESTCD | XXORRES | XXDTC      | RFSTDTC    | RFXSTDTC   | RFXENDTC   |
|:--------|:----------|:--------|:---------|:--------|:-----------|:-----------|:-----------|:-----------|
| Study 1 | Subject 1 | Visit 1 | T1       | 1       | 2023-08-01 | 2023-08-02 | 2023-08-02 | 2023-08-03 |
| Study 1 | Subject 1 | Visit 2 | T1       | 0       | 2023-08-02 | 2023-08-02 | 2023-08-02 | 2023-08-03 |
| Study 1 | Subject 1 | Visit 3 | T1       | 2       | 2023-08-03 | 2023-08-02 | 2023-08-02 | 2023-08-03 |
| Study 1 | Subject 1 | Visit 3 | T2       | 100     | 2023-08-03 | 2023-08-02 | 2023-08-02 | 2023-08-03 |
| Study 1 | Subject 1 | Visit 4 | T3       | PASS    | 2023-08-04 | 2023-08-02 | 2023-08-02 | 2023-08-03 |
| Study 1 | Subject 2 | Visit 1 | T1       | 1       | 2023-08-02 | 2023-08-03 | 2023-08-03 | 2023-08-04 |
| Study 1 | Subject 2 | Visit 2 | T1       | NA      | 2023-08-03 | 2023-08-03 | 2023-08-03 | 2023-08-04 |
| Study 1 | Subject 2 | Visit 3 | T1       | 2       | 2023-08-04 | 2023-08-03 | 2023-08-03 | 2023-08-04 |
| Study 1 | Subject 2 | Visit 3 | T2       | 200     | 2023-08-04 | 2023-08-03 | 2023-08-03 | 2023-08-04 |
| Study 1 | Subject 2 | Visit 4 | T3       | FAIL    | 2023-08-05 | 2023-08-03 | 2023-08-03 | 2023-08-04 |

Now, we can proceed with calculating those timing variables:

``` r
sdtm_xx3 <- sdtm_xx2 %>%
  
  # XXBLFL
  create_BLFL(sort_date = "XXDTC",
              domain = domain,
              grouping_vars = c("USUBJID", "XXTESTCD")) %>%
  
  # EPOCH
  create_EPOCH(date_col = "XXDTC") %>%
  
  # XXDY
  calc_DY(DY_col = "XXDY",
          DTC_col = "XXDTC")
  
knitr::kable(sdtm_xx3)
```

| STUDYID | USUBJID   | VISIT   | XXTESTCD | XXORRES | XXDTC      | RFSTDTC    | RFXSTDTC   | RFXENDTC   | XXBLFL | EPOCH     | XXDY |
|:--------|:----------|:--------|:---------|:--------|:-----------|:-----------|:-----------|:-----------|:-------|:----------|-----:|
| Study 1 | Subject 1 | Visit 1 | T1       | 1       | 2023-08-01 | 2023-08-02 | 2023-08-02 | 2023-08-03 | NA     | SCREENING |   -1 |
| Study 1 | Subject 1 | Visit 2 | T1       | 0       | 2023-08-02 | 2023-08-02 | 2023-08-02 | 2023-08-03 | Y      | TREATMENT |    1 |
| Study 1 | Subject 1 | Visit 3 | T1       | 2       | 2023-08-03 | 2023-08-02 | 2023-08-02 | 2023-08-03 | NA     | TREATMENT |    2 |
| Study 1 | Subject 1 | Visit 3 | T2       | 100     | 2023-08-03 | 2023-08-02 | 2023-08-02 | 2023-08-03 | NA     | TREATMENT |    2 |
| Study 1 | Subject 1 | Visit 4 | T3       | PASS    | 2023-08-04 | 2023-08-02 | 2023-08-02 | 2023-08-03 | NA     | FOLLOW-UP |    3 |
| Study 1 | Subject 2 | Visit 1 | T1       | 1       | 2023-08-02 | 2023-08-03 | 2023-08-03 | 2023-08-04 | Y      | SCREENING |   -1 |
| Study 1 | Subject 2 | Visit 2 | T1       | NA      | 2023-08-03 | 2023-08-03 | 2023-08-03 | 2023-08-04 | NA     | TREATMENT |    1 |
| Study 1 | Subject 2 | Visit 3 | T1       | 2       | 2023-08-04 | 2023-08-03 | 2023-08-03 | 2023-08-04 | NA     | TREATMENT |    2 |
| Study 1 | Subject 2 | Visit 3 | T2       | 200     | 2023-08-04 | 2023-08-03 | 2023-08-03 | 2023-08-04 | NA     | TREATMENT |    2 |
| Study 1 | Subject 2 | Visit 4 | T3       | FAIL    | 2023-08-05 | 2023-08-03 | 2023-08-03 | 2023-08-04 | NA     | FOLLOW-UP |    3 |
