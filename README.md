
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

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(sdtmval)
## basic example code
```

``` r
edc_tbls <- c("xx", "vd")
edc_dir <- system.file("extdata", package = "sdtmval")
edc_dat <- read_edc_tbls(edc_tbls, dir = edc_dir)
```

``` r
sdtm_tbls <- c("dm")
sdtm_dir <- system.file("extdata", package = "sdtmval")
sdtm_dat <- read_sdtm_tbls(sdtm_tbls, dir = sdtm_dir)
```
