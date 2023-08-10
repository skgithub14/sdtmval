# sdtmval 

# sdtmval 0.1.1

## Major changes

* Changed argument order for `write_tbl_to_xpt()`, `convert_to_script()`, and `write_sessionInfo()` and set default for the `dir` argument to these functions as `NULL` 

## Minor changes

* Improved `write_tbl_to_xpt()`, `convert_to_script()`, and `write_sessionInfo()` with input checking. Also added unit tests and improved the documentation and examples for these functions.

* `write_tbl_to_xpt()` now lets users set a data set name/label different from `filename`

# sdtmval 0.2.0

## Major changes

* Added functions for comparing QC to production SDTM domain data sets (`compare_qc_to_prod()`, `inspect_diffs()`, `summary_diffs()`)

* Added `convert_to_script()` for converting exploratory .Rmd to production .R scripts

* Added `write_sessionInfo()` for logging R session state after a script is run

## Minor changes

* Improved function documentation, {pkgdown} site, and README example

# sdtmval 0.1.0

* Initial release.
