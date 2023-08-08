
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

domain <- "XX"

# set working directory (this can be anything)
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
```

The raw data looks like this:

| STUDYID | USUBJID   | VISIT   | XXTESTCD | XXORRES      |
|:--------|:----------|:--------|:---------|:-------------|
| Study 1 | Subject 1 | Visit 1 |    T1    | 1            |
| Study 1 | Subject 1 | Visit 2 |    T1    | 0            |
| Study 1 | Subject 1 | Visit 3 |    T1    |     2        |
| Study 1 | Subject 1 | Visit 3 |    T2    | 100          |
| Study 1 | Subject 1 | Visit 4 |    T3    | PASS         |
| Study 1 | Subject 2 | Visit 1 |    T1    | 1            |
| Study 1 | Subject 2 | Visit 2 |    T1    |              |
| Study 1 | Subject 2 | Visit 3 |    T1    | 2            |
| Study 1 | Subject 2 | Visit 3 |    T2    | 200          |
| Study 1 | Subject 2 | Visit 4 |    T3    |        FAIL  |

The next thing we will do is get the relevant information from the SDTM
specification for the study. The next set of functions assumes there is
a .xlsx file which contains the sheets: ‘Datasets’, ‘XX’, and
‘Codelists’. ‘Datasets’ contains the key variables by domain, ‘XX’ gives
the variable information for the XX domain, and ‘Codelists’ provides a
table of coded/decoded values by variable. `get_data_spec()` imports the
domain tab from the specification file as a data frame, `get_key_vars()`
retrieves the key variables for a domain as a character vector, and
`get_codelist` extracts a data frame of coded/decoded values from the
spec for any variables in the relevant domain.

``` r
spec_fname <- "spec.xlsx"
spec <- get_data_spec(domain = domain, dir = work_dir, filename = spec_fname)
key_vars <- get_key_vars(domain = domain, dir = work_dir, filename = spec_fname)
codelists <- get_codelist(domain = domain, dir = work_dir, filename = spec_fname)

knitr::kable(spec)
```

| Order | Dataset | Variable | Label                               | Data Type | Length |
|------:|:--------|:---------|:------------------------------------|:----------|-------:|
|     1 | XX      | STUDYID  | Study Identifier                    | text      |    200 |
|     2 | XX      | DOMAIN   | Domain Abbreviation                 | text      |    200 |
|     3 | XX      | USUBJID  | Unique Subject Identifier           | text      |    200 |
|     4 | XX      | XXSEQ    | Sequence Number                     | integer   |      8 |
|     5 | XX      | XXTESTCD | XX Test Short Name                  | text      |      8 |
|     6 | XX      | XXTEST   | XX Test Name                        | text      |     40 |
|     7 | XX      | XXORRES  | Result or Finding in Original Units | text      |    200 |
|     8 | XX      | XXBLFL   | Baseline Flag                       | text      |      1 |
|     9 | XX      | VISIT    | Visit Name                          | text      |    200 |
|    10 | XX      | EPOCH    | Epoch                               | text      |    200 |
|    11 | XX      | XXDTC    | Date/Time of Measurements           | datetime  |     19 |
|    12 | XX      | XXDY     | Study Day of XX                     | integer   |      8 |

``` r
knitr::kable(codelists)
```

| ID       | Term | Decoded Value |
|:---------|:-----|:--------------|
| XXTESTCD | T1   | Test 1        |
| XXTESTCD | T2   | Test 2        |
| XXTESTCD | T3   | Test 3        |

``` r
key_vars
#> [1] "STUDYID"  "USUBJID"  "XXTESTCD" "VISIT"
```

Now we will begin creating the SDTM XX domain using the EDC XX form as
the basis.

First, it needs some pre-processing because there is extra white space
in some of the variables. We also want to turn all NA equivalent values
like `""` and `" "` to `NA` for the entire data set so we have
consistent handling of missing values during data processing. The
function `trim_and_make_blanks_NA()` does both of these tasks.

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

Next, using the codelists we retrieved from the spec earlier, we can
create the `XXTEST` variable.

``` r
# prepare the code list so it can be used by dplyr::recode() 
xxtestcd_codelist <- codelists %>%
  filter(ID == "XXTESTCD") %>%
  select(Term, `Decoded Value`) %>%
  tibble::deframe()

# create XXTEST variable
sdtm_xx2 <- mutate(sdtm_xx1, XXTEST = recode(XXTESTCD, !!!xxtestcd_codelist))

knitr::kable(sdtm_xx2)
```

| STUDYID | USUBJID   | VISIT   | XXTESTCD | XXORRES | XXTEST |
|:--------|:----------|:--------|:---------|:--------|:-------|
| Study 1 | Subject 1 | Visit 1 | T1       | 1       | Test 1 |
| Study 1 | Subject 1 | Visit 2 | T1       | 0       | Test 1 |
| Study 1 | Subject 1 | Visit 3 | T1       | 2       | Test 1 |
| Study 1 | Subject 1 | Visit 3 | T2       | 100     | Test 2 |
| Study 1 | Subject 1 | Visit 4 | T3       | PASS    | Test 3 |
| Study 1 | Subject 2 | Visit 1 | T1       | 1       | Test 1 |
| Study 1 | Subject 2 | Visit 2 | T1       | NA      | Test 1 |
| Study 1 | Subject 2 | Visit 3 | T1       | 2       | Test 1 |
| Study 1 | Subject 2 | Visit 3 | T2       | 200     | Test 2 |
| Study 1 | Subject 2 | Visit 4 | T3       | FAIL    | Test 3 |

In order to calculate the timing variables XXBLFL, EPOCH, and XXDY, we
need the visit dates from the EDC VD table and the study start/end dates
by subject from the SDTM DM table.

``` r
sdtm_xx3 <- sdtm_xx2 %>%
  
  # get the VISITDTC column from the EDC VD form
  left_join(edc_dat$vd, by = c("USUBJID", "VISIT")) %>%
  rename(XXDTC = VISITDTC) %>%
  
  # get the study start/end dates by subject
  left_join(sdtm_dat$dm, by = "USUBJID")
  
knitr::kable(sdtm_xx3)
```

| STUDYID | USUBJID   | VISIT   | XXTESTCD | XXORRES | XXTEST | XXDTC      | RFSTDTC    | RFXSTDTC   | RFXENDTC   |
|:--------|:----------|:--------|:---------|:--------|:-------|:-----------|:-----------|:-----------|:-----------|
| Study 1 | Subject 1 | Visit 1 | T1       | 1       | Test 1 | 2023-08-01 | 2023-08-02 | 2023-08-02 | 2023-08-03 |
| Study 1 | Subject 1 | Visit 2 | T1       | 0       | Test 1 | 2023-08-02 | 2023-08-02 | 2023-08-02 | 2023-08-03 |
| Study 1 | Subject 1 | Visit 3 | T1       | 2       | Test 1 | 2023-08-03 | 2023-08-02 | 2023-08-02 | 2023-08-03 |
| Study 1 | Subject 1 | Visit 3 | T2       | 100     | Test 2 | 2023-08-03 | 2023-08-02 | 2023-08-02 | 2023-08-03 |
| Study 1 | Subject 1 | Visit 4 | T3       | PASS    | Test 3 | 2023-08-04 | 2023-08-02 | 2023-08-02 | 2023-08-03 |
| Study 1 | Subject 2 | Visit 1 | T1       | 1       | Test 1 | 2023-08-02 | 2023-08-03 | 2023-08-03 | 2023-08-04 |
| Study 1 | Subject 2 | Visit 2 | T1       | NA      | Test 1 | 2023-08-03 | 2023-08-03 | 2023-08-03 | 2023-08-04 |
| Study 1 | Subject 2 | Visit 3 | T1       | 2       | Test 1 | 2023-08-04 | 2023-08-03 | 2023-08-03 | 2023-08-04 |
| Study 1 | Subject 2 | Visit 3 | T2       | 200     | Test 2 | 2023-08-04 | 2023-08-03 | 2023-08-03 | 2023-08-04 |
| Study 1 | Subject 2 | Visit 4 | T3       | FAIL    | Test 3 | 2023-08-05 | 2023-08-03 | 2023-08-03 | 2023-08-04 |

Now, we can proceed with calculating those timing variables using the
`create_BLFL()`, `create_EPOCH()`, and `calc_DY()` functions.

``` r
sdtm_xx4 <- sdtm_xx3 %>%
  
  # XXBLFL
  create_BLFL(sort_date = "XXDTC",
              domain = domain,
              grouping_vars = c("USUBJID", "XXTESTCD")) %>%
  
  # EPOCH
  create_EPOCH(date_col = "XXDTC") %>%
  
  # XXDY
  calc_DY(DY_col = "XXDY",
          DTC_col = "XXDTC")
  
knitr::kable(sdtm_xx4)
```

| STUDYID | USUBJID   | VISIT   | XXTESTCD | XXORRES | XXTEST | XXDTC      | RFSTDTC    | RFXSTDTC   | RFXENDTC   | XXBLFL | EPOCH     | XXDY |
|:--------|:----------|:--------|:---------|:--------|:-------|:-----------|:-----------|:-----------|:-----------|:-------|:----------|-----:|
| Study 1 | Subject 1 | Visit 1 | T1       | 1       | Test 1 | 2023-08-01 | 2023-08-02 | 2023-08-02 | 2023-08-03 | NA     | SCREENING |   -1 |
| Study 1 | Subject 1 | Visit 2 | T1       | 0       | Test 1 | 2023-08-02 | 2023-08-02 | 2023-08-02 | 2023-08-03 | Y      | TREATMENT |    1 |
| Study 1 | Subject 1 | Visit 3 | T1       | 2       | Test 1 | 2023-08-03 | 2023-08-02 | 2023-08-02 | 2023-08-03 | NA     | TREATMENT |    2 |
| Study 1 | Subject 1 | Visit 3 | T2       | 100     | Test 2 | 2023-08-03 | 2023-08-02 | 2023-08-02 | 2023-08-03 | NA     | TREATMENT |    2 |
| Study 1 | Subject 1 | Visit 4 | T3       | PASS    | Test 3 | 2023-08-04 | 2023-08-02 | 2023-08-02 | 2023-08-03 | NA     | FOLLOW-UP |    3 |
| Study 1 | Subject 2 | Visit 1 | T1       | 1       | Test 1 | 2023-08-02 | 2023-08-03 | 2023-08-03 | 2023-08-04 | Y      | SCREENING |   -1 |
| Study 1 | Subject 2 | Visit 2 | T1       | NA      | Test 1 | 2023-08-03 | 2023-08-03 | 2023-08-03 | 2023-08-04 | NA     | TREATMENT |    1 |
| Study 1 | Subject 2 | Visit 3 | T1       | 2       | Test 1 | 2023-08-04 | 2023-08-03 | 2023-08-03 | 2023-08-04 | NA     | TREATMENT |    2 |
| Study 1 | Subject 2 | Visit 3 | T2       | 200     | Test 2 | 2023-08-04 | 2023-08-03 | 2023-08-03 | 2023-08-04 | NA     | TREATMENT |    2 |
| Study 1 | Subject 2 | Visit 4 | T3       | FAIL    | Test 3 | 2023-08-05 | 2023-08-03 | 2023-08-03 | 2023-08-04 | NA     | FOLLOW-UP |    3 |

Next, we will assign the sequence number using `assign_SEQ()`. This
function also sorts the data set for you by whatever you make the
`key_vars` argument.

``` r
sdtm_xx5 <- assign_SEQ(sdtm_xx4, 
                       key_vars = c("USUBJID", "XXTESTCD", "VISIT"),
                       seq_prefix = domain)
knitr::kable(sdtm_xx5)
```

| STUDYID | USUBJID   | VISIT   | XXTESTCD | XXORRES | XXTEST | XXDTC      | RFSTDTC    | RFXSTDTC   | RFXENDTC   | XXBLFL | EPOCH     | XXDY | XXSEQ |
|:--------|:----------|:--------|:---------|:--------|:-------|:-----------|:-----------|:-----------|:-----------|:-------|:----------|-----:|------:|
| Study 1 | Subject 1 | Visit 1 | T1       | 1       | Test 1 | 2023-08-01 | 2023-08-02 | 2023-08-02 | 2023-08-03 | NA     | SCREENING |   -1 |     1 |
| Study 1 | Subject 1 | Visit 2 | T1       | 0       | Test 1 | 2023-08-02 | 2023-08-02 | 2023-08-02 | 2023-08-03 | Y      | TREATMENT |    1 |     2 |
| Study 1 | Subject 1 | Visit 3 | T1       | 2       | Test 1 | 2023-08-03 | 2023-08-02 | 2023-08-02 | 2023-08-03 | NA     | TREATMENT |    2 |     3 |
| Study 1 | Subject 1 | Visit 3 | T2       | 100     | Test 2 | 2023-08-03 | 2023-08-02 | 2023-08-02 | 2023-08-03 | NA     | TREATMENT |    2 |     4 |
| Study 1 | Subject 1 | Visit 4 | T3       | PASS    | Test 3 | 2023-08-04 | 2023-08-02 | 2023-08-02 | 2023-08-03 | NA     | FOLLOW-UP |    3 |     5 |
| Study 1 | Subject 2 | Visit 1 | T1       | 1       | Test 1 | 2023-08-02 | 2023-08-03 | 2023-08-03 | 2023-08-04 | Y      | SCREENING |   -1 |     1 |
| Study 1 | Subject 2 | Visit 2 | T1       | NA      | Test 1 | 2023-08-03 | 2023-08-03 | 2023-08-03 | 2023-08-04 | NA     | TREATMENT |    1 |     2 |
| Study 1 | Subject 2 | Visit 3 | T1       | 2       | Test 1 | 2023-08-04 | 2023-08-03 | 2023-08-03 | 2023-08-04 | NA     | TREATMENT |    2 |     3 |
| Study 1 | Subject 2 | Visit 3 | T2       | 200     | Test 2 | 2023-08-04 | 2023-08-03 | 2023-08-03 | 2023-08-04 | NA     | TREATMENT |    2 |     4 |
| Study 1 | Subject 2 | Visit 4 | T3       | FAIL    | Test 3 | 2023-08-05 | 2023-08-03 | 2023-08-03 | 2023-08-04 | NA     | FOLLOW-UP |    3 |     5 |

Now that the bulk of the data cleaning is complete, we will convert all
date columns to character columns and all `NA` values to `""` so that
our validation table matches the production table.

``` r
sdtm_xx6 <- format_chars_and_dates(sdtm_xx5)
knitr::kable(sdtm_xx6)
```

| STUDYID | USUBJID   | VISIT   | XXTESTCD | XXORRES | XXTEST | XXDTC      | RFSTDTC    | RFXSTDTC   | RFXENDTC   | XXBLFL | EPOCH     | XXDY | XXSEQ |
|:--------|:----------|:--------|:---------|:--------|:-------|:-----------|:-----------|:-----------|:-----------|:-------|:----------|-----:|------:|
| Study 1 | Subject 1 | Visit 1 | T1       | 1       | Test 1 | 2023-08-01 | 2023-08-02 | 2023-08-02 | 2023-08-03 |        | SCREENING |   -1 |     1 |
| Study 1 | Subject 1 | Visit 2 | T1       | 0       | Test 1 | 2023-08-02 | 2023-08-02 | 2023-08-02 | 2023-08-03 | Y      | TREATMENT |    1 |     2 |
| Study 1 | Subject 1 | Visit 3 | T1       | 2       | Test 1 | 2023-08-03 | 2023-08-02 | 2023-08-02 | 2023-08-03 |        | TREATMENT |    2 |     3 |
| Study 1 | Subject 1 | Visit 3 | T2       | 100     | Test 2 | 2023-08-03 | 2023-08-02 | 2023-08-02 | 2023-08-03 |        | TREATMENT |    2 |     4 |
| Study 1 | Subject 1 | Visit 4 | T3       | PASS    | Test 3 | 2023-08-04 | 2023-08-02 | 2023-08-02 | 2023-08-03 |        | FOLLOW-UP |    3 |     5 |
| Study 1 | Subject 2 | Visit 1 | T1       | 1       | Test 1 | 2023-08-02 | 2023-08-03 | 2023-08-03 | 2023-08-04 | Y      | SCREENING |   -1 |     1 |
| Study 1 | Subject 2 | Visit 2 | T1       |         | Test 1 | 2023-08-03 | 2023-08-03 | 2023-08-03 | 2023-08-04 |        | TREATMENT |    1 |     2 |
| Study 1 | Subject 2 | Visit 3 | T1       | 2       | Test 1 | 2023-08-04 | 2023-08-03 | 2023-08-03 | 2023-08-04 |        | TREATMENT |    2 |     3 |
| Study 1 | Subject 2 | Visit 3 | T2       | 200     | Test 2 | 2023-08-04 | 2023-08-03 | 2023-08-03 | 2023-08-04 |        | TREATMENT |    2 |     4 |
| Study 1 | Subject 2 | Visit 4 | T3       | FAIL    | Test 3 | 2023-08-05 | 2023-08-03 | 2023-08-03 | 2023-08-04 |        | FOLLOW-UP |    3 |     5 |

As a final step, we re-order the columns according to the domain spec
and drop the extra columns using this line of code:
`select(any_of(spec$Variable))`. Then we will assign the meta data from
the spec to each column using `assign_meta_data()`. The meta data
includes the labels for each column and their maximum allowed character
lengths.

``` r
sdtm_xx7 <- sdtm_xx6 %>%
  select(any_of(spec$Variable)) %>%
  assign_meta_data(spec = spec)

# show the final SDTM domain
knitr::kable(sdtm_xx7)
```

| STUDYID | USUBJID   | XXSEQ | XXTESTCD | XXTEST | XXORRES | XXBLFL | VISIT   | EPOCH     | XXDTC      | XXDY |
|:--------|:----------|------:|:---------|:-------|:--------|:-------|:--------|:----------|:-----------|-----:|
| Study 1 | Subject 1 |     1 | T1       | Test 1 | 1       |        | Visit 1 | SCREENING | 2023-08-01 |   -1 |
| Study 1 | Subject 1 |     2 | T1       | Test 1 | 0       | Y      | Visit 2 | TREATMENT | 2023-08-02 |    1 |
| Study 1 | Subject 1 |     3 | T1       | Test 1 | 2       |        | Visit 3 | TREATMENT | 2023-08-03 |    2 |
| Study 1 | Subject 1 |     4 | T2       | Test 2 | 100     |        | Visit 3 | TREATMENT | 2023-08-03 |    2 |
| Study 1 | Subject 1 |     5 | T3       | Test 3 | PASS    |        | Visit 4 | FOLLOW-UP | 2023-08-04 |    3 |
| Study 1 | Subject 2 |     1 | T1       | Test 1 | 1       | Y      | Visit 1 | SCREENING | 2023-08-02 |   -1 |
| Study 1 | Subject 2 |     2 | T1       | Test 1 |         |        | Visit 2 | TREATMENT | 2023-08-03 |    1 |
| Study 1 | Subject 2 |     3 | T1       | Test 1 | 2       |        | Visit 3 | TREATMENT | 2023-08-04 |    2 |
| Study 1 | Subject 2 |     4 | T2       | Test 2 | 200     |        | Visit 3 | TREATMENT | 2023-08-04 |    2 |
| Study 1 | Subject 2 |     5 | T3       | Test 3 | FAIL    |        | Visit 4 | FOLLOW-UP | 2023-08-05 |    3 |

``` r

# check the meta data was assigned
labels <- colnames(sdtm_xx7) %>%
  purrr::map(~ attr(sdtm_xx7[[.]], "label")) %>%
  unlist()
lengths <- colnames(sdtm_xx7) %>%
  purrr::map(~ attr(sdtm_xx7[[.]], "width")) %>%
  unlist()
data.frame(
  column = colnames(sdtm_xx7),
  labels = labels,
  lengths = lengths
)
#>      column                              labels lengths
#> 1   STUDYID                    Study Identifier     200
#> 2   USUBJID           Unique Subject Identifier     200
#> 3     XXSEQ                     Sequence Number       8
#> 4  XXTESTCD                  XX Test Short Name       8
#> 5    XXTEST                        XX Test Name      40
#> 6   XXORRES Result or Finding in Original Units     200
#> 7    XXBLFL                       Baseline Flag       1
#> 8     VISIT                          Visit Name     200
#> 9     EPOCH                               Epoch     200
#> 10    XXDTC           Date/Time of Measurements      19
#> 11     XXDY                     Study Day of XX       8
```

Finally, we will write the SDTM XX domain validation table as a SAS
transport file using `write_tbl_to_xpt()` (which is just a convenience
wrapper for `haven::write_xpt()`).

``` r
write_tbl_to_xpt(sdtm_xx7, filename = domain, dir = work_dir)
```

For each previous steps, we viewed the interim results to demonstrate
the features of {sdtmval} however, {sdtmval} is designed to be used with
pipe operators so that you can have one long, read-able pipe. To
demonstrate, we will reproduce the same results from above in one code
chunk.

``` r
sdtm_xx <- edc_dat$xx %>%
  
  # pre-processing
  trim_and_make_blanks_NA() %>%
  
  # XXTEST
  dplyr::mutate(XXTEST = dplyr::recode(XXTESTCD, !!!xxtestcd_codelist)) %>%

  # get the VISITDTC column from the EDC VD form
  dplyr::left_join(edc_dat$vd, by = c("USUBJID", "VISIT")) %>%
  dplyr::rename(XXDTC = VISITDTC) %>%

  # get the study start/end dates by subject
  dplyr::left_join(sdtm_dat$dm, by = "USUBJID") %>%

  # XXBLFL
  create_BLFL(sort_date = "XXDTC",
              domain = domain,
              grouping_vars = c("USUBJID", "XXTESTCD")) %>%

  # EPOCH
  create_EPOCH(date_col = "XXDTC") %>%

  # XXDY
  calc_DY(DY_col = "XXDY",
          DTC_col = "XXDTC") %>%

  # XXSEQ
  assign_SEQ(key_vars = c("USUBJID", "XXTESTCD", "VISIT"),
             seq_prefix = domain) %>%

  # final formatting
  format_chars_and_dates() %>%
  dplyr::select(dplyr::any_of(spec$Variable)) %>%
  assign_meta_data(spec = spec)

# check if the two data frames are identical
identical(sdtm_xx, sdtm_xx7)
#> [1] TRUE
```
